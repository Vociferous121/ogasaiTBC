script_grind = {
	isSetup = false,
	helperLoaded = include("scripts\\script_helper.lua"),
	targetLoaded = include("scripts\\script_target.lua"),
	pathLoaded = include("scripts\\script_path.lua"), 
	vendorScript = include("scripts\\script_vendor.lua"),
	grindExtra = include("scripts\\script_grindEX.lua"),
	grindMenu = include("scripts\\script_grindMenu.lua"),
	autoTalents = include("scripts\\script_talent.lua"),
	info = include("scripts\\script_info.lua"),
	gather = include("scripts\\script_gather.lua"),
	rayPather = include("scripts\\script_pather.lua"),
	debugincluded = include("scripts\\script_debug.lua"),
	aggroincluded = include("scripts\\script_aggro.lua"),
	message = 'Starting the grinder...',
	alive = true,
	target = 0,
	targetTimer = GetTimeEX();
	pullDistance = 30,
	waitTimer = 0,
	tickRate = 550,
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
	skipReason = 'user selected...',
	stopIfMHBroken = false,
	useVendor = false,
	sellWhenFull = true,
	repairWhenYellow = true,
	bagsFull = false,
	vendorRefill = true,
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
	combatStatus = 0 -- 0 = in range, 1 = not in range
}

function script_grind:setup()

	SetPVE(true);
	SetAutoLoot();
	DrawNavMeshPath(true);

	self.waitTimer = GetTimeEX();
	self.skipMobTimer = GetTimeEX();
	self.unStuckTime = GetTimeEX();
	self.tryMountTime = GetTimeEX();

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
	self.isSetup = true;

	script_rogue.useRotation = false;
	script_mage.useRotation = false;
	script_druid.useRotation = false;
	script_paladin.useRotation = false;
	script_warrior.useRotation = false;
	script_shaman.useRotation = false;
	script_hunter.useRotation = false;
	script_priest.useRotation = false;
	script_warlock.useRotation = false;
end

function script_grind:draw() 
	-- Draw everything
	script_grindEX:draw();
end

function script_grind:run()
	-- Run the setup function once
	if (not self.isSetup) then
		script_grind:setup();
		script_debug.debugGrind = "setup";
		return;
	end

	if (script_aggro.drawAggro) then
		script_aggro:drawAggroCircles(65);
	end

	if (not self.adjustTickRate) then
	
		if (not IsInCombat()) then
			self.tickRate = 50;
		end
		if (not IsMoving()) and (IsInCombat()) then
			self.tickRate = 650;
		end
	end

	-- Load nav mesh
	if (self.useNavMesh) then
		if (script_path:loadNavMesh()) then
			self.message = "Loading the oGasai maps...";
			script_debug.debugGrind = "loading nav";
			return;
		end
	end

	-- Update min/max level if we level up
	if (script_target.currentLevel ~= GetLevel(GetLocalPlayer())) then
		script_target.minLevel = script_target.minLevel + 1;
		script_target.maxLevel = script_target.maxLevel + 1;
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
	else
		--StopJump();	
	end

	-- Check: jump over obstacles
	if (IsMoving()) then

		if (not IsInCombat()) then
			script_debug.debugGrind = "checking jump over obstacles";
		end

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

	-- Check: wait for timer
	if(self.waitTimer > GetTimeEX()) then
		return;
	end

	self.waitTimer = GetTimeEX() + self.tickRate;

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
		if (self.alive) then
			script_debug.debugGrind = "we are dead repopme";
			self.alive = false;
			RepopMe();
			self.message = "Releasing spirit...";
			self.waitTimer = GetTimeEX() + 5000;
		return;
		end

		self.message = script_helper:ress(GetCorpsePosition()); 
		script_path:savePos(false); -- SAVE FOR UNSTUCK
		self.waitTimer = GetTimeEX() + 500;
		script_debug.debugGrind = "using script_helper:ress";
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
	if (self.useMana) then
		script_debug.debugGrind = "stand up after resting";
		if (hp > 98 and mana > 98 and not IsStanding()) then
			--StopMoving();
			self.shouldRest = false;
		return;

		else
			if (IsDrinking() or IsEating()) then
				script_debug.debugGrind = "we should drink";
				self.shouldRest = true;
			end
		end
	else
		if (hp > 98 and not IsStanding()) then
			--StopMoving();
			self.shouldRest = false;
		return;
		else
			if (IsEating()) then
			script_debug.debugGrind = "we should eat";
				self.shouldRest = true;
			end
		end
	end

	-- Rest out of combat
	if (not IsInCombat() or script_info:nrTargetingMe() == 0) then
		script_debug.debugGrind = "resting";
		if ((not IsSwimming()) and (not IsFlying())) then
			RunRestScript();
		else
			self.shouldRest = false;
		end
		if (self.shouldRest) then 
			script_path:savePos(true); -- SAVE FOR UNSTUCK
			self.message = "Resting..."; self.waitTimer = GetTimeEX() + 2500; return; end
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

	-- Loot
	if (script_target:isThereLoot() and not IsInCombat() and not AreBagsFull() and not self.bagsFull) then
		self.message = "Looting... (enable auto loot)";
		script_target:doLoot();
	script_debug.debugGrind = "trying to loot";
	return;
	end

	-- Wait for group members
	if (GetNumPartyMembers() > 2) then

		script_debug.debugGrind = "waiting for group memebrs";

		if (script_followEX:getTarget() ~= 0) then
			local targetGUID = script_followEX:getTarget();
			self.target = GetGUIDTarget(targetGUID);
			--UnitInteract(self.target);
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

	if (IsInCombat()) and (GetPet() == 0) and (GetUnitsTarget(GetLocalPlayer()) == 0) then
		return;
	end
	
	if (HasSpell("Fireball") or HasSpell("Smite") or HasSpell("Shadowbolt") or HasSpell("Raptor Strike")) then
		if (script_pather.reachedHotspot) and (not IsInCombat()) and (GetDistance(self.target) <= 27) and (IsInLineOfSight(self.target)) then
			if (IsMoving()) then
				StopMoving();
			end
		end
	end

	if (script_pather.reachedHotspot) and (not IsInCombat()) and (GetDistance(self.target) <= 5) then
		if (IsMoving()) then
			StopMoving();
		end
	end

	-- Fetch a new target
	if (self.skipMobTimer < GetTimeEX() or (IsInCombat() and script_info:nrTargetingMe() > 0)) then	
			script_debug.debugGrind = "fetching a new target";
		if (script_path.reachedHotspot or (not IsUsingNavmesh() and not self.raycastPathing) or IsInCombat()) then
			local targetGUID = script_target:getTarget();
			self.target = GetGUIDTarget(targetGUID);
			if (GetTarget() ~= self.target) then
				--UnitInteract(self.target);
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
	if (IsSwimming()) then
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

	if (IsInCombat()) and (GetPet() == 0) and (GetUnitsTarget(GetLocalPlayer()) == 0) then
		return;
	end
	
	-- If we have a valid target attack it
	if (self.target ~= 0 and self.target ~= nil) then
		script_debug.debugGrind = "attack valid target";
		if (GetDistance(self.target) < self.pullDistance and IsInLineOfSight(self.target)) and (not IsMoving() or GetDistance(self.target) <= 5) then
			FaceTarget(self.target);
	
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

			if (IsInCombat()) and (GetPet() == 0) and (GetUnitsTarget(GetLocalPlayer()) == 0) then
				script_debug.debugGrind = "Stuck in combat - no target";
				return;
			end

			if (HasSpell("Fireball") or HasSpell("Smite") or HasSpell("Shadowbolt") or HasSpell("Raptor Strike")) then
				if (GetDistance(self.target) <= 27) and (IsInLineOfSight(self.target)) then
					if (IsMoving()) then
						StopMoving();
					end
				end
			end
			if (GetDistance(self.target) <= 5) and (GetHealthPercentage(self.target) > 30) then
				if (IsMoving()) then
					StopMoving();
				end
			end

			self.message = "Moving to target...";
			if (not self.raycastPathing) then
				if (not HasSpell("Fireball") or not HasSpell("Shadowbolt") or not HasSpell("Smite") or not HasSpell("Raptor Strike")) and (GetDistance(self.target) >= 6) then
					MoveToTarget(self.target);
				elseif (GetDistance(self.target) > 27) or (not IsInLineOfSight(self.target)) then
					MoveToTarget(self.target);
				end
				return;
			end
			if (self.raycastPathing) then
				local tarPos = GetPosition(self.target);
				local cx, cy, cz = GetPosition(self.target);
				if (not HasSpell("Fireball") or not HasSpell("Shadowbolt") or not HasSpell("Smite") or not HasSpell("Raptor Strike")) and (tarPos >= 6) then
					script_pather:moveToTarget(cx, cy, cz);
				elseif (GetDistance(self.target) > 27) or (not IsInLineOfSight(self.target)) then
					script_pather:moveToTarget(cx, cy, cz);
				end
				return;
			end
		
		end
		
		-- Loot
		if (script_target:isThereLoot() and not IsInCombat() and not AreBagsFull() and not self.bagsFull) then
			self.message = "Looting... (enable auto loot)";
			script_target:doLoot();
			script_debug.debugGrind = "trying to loot";
		return;
		end

		self.message = 'Attacking target...';
		script_debug.debugGrind = "Attacking the target";
		script_path:resetAutoPath();
		script_pather:resetPath();
		ResetNavigate();
		RunCombatScript(self.target)
		

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
		if (IsMoving()) then StopMoving(); return; end
		script_helper:useMount(); self.tryMountTime = GetTimeEX() + 10000; return;
	end

	-- When no valid targets around, run auto pathing
	if (not IsInCombat() and (IsUsingNavmesh() or self.raycastPathing)) then
		script_debug.debugGrind = "no valid enemy, auto pathing";
		self.message = script_path:autoPath(); end

	if (not IsUsingNavmesh() and not self.raycastPathing) then
		script_debug.debugGrind = "not using nav or raycast pathing - walk path";
		self.message = "Navigating the walk path..."; Navigate(); end
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