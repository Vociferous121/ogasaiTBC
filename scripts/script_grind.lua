script_grind = {
	isSetup = false, grindSetupLoaded = include("scripts\\script_grindSetup.lua"), grindTimersLoaded = include("scripts\\script_grindTimers.lua"),
helperLoaded = include("scripts\\script_helper.lua"), targetLoaded = include("scripts\\script_target.lua"), pathLoaded = include("scripts\\script_path.lua"),  vendorScript = include("scripts\\script_vendor.lua"), grindExtra = include("scripts\\script_grindEX.lua"), grindMenu = include("scripts\\script_grindMenu.lua"), autoTalents = include("scripts\\script_talent.lua"), safeRessLoaded = include("scripts\\script_safeRess.lua"), info = include("scripts\\script_info.lua"), gather = include("scripts\\script_gather.lua"), rayPather = include("scripts\\script_pather.lua"), debugincluded = include("scripts\\script_debug.lua"), aggroincluded = include("scripts\\script_aggro.lua"), checkDebuffsLoaded = include("scripts\\script_checkDebuffs.lua"), unstuckLoaded = include("scripts\\script_unstuck.lua"), paranoidLoaded = include("scripts\\script_paranoid.lua"), grindEX2Loaded = include("scripts\\script_grindEX2.lua"), counterMenuLoaded = include("scripts\\script_counterMenu.lua"),
message = 'Starting the grinder...', alive = true, target = 0, targetTimer = GetTimeEX(), pullDistance = 30, waitTimer = 0, tickRate = 50, adjustTickRate = false, restHp = 60, restMana = 60, potHp = 15, potMana = 15, pause = true, stopWhenFull = false, hsWhenFull = false, shouldRest = false, skipMobTimer = 0, useMana = true, skipLoot = false, currentTime2 = 0, skipReason = 'user selected...', stopIfMHBroken = false, useVendor = true, sellWhenFull = true, repairWhenYellow = true, bagsFull = false, vendorRefill = false, refillMinNr = 5, unStuckPos = {}, unStuckTime = 0, jump = true, useMount = true, tryMountTime = 0, autoTalent = true, gather = true, raycastPathing = false, showRayMenu = false, useNavMesh = true, potUsed = false,
combatStatus = 0, -- 0 = in range, 1 = not in range
drawPath = false, useUnstuckScript = false, setLogoutTime = 30, currentTime = 0, timerSet = false, moveToMeleeRange = false, monsterKillCount = 0, moneyObtainedCount = 0, currentMoney = 0, dead = false, meleeDistance = 4.0,
}

function script_grind:setup()
	script_grindSetup:setup();
	self.isSetup = true;
end

function script_grind:draw()
	script_grindEX:draw();
end

function script_grind:setWaitTimer(ms) self.waitTimer = GetTimeEX() + (ms); end

function script_grind:run()
-- Run the setup function once
if not self.isSetup then script_grind:setup(); script_debug.debugGrind = "setup"; return; end
-- draw aggro circles
if script_aggro.drawAggro then script_aggro:drawAggroCircles(65); end
script_grindTimers:timers();
-- Load nav mesh
if self.useNavMesh then if script_path:loadNavMesh() then self.message = "Loading the oGasai maps..."; script_debug.debugGrind = "loading nav"; script_path.savedPos['time'] = GetTimeEX(); return; end end
-- show raycasting path
if not self.raycastPathing then script_grindEX.drawRaycastPath = false; end
-- set moeny obtained while grinder is running
self.moneyObtainedCount = GetMoney() - self.currentMoney;
-- if pause bot
if (self.pause) then script_path.savedPos['time'] = GetTimeEX(); return; end
-- set wait timers
if (self.waitTimer + self.tickRate > GetTimeEX() or IsCasting() or IsChanneling()) then return; end
-- adjust tick rate
if (not self.adjustTickRate) then if (not IsInCombat() or IsMoving()) then self.tickRate = 50; end if (not IsMoving() or IsInCombat()) then local tickRandom = math.random(342, 1521); self.tickRate = tickRandom; end end
-- face target in combat
if (IsInCombat()) and (not IsMoving()) then if (self.target ~= 0 and self.target ~= nil) and (not script_checkDebuffs:hasDisabledMovement()) then FaceTarget(self.target); end end
-- stop bot on stop movement debuffs
if (IsInCombat()) then if (script_checkDebuffs:hasDisabledMovement()) then script_path.savedPos['time'] = GetTimeEX(); script_grind.waitTimer = GetTimeEX() + 550; return; end
-- try to stop if we are stunned...
if (IsStunned(GetLocalPlayer())) then self.waitTimer = GetTimeEX() + 550; return; end end
-- Update min/max level if we level up
if (script_target.currentLevel ~= GetLevel(GetLocalPlayer())) then script_target.minLevel = script_target.minLevel + 1; script_target.maxLevel = script_target.maxLevel + 2; script_target.currentLevel = script_target.currentLevel + 1; end
-- Check: jump over obstacles
if (IsMoving()) and (not self.pause) then if (not IsInCombat()) then script_debug.debugGrind = "checking jump over obstacles"; end if (self.useUnstuckScript) then script_unstuck:drawChecks(); end if (self.useUnstuckScript) then if (not script_unstuck:pathClearAuto(2)) then script_unstuck:unstuck(); return true; end end script_pather:jumpObstacles(); end
-- Update node distance depending on if we are mounted or not
script_path:setNavNodeDist();
-- Check: Pause, Unstuck, Vendor, Repair, Buy and Sell etc
if (script_grindEX:doChecks()) then if (not IsInCombat()) and (not IsMoving()) then script_debug.debugGrind = "doing grindEX checks"; end return; end
-- reset saved pos sent to log
script_grindEX.sentToLog = false;
-- reset paranoia used
if (script_paranoid.paranoiaUsed) then	script_paranoid.paranoiaUsed = false; end
-- do paranoia
if (script_paranoid.useParanoia) and (not self.pause) and (script_paranoid.paranoidOn) and (not IsInCombat()) then if (script_paranoid:doParanoia()) then
-- stop moving on paranoia
if (script_paranoid.stopMovement) then if (IsMoving()) then StopMoving(); end end
-- we have used paranoia...
script_paranoid.paranoiaUsed = true;
self.message = "Paranoid turned on - player in range!";
-- logout if logout timer reached
if (script_paranoid.logoutOnParanoid) and (not IsInCombat()) and (script_paranoid.paranoiaUsed) then
-- logout timer reached then logout
if (self.currentTime / 1000 > ((self.currentTime2 / 1000) + self.setLogoutTime)) then StopBot(); Logout(); self.currentTime2 = GetTimeEX() *2; end end
-- reset unstuck timer
script_path.savedPos['time'] = GetTimeEX(); return; end end
-- reset paranoia
if (not script_paranoid:doParanoia()) then script_paranoid.logoutTimerSet = false; self.currentTime2 = self.currentTime + self.setLogoutTime; script_paranoid.paranoiaUsed = false; end
	-- target is dead
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
		self.monsterKillCount = self.monsterKillCount + 1;
		self.target = nil; 
		ClearTarget();
		return;
	end

	-- we are dead, but not ghost yet - wait timer
	if (not self.dead) and (IsDead(GetLocalPlayer())) and (not HasDebuff(GetLocalPlayer(), "Ghost")) then
		local randomReleaseTimer = math.random(1000, 6000);
		self.waitTimer = GetTimeEX() + randomReleaseTimer;
		self.message = "Waiting to release spirit";
		self.dead = true;
		return;
	end

	-- we are dead
	if (IsDead(GetLocalPlayer())) then
		
		if (self.alive) then
			self.alive = false;
			RepopMe();
			if (self.raycastPathing) then
				self.message = "Finding path to corpse...";
				self.waitTimer = GetTimeEX() + 1500;
			else self.waitTimer = GetTimeEX() + 350;
			end
		return;
		end
		self.message = script_helper:ress(GetCorpsePosition()); 
		script_path:savePos(false); -- SAVE FOR UNSTUCK
		script_grind.message = "Running to corpse...";
	
	return;
	else

	-- we are alive
		self.alive = true;
		self.dead = false;
		script_path:savePos(false); -- SAVE FOR UNSTUCK
	end

	-- Check: Rest 
	local hp = GetHealthPercentage(GetLocalPlayer());
	local mana = GetManaPercentage(GetLocalPlayer());

	-- Rest out of combat
	if (not IsInCombat() or (IsInCombat()) and script_info:nrTargetingMe() == 0) and (not script_target:isThereLoot()) then
		script_debug.debugGrind = "resting";
		self.potUsed = false;
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
		if (hp < self.potHp) and (not self.potUsed) then
			script_grind.waitTimer = GetTimeEX() + 100;
			if (script_helper:useHealthPotion()) then
				script_grind.waitTimer = GetTimeEX() + 1000;
				script_debug.debugGrind = "using potion";
				self.potUsed = true;
			end
		end
		if (mana < self.potMana and self.useMana) and (not self.potUsed) then
			script_grind.waitTimer = GetTimeEX() + 100;
			if (script_helper:useHealthPotion()) then
				script_grind.waitTimer = GetTimeEX() + 1000;
				script_debug.debugGrind = "using potion";
				self.potUsed = true;
			end
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

	-- stop rogue attack for stealth attacks....
	if (HasBuff(localObj, "Stealth")) and (GetUnitsTarget(GetLocalPlayer()) ~= 0) then
		StopAttack();
	end

	-- not bags are full then use or delete items
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
	if (script_target:isThereLoot() and not AreBagsFull() and not self.bagsFull) and (script_info.nrTargetingMe() == 0) then			
		self.message = "Looting... (enable auto loot in settings - grinder)";
		if (script_target:doLoot()) then
			script_grind.waitTimer = GetTimeEX() + 250;
			return true;
		end
	end

	-- stuck in combat
	if (IsInCombat()) and (not IsFleeing(GetUnitsTarget(GetLocalPlayer())) or GetHealthPercentage(GetUnitsTarget(GetLocalPlayer())) >= 100) and (script_info:nrTargetingMe() == 0) and (not HasDebuff(self.target, "Gouge")) and (not IsFleeing(self.target)) then
		self.message = "Stuck in combat... waiting...";
		if (IsMoving()) then
			StopMoving();
			return;
		end
	return;
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
		if (script_path.reachedHotspot) and (GetDistance(self.target) <= 27) and (not script_target:hasDebuff('Frost Nova') and not script_target:hasDebuff('Frostbite')) then
			if (IsMoving()) and (IsInLineOfSight(self.target)) then
				StopMoving();
				return;
			end
		end
	end
	
	-- stop when we have reached hotspot to attack target if we are a hunter class
	if (HasSpell("Raptor Strike")) then
		if (script_path.reachedHotspot)
			and (GetDistance(self.target) <= 30) and (IsInLineOfSight(self.target)) and (not script_target:hasDebuff('Frost Nova') and not script_target:hasDebuff('Frostbite')) then
			if (IsMoving()) and (IsInLineOfSight(self.target)) then
				StopMoving();
				return;
			end
		end
	end	
		
	-- Fetch a new target
	if (self.skipMobTimer < GetTimeEX()) or (IsInCombat() and script_info:nrTargetingMe() > 0) then	
			script_debug.debugGrind = "fetching a new target";
		if (script_path.reachedHotspot or (not IsUsingNavmesh() and not self.raycastPathing) or IsInCombat()) then
			local targetGUID = script_target:getTarget();
			self.target = GetGUIDTarget(targetGUID);
			if (GetTarget() ~= self.target) then
				if (self.moveToMeleeRange and not IsMoving()) or (IsInCombat()) then
					UnitInteract(self.target);
				end
				if (not IsMoving() or IsInCombat()) then
					AutoAttack(self.target);
				end
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

		if (script_checkDebuffs:hasDisabledMovement()) then
			return;
		end

		script_debug.debugGrind = "attack valid target";
		if (GetDistance(self.target) < self.pullDistance and IsInLineOfSight(self.target)) and (not IsMoving() or GetDistance(self.target) <= self.meleeDistance-.5) then
			-- stop movement when we reach target
			if (not script_target:hasDebuff('Frost Nova') and not script_target:hasDebuff('Frostbite')) then
				if (IsMoving()) and (IsInLineOfSight(self.target)) then
					StopMoving();
					return;
				end
			end

			-- face target
			if (not IsMoving()) and (not script_checkDebuffs:hasDisabledMovement()) then
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
if (HasSpell("Raptor Strike")) then if (GetDistance(self.target) <= 30) and (IsInLineOfSight(self.target)) and (not script_target:hasDebuff('Frost Nova') and not script_target:hasDebuff('Frostbite')) then if (IsMoving()) and (IsInLineOfSight(self.target)) then StopMoving(); return; end end end
-- stop when we get close enough to target and we are a melee class
if (GetDistance(self.target) <= self.meleeDistance) and (GetHealthPercentage(self.target) > 30) and (not script_target:hasDebuff('Frost Nova') and not script_target:hasDebuff('Frostbite')) then if (IsMoving()) and (IsInLineOfSight(self.target)) then StopMoving(); return true; end end
			self.message = "Moving to target...";
--wait for always rogue stealth
if (not IsInCombat()) and (HasSpell("Stealth")) and (script_rogue.alwaysStealth) and (script_rogue.useStealth) and (not HasBuff(localObj, "Stealth")) and (IsSpellOnCD("Stealth")) and (not script_target:isThereLoot()) then self.message = "Waiting for stealth cooldown..."; if (IsMoving()) then StopMoving(); return true; end script_path.savedPos['time'] = GetTimeEX(); self.waitTimer = GetTimeEX() - self.tickRate; return; end
-- rogue throw
if (script_rogueEX:stopForThrow()) then
	return;
end
-- rogue stealth
if (HasSpell("Stealth")) and (not HasBuff(localObj, "Stealth")) then
	if (script_rogueEX:forceStealth()) then
		return;
	end
end
-- sprint
if (HasSpell("Sprint")) and (not IsSpellOnCD("Sprint")) then
	if (script_rogueEX:useSprint()) then
		return;
	end
end

-- move to target...
if (not self.raycastPathing) and (not IsCasting()) and (not IsChanneling()) then if (self.moveToMeleeRange) and (GetDistance(self.target) > self.meleeDistance) then if (not self.adjustTickRate) then script_grind.tickRate = 50; end local x, y, z = GetPosition(self.target); if (not script_target:hasDebuff('Frost Nova') and not script_target:hasDebuff('Frostbite')) then if (MoveToTarget(x, y, z)) then if (IsMoving()) then self.waitTimer = GetTimeEX() + 350; end else if (GetDistance(self.target) <= self.meleeDistance) and (not script_target:hasDebuff('Frost Nova') and not script_target:hasDebuff('Frostbite')) then if (IsMoving()) and (IsInLineOfSight(self.target)) then StopMoving(); return; end end end end elseif (GetDistance(self.target) > 27 or not IsInLineOfSight(self.target)) and (not script_target:hasDebuff('Frost Nova') and not script_target:hasDebuff('Frostbite')) then if (not self.adjustTickRate) then script_grind.tickRate = 50; end local x, y, z = GetPosition(self.target); if (MoveToTarget(x, y, z)) then if (IsMoving()) then self.waitTimer = GetTimeEX() + 350; end end end return; end
if (self.raycastPathing) and (not IsCasting()) and (not IsChanneling()) and (not HasDebuff(self.target, "Frost Nova")) then local tarDist = GetDistance(self.target); local cx, cy, cz = GetPosition(self.target); if (self.moveToMeleeRange) and (tarDist > self.meleeDistance) then
script_grind.tickRate = 50; script_pather:moveToTarget(cx, cy, cz); if IsMoving() then self.waitTimer = GetTimeEX() + 550; end if (GetDistance(self.target) <= self.meleeDistance) and (not script_target:hasDebuff('Frost Nova') and not script_target:hasDebuff('Frostbite')) then if (IsMoving()) and (IsInLineOfSight(self.target)) then StopMoving(); return; end end elseif (GetDistance(self.target) > 27) then script_grind.tickRate = 50; script_pather:moveToTarget(cx, cy, cz); if IsMoving() then self.waitTimer = GetTimeEX() + 550; end if (GetDistance(self.target) <= 27) and (not script_target:hasDebuff('Frost Nova') and not script_target:hasDebuff('Frostbite')) then if (IsMoving()) and (IsInLineOfSight(self.target)) then StopMoving(); return; end end end return; end end
--gift of naruu
if (IsInCombat()) and ( (script_info:nrTargetingMe() >= 2 and GetHealthPercentage(GetLocalPlayer()) <= 75) or (GetHealthPercentage(GetLocalPlayer()) <= 40) ) then if (HasSpell("Gift of the Naaru")) and (not IsSpellOnCD("Gift of the Naaru")) then if (not IsSpellOnCD("Gift of the Naaru")) then Cast("Gift of the Naaru"); CastSpellByName("Gift of the Naaru"); self.waitTimer = GetTimeEX() + 2000; return true; end end end

	local localHealth = GetHealthPercentage(GetLocalPlayer());
	local localMana = GetManaPercentage(GetLocalPlayer());

	if (not IsInCombat()) and (not IsMoving() and (script_info:nrTargetingMe() == 0) and script_rogue.useBandage and localHealth <= script_rogue.eatHealth and localHealth > 35 and not HasDebuff(localObj, "Recently Bandaged")) or ( (script_info:nrTargetingMe() == 0) and (localHealth <= self.restHp) ) then
		if (IsMoving()) then
			StopMoving();
			return;
		end
	return;
	end
if (script_info:nrTargetingMe() == 0) and ( (localMana <= script_grind.restMana and script_grind.useMana) or (localHealth <= script_grind.restHp) ) then
		return;
	end
		self.message = 'Attacking target...';
		script_debug.debugGrind = "Attacking the target";
		script_path:resetAutoPath();
		script_pather:resetPath();
		ResetNavigate();
		RunCombatScript(self.target);
		local creatureType = GetCreatureType(GetUnitsTarget(GetLocalPlayer()));
if (not IsMoving() or IsInCombat()) and ( (not HasBuff(localObj, "Stealth")) or (script_rogue.pickpocketUsed) or (HasBuff(localObj, "Stealth") and not strfind("Humanoid", creatureType) and not strfind("Undead", creatureType) and (script_rogue.usePickPocket) )) then AutoAttack(self.target); self.waitTimer = GetTimeEX() + 200; end
-- Unstuck feature on valid "working" targets
if (GetTarget() ~= 0 and GetTarget() ~= nil) then 
if (GetHealthPercentage(GetTarget()) < 98) then script_path:savePos(true);
-- SAVE FOR UNSTUCK
script_debug.debugGrind = "Using unstuck feature"; end end return true; end
-- Mount before pathing
	if (not IsMounted() and self.target ~= nil and self.target ~= 0 and IsOutdoors() and self.tryMountTime < GetTimeEX()) then if (IsMoving()) then StopMoving(); return; end script_helper:useMount(); self.tryMountTime = GetTimeEX() + 10000; return; end

	-- When no valid targets around, run auto pathing
	if (not IsInCombat() and (IsUsingNavmesh() or self.raycastPathing)) then script_debug.debugGrind = "no valid enemy, auto pathing"; self.message = script_path:autoPath(); script_grind.tickRate = 50; if (IsMoving() and not IsMounted() and not HasBuff(localObj, "Sprint")) then script_grind.waitTimer = GetTimeEX() + 500; end end

if (not IsUsingNavmesh() and not self.raycastPathing) then script_debug.debugGrind = "not using nav or raycast pathing - walk path"; self.message = "Navigating the walk path..."; Navigate(); end end
function script_grind:turnfOffLoot(reason) self.skipReason = reason; self.skipLoot = true; self.bagsFull = true; end function script_grind:turnfOnLoot() self.skipLoot = false; self.bagsFull = false; end function script_grind:restOn() self.shouldRest = true; end function script_grind:restOff() self.shouldRest = false; end