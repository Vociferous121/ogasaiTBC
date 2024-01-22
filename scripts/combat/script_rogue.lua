script_rogue = {
	message = 'Rogue Combat',
	rogueEXLoaded = include("scripts\\combat\\script_rogueEX.lua"),
	eatHealth = 50,
	isSetup = false,
	waitTimer = 0,
	useStealth = false,
	useThrow = false,
	mainhandPoison = "Instant Poison",
	offhandPoison = "Instant Poison",
	useRotation = false,
	stealthRange = 100,
	cpGenerator = "Sinister Strike",
	cpGeneratorCost = 45,
	stealthOpener = "Sinister Strike",
	riposteActionBarSlot = 8,
	alwaysStealth = false,
	usePickPocket = false,
	pickpocketUsed = false,
	usePoisons = false,
	useSprint = true,
	useExposeArmor = false,
	useRupture = false,
	exposeArmorStacks = 2,
	ruptureStacks = 2,
	useSlice = true,
	useFeint = false,
	envenomHealth = 15,
	useEnvenom = false,
	poisonName = "Instant Poison",
	pickpocketMoney = 0,
	ppmoney = GetMoney(),
	ppVarUsed = false,
	useBandage = true,
	hasBandage = false,
	openerUsed = 0,
	randomizeCombat = true,
	randomCastCount = 96,

}

function script_rogue:setup()

	script_rogueEX:checkBandage();

	--set backstab as opener
	if (GetLevel(GetLocalPlayer()) < 10) then
		self.stealthOpener = "Backstab";
	end

	-- set garrote as opener
	if (not HasSpell("Ambush")) and (HasSpell("Garrote")) and (GetLevel(GetLocalPlayer()) >= 10) then
		self.stealthOpener = "Garrote";
	end

	-- set ambush as opener
	if (HasSpell("Ambush")) and (not HasSpell("Riposte") or HasSpell("Ghostly Strike")) then
		self.stealthOpener = "Ambush";
	end

	-- set garote as opener
	if (HasSpell("Riposte")) and (not HasSpell("Cheap Shot")) then
		self.stealthOpener = "Garrote";
	end

	-- set cheap shot as opener
	if (HasSpell("Cheap Shot")) and (not HasSpell("Ghostly Strike")) then
		self.stealthOpener = "Cheap Shot";
	end

	-- Set Hemorrhage as default CP builder if we have it
	if (HasSpell("Hemorrhage")) then
		self.cpGenerator = "Hemorrhage";
	end

	-- if we have sinister strike then set CP cost to 45
	if (self.cpGenerator == "Sinister Strike") then
		self.cpGeneratorCost = 45;
	end

	-- if we have riposte we can set sinister strike energy to 40
	if (HasSpell("Riposte")) then
		self.cpGeneratorCost = 40;
	end

	-- if we don't have stealth then don't wait for stealth
	if (not HasSpell("Stealth")) then
		self.alwaysStealth = false;
	end

	if (HasSpell("Pick Pocket")) then
		self.usePickPocket = true;
	end

	if (HasSpell("Sprint")) then
		self.useSprint = true;
	end

	local level = GetLevel(GetLocalPlayer());
	if (level == 10) then
		self.cpGeneratorCost = 43;
	end
	if (level >= 11) then
		self.cpGeneratorCost = 40;
	end
	if (HasSpell("Poisons")) then
		self.usePoisons = true;
	end
	if (GetNumPartyMembers() >= 1) then
		self.useFeint = true;
	end
	if (HasSpell("Envenom")) then
		self.useEnvenom = true;
	end
	if (HasSpell("Stealth")) then
		self.useStealth = true;
		self.alwaysStealth = true;
	end
	

	--self.waitTimer = GetTimeEX();

	script_grind.moveToMeleeRange = true;


	self.isSetup = true;
end

function script_rogue:canRiposte()
	local isUsable, _ = IsUsableAction(self.riposteActionBarSlot); 
	if (isUsable == 1 and not IsSpellOnCD("Riposte")) then 
		return true; 
	end 
	return false;
end


function script_rogue:checkPoisons()
	hasMainHandEnchant, _, _,  hasOffHandEnchant, _, _ = GetWeaponEnchantInfo();
	if (hasMainHandEnchant == nil and HasItem(self.mainhandPoison)) then 
		-- Check: Stop moving, sitting
		if (not IsStanding() or IsMoving()) then 
			StopMoving(); 
			return; 
		end 
		-- Check: Dismount
		if (IsMounted()) then DisMount(); return true; end
		-- Apply poison to the main-hand
		self.message = "Applying poison to main hand..."
		UseItem(self.mainhandPoison); 
		PickupInventoryItem(16);  
		self.waitTimer = GetTimeEX() + 6000; 
		return true;
	end
		
	if (hasOffHandEnchant == nil and HasItem(self.offhandPoison)) then
		-- Check: Stop moving, sitting
		if (not IsStanding() or IsMoving()) then 
			StopMoving(); 
			return; 
		end 
		-- Check: Dismount
		if (IsMounted()) then DisMount(); return true; end
		-- Apply poison to the off-hand
		self.message = "Applying poison to off hand..."
		UseItem(self.offhandPoison); 
		PickupInventoryItem(17); 
		self.waitTimer = GetTimeEX() + 6000;  
		return true; 
	end

	return false;
end

function script_rogue:hasThrow()
	local id, texture, checkRelic = GetInventorySlotInfo("RangedSlot")
	local durability, max = GetInventoryItemDurability(id);
	if (durability ~= nil) then
		if (durability > 0) then
			return true;
		end
	end
	return false;
end

function script_rogue:setTimers(miliseconds)
	
	self.waitTimer = GetTimeEX() + miliseconds;
	script_grind.waitTimer = GetTimeEX() + miliseconds;

end

function script_rogue:run(targetObj)

	if (not self.isSetup) then
		script_rogue:setup();
		return;
	end

	if (IsDead(GetLocalPlayer())) or (HasDebuff(GetLocalPlayer(), "Ghost")) then
		return;
	end

	local localObj = GetLocalPlayer();
	local localEnergy = GetEnergy(localObj);
	local localHealth = GetHealthPercentage(localObj);
	local targetHealth = GetHealthPercentage(targetObj);

	-- Pre Check
	if (self.waitTimer > GetTimeEX() + script_grind.tickRate or IsCasting() or IsChanneling()) then
		return;
	end

	if (script_info:nrTargetingMe() == 0) and (localHealth <= self.eatHealth) then
		return;
	end


	if (IsInCombat()) and (not script_grind.adjustTickRate) then
		local tickRandom = math.random(232, 514);
		script_grind.tickRate = tickRandom;
	end

	local targetGUID = GetTargetGUID(targetObj);

	-- Set pull range
	if (not self.useThrow) then
		script_grind.pullDistance = 4;
	elseif (not self.useThrow) then
		script_grind.pullDistance = 25;
	end

	rogueRandom = math.random(0, 100);
	rogueRandomCP = math.random(0, 5);

	if (IsInCombat()) and (GetHealthPercentage(GetLocalPlayer()) <= 10) and (script_info.nrTargetingMe() > 0) then
		script_grind.tickRate = 50;
	end

	--Valid Enemy
	if (targetObj ~= 0) and (not IsDead(GetLocalPlayer())) then

		-- Cant Attack dead targets
		if (IsDead(targetObj)) then
			return;
		end
		
		if (not CanAttack(targetObj)) then
			return;
		end
		
		-- Dismount
		DismountEX();

		-- wait for stealth cooldown
		if (not IsInCombat()) and (HasSpell("Stealth")) and (script_rogue.alwaysStealth) and (script_rogue.useStealth) and (not HasBuff(localObj, "Stealth")) and (IsSpellOnCD("Stealth")) and (not script_target:isThereLoot()) and (not script_checkDebuffs:hasPoison()) then
			self.message = "Waiting for stealth cooldown...";
			if (IsMoving()) then
				StopMoving();
				return;
			end
			script_path.savedPos['time'] = GetTimeEX();
		return;
		end


		-- cast stealth
		if (not IsInCombat()) and (script_rogue.useStealth) and (HasSpell("Stealth")) and (not IsSpellOnCD("Stealth")) and (not HasBuff(localObj, "Stealth")) and (not HasDebuff(localObj, "Faerie Fire")) and (not script_target:isThereLoot()) and (not script_checkDebuffs:hasPoison()) then
			if (CastSpellByName("Stealth")) then
				Jump();
				script_rogue:setTimers(1050);
				return;
			end
		end

		if (not script_grind.adjustTickRate) and (GetDistance(self.target) > script_grind.meleeDistance) or (IsMoving()) and (IsInCombat()) then
			script_grind.tickRate = 50;
		end

		-- Apply poisons 
		if (not IsInCombat()) and (self.usePoisons) then
			if (script_rogue:checkPoisons()) then
				script_rogue:setTimers(1050);
				script_debug.debugCombat = "applying poisons";
				return;
			end
		end

		-- try to stop if we are stunned...
		if (IsStunned(GetLocalPlayer())) then
			script_rogue:setTimers(550);
			return;
		end

		-- cold blood
		if (HasSpell("Cold Blood")) and (not IsSpellOnCD("Cold Blood")) and (not localObj:HasBuff("Cold Blood")) and (not IsInCombat()) then
			if (CastSpellByName("Cold Blood")) then
				script_rogue:setTimers(1050);
				return true;
			end
		end

		-- Combat
		if (not IsInCombat()) then

			-- Check: Use Stealth before oponer
			if (self.useStealth and HasSpell('Stealth')) and (not HasBuff(localObj, 'Stealth')) and (GetDistance(self.target) <= self.stealthRange) and (not IsSpellOnCD("Stealth")) then
				script_debug.debugCombat = "using stealth";
				if (CastSpellByName('Stealth')) then
					script_rogue:setTimers(1050);
					return true;
				end
			else
				-- Check: Use Throw	
				if (self.useThrow and script_rogue:hasThrow()) and (not IsSpellOnCD("Throw")) and (GetDistance(targetObj) <= 25) and (GetDistance(targetObj) >= 9) then
					if (IsSpellOnCD('Throw')) then
						script_debug.debugCombat = "using throw";
						script_rogue:setTimers(4000);
						return;	
					end
					if (IsMoving()) then
						StopMoving();
						return;
					end
					if (Cast('Throw', targetGUID)) then 
						script_rogue:setTimers(2550);
						return true;
					end 
					return;
				end
			end

			local creatureType = GetCreatureType(GetUnitsTarget(GetLocalPlayer()));

			if (not IsMoving()) and (not IsDead(targetObj)) and (GetHealthPercentage(targetObj) <= 99) then
				FaceTarget(GetUnitsTarget(GetLocalPlayer()));
			end

			if (self.usePickPocket) and (GetHealthPercentage(targetObj) >= 100) and (strfind("Humanoid", creatureType) or strfind("Undead", creatureType)) and (HasBuff(localObj, "Stealth")) and (HasSpell("Pick Pocket")) and (GetDistance(targetObj) < 5) and (self.useStealth) and (not IsSpellOnCD("Pick Pocket")) and (not IsInCombat()) and (not self.pickpocketUsed) then
			if (not script_grind.adjustTickRate) then
				script_grind.tickRate = 500;
			end
			CastSpellByName("Pick Pocket");
			self.ppmoney = GetMoney();
			self.ppVarUsed = false;
			self.pickpocketUsed = true;
			script_rogue:setTimers(500);
			end

			-- Open with stealth opener
			if (self.openerUsed < 2)
				and (GetDistance(targetObj) <= 5)
				and (self.useStealth and HasSpell(self.stealthOpener))
				and (HasBuff(localObj, "Stealth"))
				and (not IsInCombat())
				and (GetUnitsTarget(GetLocalPlayer()) ~= 0)
				and (not IsSpellOnCD(self.stealthOpener))
				and
( (self.usePickPocket and self.pickpocketUsed and (strfind("Humanoid", creatureType) or strfind("Undead", creatureType))) or (not self.usePickPocket) or (self.usePickPocket and (not strfind("Humanoid", creatureType) and not strfind("Undead", creatureType))) )
then
					if (not script_grind.adjustTickRate) then
						script_grind.tickRate = 50;
					end
					FaceTarget(targetObj);
				if (not CastSpellByName(self.stealthOpener)) then
					local x, y, z = GetPosition(GetUnitsTarget(GetLocalPlayer()));
					self.waitTimer = GetTimeEX() + 1250;
					script_grind.waitTimer = GetTimeEX() + 1250;
					FaceTarget(targetObj);
					self.openerUsed = self.openerUsed + 1;
					if (not self.useRotation) then
						local moveBuffer = random(-2, 2);
						if (Move(x+moveBuffer, y+moveBuffer, z)) then
						--	self.waitTimer = GetTimeEX() + 1250;
						--	script_grind.waitTimer = GetTimeEX() + 1250;
						end
					end
				end
			end

			-- Use CP generator attack 
			if (GetDistance(targetObj) <= 4) then
				if (self.openerUsed >= 2) or ( (not self.useStealth or not HasBuff(localObj, "Stealth")) and (localEnergy >= self.cpGeneratorCost) and (HasSpell(self.cpGenerator)) and (not IsSpellOnCD(self.cpGenerator)) and ( (self.usePickPocket and self.pickpocketUsed) or (not self.usePickPocket) or (self.usePickPocket and not self.pickpocketUsed and not (strfind("Humanoid", creatureType) or not strfind("Undead", creatureType))))) then
					if (not CastSpellByName(self.cpGenerator)) then
						FaceTarget(targetObj);
						script_rogue:setTimers(1050);
					end
				end
			end

			if (not self.useRotation) then
				if (GetDistance(targetObj) > script_grind.meleeDistance) then
					-- Set the grinder to wait for momvement
					if (script_grind.waitTimer ~= 0) then
						script_grind.waitTimer = GetTimeEX() + 1050;
					end
					script_debug.debugCombat = "moving to target";
					MoveToTarget(targetObj);
					return;
				else
					-- Auto attack
					--UnitInteract(targetObj);
					script_debug.debugCombat = "unit interact";
	
				end
			end

		-- now in combat 
		-- START OF COMBAT PHASE	
	
		else	

if (IsInCombat()) then
			self.pickpocketUsed = false;
			self.openerUsed = 0;
		end

			local cp = GetComboPoints(localObj);
			local tarDist = GetDistance(targetObj);

			if (self.ppmoney ~= GetMoney()) and (not self.ppVarUsed) and (IsInCombat()) then
				self.pickpocketMoney = self.pickpocketMoney + (GetMoney() - self.ppmoney);
				self.ppVarUsed = true;
			end
			if (IsInCombat()) then
				self.pickpocketUsed = false;
			end

			-- If too far away move to the target then stop
			if (not self.useRotation) then
				if (GetDistance(targetObj) > script_grind.meleeDistance) then 
					if (script_grind.combatStatus ~= nil) then
						script_grind.combatStatus = 1;
					end
					script_debug.debugCombat = "Moving to target";
					MoveToTarget(targetObj); 
					return; 
				else 
					if (script_grind.combatStatus ~= nil) then
						script_grind.combatStatus = 0;
					end
					script_debug.debugCombat = "Reached target and in combat - stop moving";
					if (IsMoving()) then 
						StopMoving(); 
					end 
				end 
			end

			-- Check: Use Evasion
			if (HasSpell('Evasion') and not IsSpellOnCD('Evasion')) then
				if (localHealth < targetHealth and localHealth < 35) or (script_info:nrTargetingMe() >= 2) then
					script_debug.debugCombat = "use evasion";
					if (not CastSpellByName('Evasion')) then
						script_rogue:setTimers(1050);
						return true;
					end 
				end
			end

			-- Check: Kick Spells
			if (HasSpell('Kick')) and (not IsSpellOnCD("Kick")) and (localEnergy >= 25) and (tarDist < 5) then
			local name, subText, text, texture, startTime, endTime, isTradeSkill, castID, notInterruptible = UnitCastingInfo("target");
				if (name ~= nil) then
					script_debug.debugCombat = "use kick";
					if (not Cast('Kick', targetGUID)) then 
						script_rogue:setTimers(1050);
						return true;
					end 
				end
			end

			if (HasSpell('Kidney Shot')) and (tarDist < 5) then
			local name, subText, text, texture, startTime, endTime, isTradeSkill, castID, notInterruptible = UnitCastingInfo("target");
				if (name ~= nil) then
					if (cp >= 1) and (not IsSpellOnCD('Kidney Shot')) and (localEnergy >= 25) then	
						if (not Cast('Kidney Shot', targetObj)) then
							script_rogue:setTimers(1050);
							return true;
						end
					end
				end
			end

			-- Check: gouge Spells
			if (HasSpell('Gouge')) and (not IsSpellOnCD("Gouge")) and (localEnergy >= 45) and (tarDist < 5) then
			local name, subText, text, texture, startTime, endTime, isTradeSkill, castID, notInterruptible = UnitCastingInfo("target");
				if (name ~= nil) then
					script_debug.debugCombat = "use gouge";
					if (not Cast('Gouge', targetGUID)) then 
						script_rogue:setTimers(1050);
						AutoAttack(targetObj);
						return true;
					end 
				end
			end
			

	-- start of combat in melee range

			-- Check: If we are in meele range
			if (GetDistance(targetObj) <= script_grind.meleeDistance+2) then 

				-- Auto attack
				if (not self.useRotation) and (not IsMoving()) then
					script_debug.debugCombat = "unit interact";
					UnitInteract(targetObj);
				end

				-- Check: Use Riposte whenever we can
				if (HasSpell("Riposte")) and (script_rogue:canRiposte() and not IsSpellOnCD("Riposte")) and (localEnergy >= 10) then 
					if (not CastSpellByName("Riposte")) then
						script_rogue:setTimers(1050);
						return true;					
					end
				end

				if (GetNumPartyMembers() >= 1) and (self.useFeint) and (HasSpell("Feint")) and (script_grindEX2:isTargetingMe(targetObj))
					and (not IsSpellOnCD("Feint")) and (localEnergy >= 20) and (not IsSpellOnCD("Feint")) then
					if (not CastSpellByName("Feint")) then
						script_rogue:setTimers(1050);
						return true;
					end
				end

				if (HasSpell("Ghostly Strike")) and (not IsSpellOnCD("Ghostly Strike")) and (localEnergy >= 40) and (not HasBuff(localObj, "Ghostly Strike")) then
					if (not CastSpellByName("Ghostly Strike")) then
						script_rogue:setTimers(1050);
						return true;
					end
				end

				
				local add = script_info:addTargetingMe(targetObj);

				if (add ~= nil and HasSpell('Blade Flurry') and not IsSpellOnCD('Blade Flurry')) and (localEnergy >= 25) then
					if (GetDistance(add) < 5) then
					script_debug.debugCombat = "blade flurry";
						if (not CastSpellByName("Blade Flurry")) then
							script_rogue:setTimers(1050);
							return true;
						end
					end
				end

				if (script_info:nrTargetingMe() >= 3) then
					if (HasSpell('Adrenaline Rush') and not IsSpellOnCD('Adrenaline Rush')) then
						script_debug.debugCombat = "adrenaline rush";
						if (not CastSpellByName('Adrenaline Rush')) then
							script_rogue:setTimers(1050);
							return true;
						end
					end
				end

				-- Use Riposte when we can
				if (script_rogue:canRiposte() and HasSpell("Riposte")) and (not IsSpellOnCD("Riposte")) and (localEnergy >= 10) then
				script_debug.debugCombat = "Use riposte";
					if (not CastSpellByName("Riposte")) then
						script_rogue:setTimers(1050);
						return true;
					end
				end

				-- Keep Slice and Dice up when 1-4 CP
				if (self.useSlice or (self.randomizeCombat and rogueRandom >= self.randomCastCount)) and ( (cp < 5 and cp > 0) or (self.randomizeCombat and cp == rogueRandomCP) ) and (HasSpell('Slice and Dice')) and (not IsSpellOnCD("Slice and Dice")) then 
					-- Keep Slice and Dice up
					if (not HasBuff(localObj, 'Slice and Dice') and targetHealth > 30 and localEnergy >= 25) then
						script_debug.debugCombat = "slice and dice";

						if (not CastSpellByName('Slice and Dice')) then
							script_rogue:setTimers(1050);
							return true;
						end
					end 
				end

				-- expose armor
				if (self.useExposeArmor or (self.randomizeCombat and rogueRandom >= self.randomCastCount)) and (cp == self.exposeArmorStacks or (self.randomizeCombat and cp == rogueRandomCP)) and (not HasDebuff(targetObj, "Expose Armor")) and (not HasDebuff(targetObj, "Sunder Armor")) and (GetHealthPercentage(targetObj) >= 30) then
					if (localEnergy >= 25) then
						if (not CastSpellByName("Expose Armor")) then
							script_rogue:setTimers(1050);
							return true;
						end
					else
						script_debug.debugCombat = "Saving energy for expose armor";
						return;
					end
				end
	
				-- rupture
				if (self.useRupture or (self.randomizeCombat and rogueRandom >= self.randomCastCount)) and (cp == self.ruptureStacks or (self.randomizeCombat and cp == rogueRandomCP)) and (not HasDebuff(targetObj, "Rupture")) and (GetHealthPercentage(targetObj) >= 30) then
					if (localEnergy >= 25) then
						if (not CastSpellByName("Rupture")) then
							script_rogue:setTimers(1050);
							return true;
						end
					else
						script_debug.debugCombat = "Saving energy for rupture";
						return;
					end
				end

				-- Eviscerate
				if (HasSpell('Eviscerate') and ((cp == 5) or targetHealth <= cp*10)) and (not IsSpellOnCD("Eviscerate")) then 
					if (localEnergy >= 35) then
						script_debug.debugCombat = "eviscerate";
						if (not CastSpellByName('Eviscerate')) then
							script_rogue:setTimers(1050);
							return true;
						end
					else
						script_debug.debugCombat = "saving energy for eviscerate";
						-- save energy
						return;
					end
				end 

				if (HasSpell("Envenom")) and (GetDebuffStacks(targetObj, self.poisonName) >= 3) and (GetHealthPercentage(targetObj) >= self.envenomHealth) and (not IsSpellOnCD("Envenom")) then
					if (localEnergy >= 35) then
						if (CastSpellByName("Envenom")) then
							script_rogue:setTimers(1050);
							return true;
						end
					else
						script_debug.debugCombat = "saving energy for envenom";
						return;
					end
				end

				-- Sinister Strike
				if (localEnergy >= self.cpGeneratorCost) and (not IsSpellOnCD(self.cpGenerator)) then
					script_debug.debugCombat = "sinister strike";
					if (not CastSpellByName(self.cpGenerator)) then
						script_rogue:setTimers(1050);
						return true;
					end
				end 
			
			end
		end
	end
return;
end

function script_rogue:rest()

	if(not self.isSetup) then
		script_rogue:setup();
		return;
	end

	local localObj = GetLocalPlayer();
	local localHealth = GetHealthPercentage(localObj);

	if (self.waitTimer > GetTimeEX()) then
		return;
	end

	-- Update rest values
	if (script_grind.restHp ~= 0) then
		self.eatHealth = script_grind.restHp;
	end

	script_rogueEX:checkBandage();

	-- if has bandage then use bandages
	if (not script_checkDebuffs:hasPoison()) and (not IsInCombat()) and (self.eatHealth >= 35) and (self.hasBandage) and (self.useBandage) and (localHealth < self.eatHealth) and (not HasDebuff(localObj, "Recently Bandaged")) and (not IsEating()) and (not IsDead(GetLocalPlayer())) then
		if (IsMoving()) then
			StopMoving();
			return true;
		end	
		script_grind:restOn();
		script_rogue:setTimers(1550);
		script_grind.tickRate = 1500;
		if (not script_helper:useBandage()) then
			script_rogue:setTimers(9550);
		end
		script_path.savedPos['time'] = GetTimeEX();
		
	script_rogue:setTimers(9500);
	return;	
	end

	--Eat 
	if (not IsCasting()) and (not IsChanneling()) and (not IsInCombat()) and (not IsEating()) and ( (localHealth <= self.eatHealth and not self.useBandage) or (localHealth < self.eatHealth) ) then
		script_debug.debugCombat = "rest eat";
		if (IsMoving()) then
			StopMoving();
			script_grind:restOn();
			return true;
		end
		
		if (not IsInCombat()) and (not IsEating()) then
			if (IsMoving()) then
				StopMoving();
				return true;
			end
			if (not script_helper:eat()) then
				script_debug.debugCombat = "use script_helper:eat";
				script_rogue:setTimers(550);
				script_grind:restOn();
			end
		return;
		end
	return true;
	end

	if (IsEating()) and (HasSpell("Stealth")) and (not IsSpellOnCD("Stealth")) and (self.useStealth) and (not script_target:isThereLoot()) and (not HasDebuff(localObj, "Faerie Fire")) and (not script_checkDebuffs:hasPoison()) then
		if (CastSpellByName("Stealth")) then
		script_rogue:setTimers(1550);
		return true;
		end
	end

	if (not IsInCombat()) and (localHealth < self.eatHealth) then
		if (IsMoving()) then
			StopMoving();				
		end
		script_grind:restOn();
		return true;
	end

	if (IsEating() and localHealth < 98) then
		script_debug.debugCombat = "eating... waiting for health";
		script_grind:restOn();
		return true;
	end

	if (IsEating() and localHealth < 95) then
		return;
	elseif (not IsStanding()) then
		local x, y, z = GetPosition(GetLocalPlayer());
		local mbuffer = math.random(-1, 1);
		Move(x+mbuffer, y+mbuffer, z)
		script_grind:restOff();
	end

	script_grind:restOff();
	return false;
end

