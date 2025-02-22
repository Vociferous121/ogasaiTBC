script_grindEX = {
	isSetup = false,
	drawTarget = true,
	drawStatus = true,
	drawPath = true,
	drawGather = true,
	drawAutoPath = true,
	currentMapZone = 0,
	unstuckRight = true,
	drawRaycastPath = true,
	strafeLeft = false,
	jumpFloat = 97,
	waitTimer = 0,
	sentToLog = false,
	jumpInWater = false,
	jumpTimer = 0,
}

function script_grindEX:setup()

	script_grindEX:setZone();

	self.isSetup = true;
end

function script_grindEX:window()
	EndWindow();
	if(NewWindow("Grinder", 200, 100)) then
		script_grindMenu:menu();
	end
end

function script_grindEX:draw()
	-- Draw window
	script_grindEX:window()

	-- Draw mesh
	if (script_pather.drawMesh) then
		script_patherEX:drawMesh(2, 8, script_pather.maxZSlopeDown, script_pather.maxZSlopeUp);
	end

	-- Draw current target
	if (self.drawTarget) then
		script_info:drawUnitsDataOnScreen();
	end
	
	if (self.drawGather) then
		script_gather:drawGatherNodes();
	end

	if (self.jumpInWater) then
		script_grind.jump = false;
	end

	-- Draw auto path 
	if (self.drawAutoPath) then
		script_path:draw();
		DrawNavMeshPath(true);
	end
	if (self.drawRaycastPath) then
		script_patherEX:drawPath();
	end

	-- Draw info and status
	if (self.drawStatus) then
		local pX, pY, onScreen = WorldToScreen(GetUnitsPosition(GetLocalPlayer()));
		pX = pX - 70;
		pY = pY + 100;
		if (onScreen) then
			DrawRectFilled(pX - 5, pY - 5, pX + 385, pY + 65, 0, 0, 0, 160, 0, 0);
			--DrawRect(pX - 5, pY - 5, pX + 385, pY + 65, 0, 190, 45,  1, 1, 1);
			DrawText("Grinder", pX, pY, 0, 190, 45);
			DrawText('Current Hotspot: ' .. script_path.hName, pX, pY+10, 255, 128, 0);
			DrawText('Status: ' .. (script_grind.message or " "), pX, pY+20, 255, 255, 0);
			DrawText('Script Speed: ' .. math.max(((script_grind.waitTimer + script_grind.tickRate) - GetTimeEX()), 0) .. ' ms', pX, pY+30, 255, 255, 255);
			DrawText('Unstuck in: ' .. 10-math.floor(((GetTimeEX()-(script_path.savedPos['time'] or GetTimeEX()))/1000), 0) .. ' second(s)', pX, pY+40, 0, 255, 0);
			if (AreBagsFull()) then
			DrawText('Warning bags are full...', pX, pY+50, 255, 0, 0);
			end	
			if (script_grind.skipLoot) then
				DrawText('Skip loot enabled: ' .. script_grind.skipReason, pX, pY+50, 255, 0, 0);
			end	
		end
	end
end

function script_grindEX:doChecks()
	-- Check: wait for channeling and casting
	if (IsChanneling() or IsCasting()) then script_path:savePos(true); return true; end 

	-- Load a hotspot from hotspotDB.lua
	if (script_path.autoLoadHotspot) then 
		script_path:updateHotspot();
	end

	-- Check map id and update vendors
	if (self.currentMapZone ~= 0) then
		if (self.currentMapZone ~= GetCurrentMapZone()) then
			self.currentMapZone = GetCurrentMapZone();
			vendorDB:loadDBVendors();
		end
	else
		self.currentMapZone = GetCurrentMapZone();
	end

	-- Check: User pause
	if (script_grind.pause) then
		-- reset paranoia logout time when paused...
		script_grind.currentTime2 = GetTimeEX() + script_grind.setLogoutTime;
		-- reset unstuck when paused
		script_path:savePos(true);
		script_path.hx = 0;
		script_path.hy = 0;
		script_path.hz = 0;
		script_path.numSavedPathNodes = 0;
		script_grind.message = "Paused by user...";
		if (IsMoving()) then
			StopMoving();
		end
		return true;
	end

	-- Check: jump to the surface if we are under water
	--local progress = GetMirrorTimerProgress("BREATH");
	--if (progress ~= nil and progress ~= 0) and (self.jumpInWater) then
	--	if ((progress/1000) < 35) then
	--		self.message = "Let's not drown...";
	--		script_debug.debugGrind = "using jump out of water";
	--		Jump();
	--		self.waitTimer = GetTimeEX() + 5500;
	--	end	
	--end

	
	if (script_grind.jump) and (not IsSwimming()) and (IsMoving()) and (not IsInCombat()) and (not script_checkDebuffs:hasDisabledMovement()) and (GetTimeEX() > self.jumpTimer) then
		local randomJump = math.random(-100, 100);
		local randomWait = random(550, 8215);
		if randomJump > self.jumpFloat then
			JumpOrAscendStart();
			self.waitTimer = GetTimeEX() + randomWait;
		end
	end

	-- save pos while/if moving
	script_path:savePos(false); 

	if (script_grind.unStuckTime > GetTimeEX()) then

		-- send position to log file
		if (not self.sentToLog) then
			local x, y, z = GetPosition(GetLocalPlayer());
			local time = math.floor(GetTimeEX()/1000);
			local angle = math.floor(GetAngle(GetLocalPlayer()));
			local string = "Time - " ..time.. " | Position - x " ..math.floor(x).. " | y " ..math.floor(y)..  " | z "  ..math.floor(z).. " | Facing Angle - " .. angle ..  "";
			ToFile(string);
			self.sentToLog = true;
		end
		script_target:resetLoot(); -- remove loot so we dont stuck on loot targets we cant reach

		if (not self.unstuckRight) then
			StrafeRightStart();
		else
			self.strafeLeft = true;
			StrafeLeftStart();
			
		end
		script_helper:jump();
		if (script_grind.raycastPathing) then
			script_pather.status = 2;
		end
		return true;
	end

	if (not self.unstuckRight) then
		StrafeRightStop();
	else
		if (self.strafeLeft) then
		StrafeLeftStop();
		self.strafeLeft = false;
		end
	end

	-- Check: Unstuck feature
	if (script_path:unStuck() and (GetTimeEX() - script_path.savedPos['time']) < 20000) then
		script_grind.message = "Trying to unstuck..."; 
		script_grind.unStuckTime = GetTimeEX()+3500; 
		local mx, my, mz = GetPosition(GetLocalPlayer());
		MoveToTarget(mx+2, my+2, mz);
		self.unstuckRight = not self.unstuckRight;
		return true; 
	end

	-- Don't run checks if dead
	if (IsDead(GetLocalPlayer())) then
		return false;
	else
		-- Check: Spend talent points
		if (not IsInCombat() and script_grind.autoTalent) then
			if (script_talent:learnTalents()) then
				script_grind.message = "Checking/learning talent: " .. script_talent:getNextTalentName();
				script_path.savedPos['time'] = GetTimeEX();
				script_grind.tickRate = 50;
				script_grind.waitTimer = GetTimeEX() - 5000;
				script_path:savePos(true); 
			return true;
			end
		end
	end

	-- Run vendor script if status not idle and we are swimming, even if in combat
	if (script_vendor.status ~= 0 and script_grind.useVendor and IsSwimming()) then
		script_path:savePos(false); -- save Pos for unstuck feature

		script_target:resetLoot(); -- reset loot while swimming

		script_grind.message = script_vendor.message;

		-- Run vendor routine and add wait time
		script_grind.waitTimer = GetTimeEX() - 1000 + script_vendor:run();

		return true;
	end

	-- Run the vendor script until finished
	if (script_vendor.status ~= 0 and script_grind.useVendor and (not IsInCombat() or IsMounted())) then

		if (script_grind.waitTimer > GetTimeEX()) then
			return true;
		end

		script_path:savePos(false); -- save Pos for unstuck feature

		-- Rest out of combat
		if (not IsInCombat()) then
			if ((not IsSwimming()) and (not IsFlying())) then RunRestScript();
			else script_grind.shouldRest = false; end
		if (script_grind.shouldRest) then 
			script_path:savePos(true); -- SAVE FOR UNSTUCK
			script_grind.message = "Resting..."; script_grind.waitTimer = GetTimeEX() + 2500; return true; end
		end

		-- Loot if there is anything to loot
		if (script_target:isThereLoot() and not IsInCombat() and not AreBagsFull() and not script_grind.bagsFull) then
			script_grind.tickRate = 150;
			script_grind.message = "Looting... (enable auto loot)";
			script_target:doLoot();
			script_grind.waitTimer = GetTimeEX() + 150;
		return true;
		end

		if (not IsMounted() and script_grind.useMount and IsOutdoors() and script_grind.tryMountTime < GetTimeEX()) then
			if (IsMoving()) then StopMoving(); script_grind.waitTimer = 500; return true; end
			script_helper:useMount(); script_grind.tryMountTime = GetTimeEX()+10000; return true;
		end

		script_grind.message = script_vendor.message;

		-- Run vendor routine and add wait time
		script_grind.waitTimer = GetTimeEX() - 1000 + script_vendor:run();
		
		return true;
	end

	-- Check: Vendor refill
	if (script_grind.useVendor and script_grind.vendorRefill and not IsInCombat()) then
		if (script_vendorEX:checkVendor(script_grind.refillMinNr, script_grind.useMana)) then
			return true;
		end
	end

	-- Check: If our gear is yellow
	local id, texture, checkRelic = GetInventorySlotInfo("MainHandSlot");
	local durability, max = GetInventoryItemDurability(id);
	
	if (durability ~= nil) then
		local isYellow = durability/max;
		if (isYellow < 0.2 and script_grind.repairWhenYellow and script_grind.useVendor and script_vendorEX.repairVendor ~= 0 and not IsInCombat()) then
			script_vendor:repair();
			return true;
		end
	end

	-- Check: If Mainhand is broken
	local isMainHandBroken = GetInventoryItemBroken("player", 16);
	if (script_grind.stopIfMHBroken and isMainHandBroken) then
		script_grind.message = "Stopped: The main hand weapon is broken...";
		return true;
	end

	-- Check: When bags are full
	if ((AreBagsFull() or script_grind.bagsFull) and not IsInCombat()) then
		-- Sell if we are full and there is a sell vendor loaded
		if (script_grind.sellWhenFull and script_grind.useVendor and script_vendorEX.sellVendor ~= 0) then
			script_vendor:sell();
			return true;
		end
	
		if (script_grind.hsWhenFull and HasItem("Hearthstone")) then
			script_grind.message = 'Inventory is full, using Hearthstone...';
			if (UseItem("Hearthstone") == 1) then script_grind.waitTimer = GetTimeEX()+20000; return true; end
			if (script_grind.stopWhenFull) then script_grind.message = "Stopping bot..."; Logout(); StopBot(); end
			return true;
		end
	end
	return false;
end

function script_grindEX:setZone()

	local myZone = GetZoneText();

	if 	myZone == "Ghostlands"
		or myZone == "Azuremyst Isle"
		or myZone == "Bloodmyst Isle"
		or myZone == "Eversong Woods"
		or myZone == "Hellfire Peninsula"
		or myZone == "Zangarmarsh"
		or myZone == "Nagrand"
		or myZone == "Terrokar Forest"
		or myZone == "Shadowmoon Valley"
		or myZone == "Netherstorm" then

		script_grind.raycastPathing = true;
		script_grind.meleeDistance = 3.5;
	end
return false;
end