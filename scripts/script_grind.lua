script_grind = {
	isSetup = false,
	helperLoaded = include("scripts\\script_helper.lua"),
	targetLoaded = include("scripts\\script_target.lua"),
	pathLoaded = include("scripts\\script_path.lua"), 
	vendorScript = include("scripts\\script_vendor.lua"),
	grindExtra = include("scripts\\script_grindEX.lua"),
	grindMenu = include("scripts\\script_grindMenu.lua"),
	autoTalents = include("scripts\\script_talent.lua"),
	safeRessLoaded = include("scripts\\script_safeRess.lua"),
	info = include("scripts\\script_info.lua"),
	gather = include("scripts\\script_gather.lua"),
	rayPather = include("scripts\\script_pather.lua"),
	debugincluded = include("scripts\\script_debug.lua"),
	aggroincluded = include("scripts\\script_aggro.lua"),
	checkDebuffsLoaded = include("scripts\\script_checkDebuffs.lua"),
	unstuckLoaded = include("scripts\\script_unstuck.lua"),
	paranoidLoaded = include("scripts\\script_paranoid.lua"),
	grindEX2Loaded = include("scripts\\script_grindEX2.lua"),

	message = 'Starting the grinder...',
	alive = true,
	target = 0,
	targetTimer = GetTimeEX(),
	pullDistance = 30,
	waitTimer = 0,
	tickRate = 500,
	adjustTickRate = false,
	restHp = 60,
	restMana = 60,
	potHp = 10,
	potMana = 10,
	pause = true,
	stopWhenFull = false,
	hsWhenFull = false,
	shouldRest = false,
	skipMobTimer = 0,
	useMana = true,
	skipLoot = false,
	currentTime2 = 0,
	skipReason = 'user selected...',
	stopIfMHBroken = false,
	useVendor = false,
	sellWhenFull = true,
	repairWhenYellow = true,
	bagsFull = false,
	vendorRefill = false,
	refillMinNr = 5,
	unStuckPos = {},
	unStuckTime = 0,
	jump = false,
	useMount = true,
	tryMountTime = 0,
	autoTalent = true,
	gather = true,
	raycastPathing = false,
	showRayMenu = false,
	useNavMesh = true,
	combatStatus = 0, -- 0 = in range, 1 = not in range
	drawPath = false,
	useUnstuckScript = false,
	setLogoutTime = 30,
	currentTime = 0,
	timerSet = false,
	moveToMeleeRange = false,
}


function script_grind:setup()

	--ZoneNames1 = { GetMapZones(1) } ;
	--ZoneNames2 = { GetMapZones(2) } ;
	--ZoneNames3 = { GetMapZones(3) } ;
	--for i = 1, ZoneNames3 do
	--if (GetCurrentMapAreaID() == 1941) then
	--	self.raycastPathing = true;
	--end

	SetPVE(true);
	SetAutoLoot();
	DrawNavMeshPath(true);

	self.skipMobTimer = GetTimeEX();
	self.unStuckTime = GetTimeEX();
	self.tryMountTime = GetTimeEX();
	self.waitTimer = GetTimeEX();

	-- Classes that doesn't use mana
	local class, classFileName = UnitClass("player");
	if (strfind("Warrior", class) or strfind("Rogue", class)) then
		self.useMana = false;
		self.restMana = 0;
	end

	-- don't vendor if a mage
	if (strfind("Mage", class)) then
		self.vendorRefill = false;
	end

	-- don't refill low level
	if (GetLevel(GetLocalPlayer()) <= 5) then
		self.vendorRefill = false;
	end

	-- don't use mount if we don't have one
	if (GetLevel(GetLocalPlayer()) <= 39) then
		self.useMount = false;
	end

	hotspotDB:setup();

	DEFAULT_CHAT_FRAME:AddMessage('script_grind: loaded...');
	script_grindEX:setup();
	script_helper:setup(); 
	script_path:setup();
	script_target:setup();
	script_vendor:setup();
	script_talent:setup();
	script_pathFlyingEX:setup();

	script_rogue.useRotation = false;
	script_mage.useRotation = false;
	script_druid.useRotation = false;
	script_paladin.useRotation = false;
	script_warrior.useRotation = false;
	script_shaman.useRotation = false;
	script_hunter.useRotation = false;
	script_priest.useRotation = false;
	script_warlock.useRotation = false;


	self.isSetup = true;


end

function script_grind:draw() 
	-- Draw everything
	script_grindEX:draw();
end

function script_grind:enemiesAttackingUs() -- returns number of enemies attacking us
	local unitsAttackingUs = 0; 
        local localPlayer = GetLocalPlayer();
	local i, t = GetFirstObject(); 
	while i ~= 0 do 
    		if t == 3 then
			if (CanAttack(i) and not IsDead(i)) then
				if (localPlayer ~= nil and localPlayer ~= 0 and not IsDead(localPlayer)) then
					if (GetUnitsTarget(i) ~= nil and GetUnitsTarget(i) ~= 0) then
	                			unitsAttackingUs = unitsAttackingUs + 1; 
	                		end 
				end
	            	end 
	       	end
	i, t = GetNextObject(i); 
    	end
    return unitsAttackingUs;
end

-- set timer for grind script to run
function script_grind:setWaitTimer(ms)
	self.waitTimer = (GetTimeEX() + (ms));
end

function script_grind:run()
	-- Run the setup function once
	if (not self.isSetup) then
		script_grind:setup();
		script_debug.debugGrind = "setup";
		return;
	end

	-- draw aggro circles
	if (script_aggro.drawAggro) then
		script_aggro:drawAggroCircles(65);
	end

	-- paranoia timer
	self.currentTime = GetTimeEX();

	-- rogue wait timers
	script_rogue.waitTimer = GetTimeEX();
	--mage wait timers
	script_mage.waitTimer = GetTimeEX();
	script_mage.gemTimer = GetTimeEX();
	--warlock timers
	script_warlock.waitTimer = GetTimeEX();
	script_warlocksiphonTime = GetTimeEX();
	script_warlockagonyTime = GetTimeEX();
	script_warlockcorruptTime = GetTimeEX();
	script_warlockimmoTime = GetTimeEX();
	script_warlockstoneTime = GetTimeEX();
	-- warrior timers
	script_warrior.waitTimer = GetTimeEX();
	-- paladin timers
	script_paladin.waitTimer = GetTimeEX();
	script_paladin.sealTimer = GetTimeEX();
	-- priest timers
	script_priest.waitTimer = GetTimeEX();
	-- shaman timers
	script_shaman.waitTimer = GetTimeEX();
	-- hunter timers
	script_hunter.waitTimer = GetTimeEX();
	-- druid timers
	script_druid.waitTimer = GetTimeEX();

	-- draw move path
	if (IsMoving()) and (self.drawPath) then
		DrawMovePath();
	end

	-- Load nav mesh
	if (self.useNavMesh) then
		if (script_path:loadNavMesh()) then
			self.message = "Loading the oGasai maps...";
			script_debug.debugGrind = "loading nav";
			return;
		end
	end

	if (self.waitTimer + self.tickRate > GetTimeEX()) then
		return;
	end

	-- adjust tick rate
	if (not self.adjustTickRate) then
	
		-- moving tick rate
		if (not IsInCombat() or IsMoving()) then
			self.tickRate = 50;
		end
		-- combat tick rate
		if (not IsMoving() or IsInCombat()) then
			local tickRandom = math.random(242, 721);
			self.tickRate = tickRandom;
		end
	end


	-- Update min/max level if we level up
	if (script_target.currentLevel ~= GetLevel(GetLocalPlayer())) then
		script_target.minLevel = script_target.minLevel + 1;
		script_target.maxLevel = script_target.maxLevel + 2;
		script_target.currentLevel = script_target.currentLevel + 1;
	end

	-- Check: jump to the surface if we are under water
	local progress = GetMirrorTimerProgress("BREATH");
	if (progress ~= nil and progress ~= 0) then
		if ((progress/1000) < 35) then
			self.message = "Let's not drown...";
			script_debug.debugGrind = "using jump out of water";
			Jump();
			return;
		end	
	end

	-- was here... testing...

	if (self.useUnstuckScript) then --and (not self.pause) then
			script_unstuck:drawChecks();
	end

	if (self.useUnstuckScript) then
		if (not script_unstuck:pathClearAuto(2)) then
			script_unstuck:unstuck();
			return true;
		end
	end

	-- end was here...
	--was here goes below...

	-- Check: jump over obstacles
	if (IsMoving()) and (not self.pause) then

		if (not IsInCombat()) then
			script_debug.debugGrind = "checking jump over obstacles";
		end

		-- was here....
		

		script_pather:jumpObstacles();
	end

	-- Update node distance depending on if we are mounted or not
	script_path:setNavNodeDist();

	-- Check: Pause, Unstuck, Vendor, Repair, Buy and Sell etc
	if (script_grindEX:doChecks()) then
		if (not IsInCombat()) and (not IsMoving()) then
			script_debug.debugGrind = "doing grindEX checks";
		end
		return;
	end

	if (script_paranoid.paranoiaUsed) then
		script_paranoid.paranoiaUsed = false;
	end

	-- do paranoia
	if (script_paranoid.useParanoia) and (not self.pause) and (script_paranoid.paranoidOn) and (not IsInCombat()) then
		if (script_paranoid:doParanoia()) then

			if (script_paranoid.stopMovement) then
				if (IsMoving()) then
					StopMoving();
				end
			end

			script_paranoid.paranoiaUsed = true;

			self.message = "Paranoid turned on - player in range!";
		
			if (script_paranoid.logoutOnParanoid) and (not IsInCombat()) and (script_paranoid.paranoiaUsed) then
				-- logout timer reached then logout
				if (self.currentTime / 1000 > ((self.currentTime2 / 1000) + self.setLogoutTime)) then
					StopBot();
					Logout();
					self.currentTime2 = GetTimeEX() *2;
				end
			end

				script_path.savedPos['time'] = GetTimeEX();

		return;
		end
	end

	if (not script_paranoid:doParanoia()) then
		script_paranoid.logoutTimerSet = false;
		self.currentTime2 = self.currentTime + self.setLogoutTime;
		script_paranoid.paranoiaUsed = false;
	end

	if (IsDead(self.target)) then 
		-- Keep saving path nodes at dead target's locations
		if (script_path.reachedHotspot) then
			script_path:savePathNode();
			script_debug.debugGrind = "hotspot reached save path node";
		end
		-- Add dead target to the loot list
		if (not self.skipLoot) then
			script_target:addLootTarget(self.target);
			script_debug.debugGrind = "add target to loot";
		end
		self.target = nil; 
		ClearTarget();
		return;
	end

	-- Dead
	if (IsDead(GetLocalPlayer())) then
			self.waitTimer = GetTimeEX() + 1500;
		if (self.alive) then
			self.alive = false;
			RepopMe();
			self.message = "Releasing spirit...";
			self.waitTimer = GetTimeEX() + 1500;
			return;
		end
			self.message = script_helper:ress(GetCorpsePosition()); 
			script_path:savePos(false); -- SAVE FOR UNSTUCK
		return;
	else
	-- Alive
		self.alive = true;
		script_path:savePos(false); -- SAVE FOR UNSTUCK
	end

	-- Check: Rest 
	local hp = GetHealthPercentage(GetLocalPlayer());
	local mana = GetManaPercentage(GetLocalPlayer());

	-- Stand up after resting
	--if (self.useMana) then
	--	script_debug.debugGrind = "stand up after resting";
	--	if (hp >= 92 and mana >= 92 and not IsStanding()) then
	--		--StopMoving();
	--		self.shouldRest = false;
	--	return;
		
	--	else
	--		if (IsDrinking() or IsEating()) then
	--			script_debug.debugGrind = "we should drink";
	--			self.shouldRest = true;
	--		end
	--	end
	--else
		--if (hp >= 92 and not IsStanding()) then
		--	--StopMoving();
		--	self.shouldRest = false;
		--return;
		--else
		--	if (IsEating()) then
		--	script_debug.debugGrind = "we should eat";
		--		self.shouldRest = true;
		--	end
		--end
	--end

	-- Rest out of combat
	if (not IsInCombat() or (IsInCombat()) and script_info:nrTargetingMe() == 0) then
		script_debug.debugGrind = "resting";
		if ((not IsSwimming()) and (not IsFlying())) then
			RunRestScript();
		else
			self.shouldRest = false;
		end
		if (self.shouldRest) then 
			script_path:savePos(true); -- SAVE FOR UNSTUCK
			self.message = "Resting..."; self.waitTimer = GetTimeEX() + 2500;
			return;
		end
	else
		-- Use Potions in combat
		if (hp < self.potHp) then
			script_helper:useHealthPotion();
			script_debug.debugGrind = "using potion";
		end
		if (mana < self.potMana and self.useMana) then
			script_helper:useHealthPotion();
			script_debug.debugGrind = "using potion";
		end
		-- Dismount in combat
		if (IsMounted()) then
			Dismount();
			return;
		end 
		ResetNavigate();
		script_pather:resetPath()
		script_debug.debugGrind = "reset navigate";
	end

	if (not IsInCombat()) and (not AreBagsFull()) then
		if (HasItem("Small Barnacled Clam")) then
			if (UseItem("Small Barnacled Clam")) then
				self.waitTimer = GetTimeEX() + 1650;
			end
		end

		if (HasItem("Cracked Power Core")) then
			if (DeleteItem("Cracked Power Core")) then
				self.waitTimer = GetTimeEX() + 1650;
			end
		end
	end

	-- Check: Summon our Demon if we are not in combat (Voidwalker is Summoned in favor of the Imp)
	if (HasSpell("Summon Imp")) then
		if (script_warlock:summonPet()) then
			return;
		end
	end

	-- Loot
	if (script_target:isThereLoot() and not AreBagsFull() and not self.bagsFull) and (not script_grindEX2:isAnyTargetTargetingMe()) then
		self.message = "Looting... (enable auto loot)";
		script_target:doLoot();
		if (IsLooting()) then 
			self.waitTimer = GetTimeEX() + 750;
		end
	return;
	end

	-- stuck in combat
	if (IsInCombat()) and (not script_grindEX2:isAnyTargetTargetingMe()) and (GetHealthPercentage(GetUnitsTarget(localObj)) >= 100)
		and (GetDistance(GetUnitsTarget(localObj)) > 10) then
		self.message = "Stuck in combat... waiting...";
		if (IsMoving()) then
			StopMoving();
			return;
		end
	return true;
	end

	-- Wait for group members
	if (GetNumPartyMembers() > 2) then

		script_debug.debugGrind = "waiting for group memebrs";

		if (script_followEX:getTarget() ~= 0) then
			local targetGUID = script_followEX:getTarget();
			self.target = GetGUIDTarget(targetGUID);
			UnitInteract(self.target);
		else
			if (script_info:waitGroup() and not IsInCombat()) then
				self.message = 'Waiting for group (rest & movement)...';
				script_path:savePos(true);
				return;
			end
		end
	end

	-- Gather
	if (self.gather and not IsInCombat() and not AreBagsFull() and not self.bagsFull) then
		if (script_gather:gather()) then
			self.message = 'Gathering ' .. script_gather:currentGatherName() .. '...';
			script_debug.debugGrind = "using gatherer";
			return;
		end
	end
	
	-- stop then we reach target if we are ranged class
	if (not self.moveToMeleeRange) then
		if (script_path.reachedHotspot) and (not IsInCombat()) and (GetDistance(self.target) <= 27) and (not script_target:hasDebuff('Frost Nova') and not script_target:hasDebuff('Frostbite')) then
			if (IsMoving()) and (IsInLineOfSight(self.target)) then
				StopMoving();
				return;
			end
		end
	end
	
	-- stop when we have reached hotspot to attack target if we are a hunter class
	if (HasSpell("Raptor Strike")) then
		if (script_path.reachedHotspot) and (not IsInCombat())
			and (GetDistance(self.target) <= 30) and (IsInLineOfSight(self.target)) and (not script_target:hasDebuff('Frost Nova') and not script_target:hasDebuff('Frostbite')) then
			if (IsMoving()) and (IsInLineOfSight(self.target)) then
				StopMoving();
				return;
			end
		end
	end	
		
	-- Fetch a new target
	if (self.skipMobTimer < GetTimeEX() or (IsInCombat() and script_info:nrTargetingMe() > 0)) then	
			script_debug.debugGrind = "fetching a new target";
		if (script_path.reachedHotspot or (not IsUsingNavmesh() and not self.raycastPathing) or IsInCombat()) then
			local targetGUID = script_target:getTarget();
			self.target = GetGUIDTarget(targetGUID);
			if (GetTarget() ~= self.target) then
				-- this causes mage to walk to melee range...
				if (self.moveToMeleeRange) then
					UnitInteract(self.target);
				end
				AutoAttack(self.target);
			end	
		end
	else
		-- Move away from unvalid targets
		if (IsUsingNavmesh() or self.raycastPathing) then 
			script_path:autoPath();
			script_debug.debugGrind = "auto pathing move away from invalid target";
		else
			Navigate();
			script_debug.debugGrind = "navigate to target";
		end
		return;
	end

	-- Check: Dont pull monsters too far away from the grinding hotspot
	if (self.target ~= 0 and self.target ~= nil and not IsInCombat()) then
		local mx, my, mz = GetPosition(self.target);
		local mobDistFromHotSpot = math.sqrt((mx - script_path.hx)^2+(my - script_path.hy)^2);
		if (mobDistFromHotSpot > script_path.grindingDist) then
			script_debug.debugGrind = "moving to hotspot before we pull";
			self.target = nil;
			self.skipMobTimer = GetTimeEX() + 15000; -- 15 sec to move back to waypoints
			ClearTarget();
		end
	end

	-- Dont fight if we are swimming
	if (IsSwimming()) and (script_path.reachedHotspot) then
		script_debug.debugGrind = "we are swimming don't attack";
		self.target = nil;
		if (IsUsingNavmesh() or self.raycastPathing) then 
			script_path:autoPath();
		else 
			Navigate();
			script_debug.debugGrind = "navigate while swimming";
		end
		script_target:resetLoot(); -- reset loot while swimming
		self.skipMobTimer = GetTimeEX() + 15000; -- 15 sec to move back to waypoints
		self.message = "Don't fight in water...";
		return;
	end
	
	-- If we have a valid target attack it
	if (self.target ~= 0 and self.target ~= nil) then

		script_debug.debugGrind = "attack valid target";
		if (GetDistance(self.target) < self.pullDistance and IsInLineOfSight(self.target)) and (not IsMoving() or GetDistance(self.target) <= 4) then
			if (not script_target:hasDebuff('Frost Nova') and not script_target:hasDebuff('Frostbite')) then
				if (IsMoving()) and (IsInLineOfSight(self.target)) then
					StopMoving();
					return;
				end
			end
			if (not IsMoving()) then
				FaceTarget(self.target);
			end
		else
			-- If we can't move to the target keep on grinding	
			local x, y, z = GetPosition(self.target);
			if (IsNodeBlacklisted(x, y, z, 5)) then
				self.target = nil;
				self.message = "Can't move to the target..";
				if (IsUsingNavmesh() or self.raycastPathing) then 
					script_debug.debugGrind = "auto path to target";
					script_path:autoPath();
				end
				return;
			end

			-- stuck in combat
			if (IsInCombat()) and (GetPet() ~= 0) and (not script_hunter.useRotation) then
				if (GetUnitsTarget(localObj) == 0) and (GetUnitsTarget(GetPet()) == 0) and (GetNumPartyMembers() < 1) then
					if (GetUnitsTarget(GetPet()) ~= 0) then
						AssistUnit("pet");
					end
					self.message = "No Target - stuck in combat! WAITING!";
					if (IsMoving()) then
						StopMoving();
						return;
					end
					return;
				end
			end

			-- stop when we get close enough to target and we are a ranged class
			if (not self.moveToMeleeRange) then
				if (GetDistance(self.target) <= 27) and (IsInLineOfSight(self.target)) and (not script_target:hasDebuff('Frost Nova') and not script_target:hasDebuff('Frostbite')) then
					if (IsMoving()) and (IsInLineOfSight(self.target)) then
						StopMoving();
						return;
					end
				end
			end

			-- stop when we get close enough to target and we are a hunter class
			if (HasSpell("Raptor Strike")) then
				if (GetDistance(self.target) <= 30) and (IsInLineOfSight(self.target)) and (not script_target:hasDebuff('Frost Nova') and not script_target:hasDebuff('Frostbite')) then
					if (IsMoving()) and (IsInLineOfSight(self.target)) then
						StopMoving();
						return;
					end
				end
			end

			-- stop when we get close enough to target and we are a melee class
			if (GetDistance(self.target) <= 4) and (GetHealthPercentage(self.target) > 30) and (not script_target:hasDebuff('Frost Nova') and not script_target:hasDebuff('Frostbite')) then
				if (IsMoving()) and (IsInLineOfSight(self.target)) then
					StopMoving();
					return;
				end
			end

			self.message = "Moving to target...";

			if (script_rogue.useThrow) and (not IsInCombat())
				and (not HasBuff(localObj, "Stealth")) then
				if (GetDistance(self.target) <= 25) and (GetDistance(self.target) >= 7) and (IsInLineOfSight(self.target)) then
					if (IsMoving()) then
						StopMoving();
					end
				end
			end

			if (not IsInCombat()) and (HasSpell("Stealth")) and (script_rogue.alwaysStealth) and (script_rogue.useStealth) and (not HasBuff(localObj, "Stealth")) and (IsSpellOnCD("Stealth")) then
				self.waitTimer = GetTimeEX() + 250;
				self.message = "Waiting for stealth cooldown...";
				if (IsMoving()) then
					StopMoving();
					return;
				end
			script_path.savedPos['time'] = GetTimeEX();
			return;
			end

			-- force rogue stealth
			if (not IsInCombat()) and (not script_checkDebuffs:hasPoison()) and (GetDistance(self.target) <= script_rogue.stealthRange) and (GetHealthPercentage(GetLocalPlayer()) > script_rogue.eatHealth) and (script_rogue.useStealth) and (HasSpell("Stealth")) and (not IsSpellOnCD("Stealth")) and (not HasBuff(localObj, "Stealth")) then
				if (CastSpellByName("Stealth")) then
					return;
				end
			end


			-- move to target...
			if (not self.raycastPathing) then

				if (self.moveToMeleeRange) and (GetDistance(self.target) > 2) then
					if (not self.adjustTickRate) then
						script_grind.tickRate = 50;
					end
					local moveBuffer = math.random(-1, 1);
					if (HasBuff(localObj, "Stealth")) or (HasBuff(localObj, "Prowl")) then
						moveBuffer = 0;
					end
					local x, y, z = GetPosition(self.target);
					if (not script_target:hasDebuff('Frost Nova') and not script_target:hasDebuff('Frostbite')) then
						if (MoveToTarget(x+moveBuffer, y+moveBuffer, z)) then
							self.waitTimer = GetTimeEX() + 100;
						else
							if (GetDistance(self.target) <= 2) and (not script_target:hasDebuff('Frost Nova') and not script_target:hasDebuff('Frostbite')) then
								if (IsMoving()) and (IsInLineOfSight(self.target)) then
									StopMoving();
									return;
								end
							end
						end
					end
				elseif (GetDistance(self.target) > 27 or not IsInLineOfSight(self.target)) and (not script_target:hasDebuff('Frost Nova') and not script_target:hasDebuff('Frostbite')) then
					if (not self.adjustTickRate) then
						script_grind.tickRate = 50;
					end
					local moveBuffer = math.random(-1, 1);
					if (HasBuff(localObj, "Stealth")) or (HasBuff(localObj, "Prowl")) then
						moveBuffer = 0;
					end
					local x, y, z = GetPosition(self.target);
					if (MoveToTarget(x+moveBuffer, y+moveBuffer, z)) then
						self.waitTimer = GetTimeEX() + 100;
					end
				end
				return;
			end


			if (self.raycastPathing) and (not HasDebuff(self.target, "Frost Nova")) then
				local tarDist = GetDistance(self.target);
				local cx, cy, cz = GetPosition(self.target);
				if (self.moveToMeleeRange) and (tarDist > 2) then
					script_pather:moveToTarget(cx, cy, cz);
					if (GetDistance(self.target) <= 2)and (not script_target:hasDebuff('Frost Nova') and not script_target:hasDebuff('Frostbite')) then
						if (IsMoving()) and (IsInLineOfSight(self.target)) then
							StopMoving();
							return;
						end
					end

				elseif (GetDistance(self.target) > 27) then
					script_pather:moveToTarget(cx, cy, cz);
					if (GetDistance(self.target) <= 27) and (not script_target:hasDebuff('Frost Nova') and not script_target:hasDebuff('Frostbite')) then
						if (IsMoving()) and (IsInLineOfSight(self.target)) then
							StopMoving();
							return;
						end
					end
				end
				return;
			end
		
		end

		if (IsInCombat()) and ( (script_grind.enemiesAttackingUs() >= 2 and GetHealthPercentage(GetLocalPlayer()) <= 75) or 
			(GetHealthPercentage(GetLocalPlayer()) <= 40) ) then
			if (HasSpell("Gift of the Naaru")) and (not IsSpellOnCD("Gift of the Naaru")) then
				if (not IsSpellOnCD("Gift of the Naaru")) then
					Cast("Gift of the Naaru");
					CastSpellByName("Gift of the Naaru");
					self.waitTimer = GetTimeEX() + 2000;
					return;
				end
			end
		end

		self.message = 'Attacking target...';
		script_debug.debugGrind = "Attacking the target";
		script_path:resetAutoPath();
		script_pather:resetPath();
		ResetNavigate();
		RunCombatScript(self.target);
		AutoAttack(self.target);

		-- Unstuck feature on valid "working" targets
		if (GetTarget() ~= 0 and GetTarget() ~= nil) then
			if (GetHealthPercentage(GetTarget()) < 98) then
				script_path:savePos(true); -- SAVE FOR UNSTUCK 
				script_debug.debugGrind = "Using unstuck feature";
			end
		end

		return;
	end

	-- Mount before pathing
	if (not IsMounted() and self.target ~= nil and self.target ~= 0 and IsOutdoors() and self.tryMountTime < GetTimeEX()) then
		if (IsMoving()) then StopMoving();
			return;
		end
		script_helper:useMount();
		self.tryMountTime = GetTimeEX() + 10000;
		return;
	end

	-- When no valid targets around, run auto pathing
	if (not IsInCombat() and (IsUsingNavmesh() or self.raycastPathing)) then
		script_debug.debugGrind = "no valid enemy, auto pathing";
		self.message = script_path:autoPath();
	end

	if (not IsUsingNavmesh() and not self.raycastPathing) then
		script_debug.debugGrind = "not using nav or raycast pathing - walk path";
		self.message = "Navigating the walk path..."; Navigate();
	end
end

function script_grind:turnfOffLoot(reason)
	self.skipReason = reason;
	self.skipLoot = true;
	self.bagsFull = true;
end

function script_grind:turnfOnLoot()
	self.skipLoot = false;
	self.bagsFull = false;
end

function script_grind:restOn()
	self.shouldRest = true;
end

function script_grind:restOff()
	self.shouldRest = false;
end