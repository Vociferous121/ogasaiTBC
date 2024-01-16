script_rogue = {
	message = 'Rogue Combat',
	eatHealth = 50,
	isSetup = false,
	waitTimer = 0,
	useStealth = true,
	useThrow = false,
	mainhandPoison = "Instant Poison",
	offhandPoison = "Instant Poison",
	useRotation = false,
	stealthRange = 100,
	cpGenerator = "Sinister Strike",
	cpGeneratorCost = 45,
	stealthOpener = "Sinister Strike",
	riposteActionBarSlot = 8,
	alwaysStealth = true,
	usePickPocket = true,
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

}

function script_rogue:setup()

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

	if (HasSpell("Riposte")) then
		self.cpGeneratorCost = 40;
	end

	if (self.cpGenerator == "Sinister Strike") then
		self.cpGeneratorCost = 45;
	end

	if (not HasSpell("Stealth")) then
		alwaysStealth = false;
	end

	if (not HasSpell("Pick Pocket")) then
		usePickPocket = false;
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

	local localObj = GetLocalPlayer();
	local localEnergy = GetEnergy(localObj);
	local localHealth = GetHealthPercentage(localObj);
	local targetHealth = GetHealthPercentage(targetObj);

	-- Pre Check
	if (self.waitTimer > GetTimeEX() + script_grind.tickRate or IsCasting() or IsChanneling()) then
		return;
	end

	if (IsInCombat()) then
		local tickRandom = math.random(232, 1014);
		script_grind.tickRate = tickRandom;
	end

	local targetGUID = GetTargetGUID(targetObj);

	-- Set pull range
	if (not self.useThrow) then
		script_grind.pullDistance = 4;
	elseif (not self.useThrow) then
		script_grind.pullDistance = 25;
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

		if (not IsInCombat()) and (HasSpell("Stealth")) and (script_rogue.alwaysStealth) and (script_rogue.useStealth) and (not HasBuff(localObj, "Stealth")) and (IsSpellOnCD("Stealth")) and (not script_target:isThereLoot()) then
			self.message = "Waiting for stealth cooldown...";
			if (IsMoving()) then
				StopMoving();
				return;
			end
			script_path.savedPos['time'] = GetTimeEX();
		return;
		end


		-- cast stealth
		if (not IsInCombat()) and (script_rogue.useStealth) and (HasSpell("Stealth")) and (not IsSpellOnCD("Stealth")) and (not HasBuff(localObj, "Stealth")) and (not script_target:isThereLoot()) then
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
			if (self.usePickPocket) and (not self.pickpocketUsed) and (GetDistance(targetObj) <= 5) then
				if (IsMoving()) then
					StopMoving();
					return;
				end
			end
			if (GetHealthPercentage(targetObj) >= 100) and (strfind("Humanoid", creatureType) or strfind("Undead", creatureType)) and (HasBuff(localObj, "Stealth")) and (HasSpell("Pick Pocket")) and (GetDistance(targetObj) < 5) and (self.useStealth) and (not IsSpellOnCD("Pick Pocket")) and (not IsInCombat()) and (not self.pickpocketUsed) then
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
			if (GetDistance(targetObj) < 5) and (self.useStealth and HasSpell(self.stealthOpener) and HasBuff(localObj, "Stealth")) and (not IsInCombat()) and (GetUnitsTarget(GetLocalPlayer()) ~= 0) and (not IsSpellOnCD(self.stealthOpener)) and ( (self.usePickPocket and self.pickpocketUsed) or (not self.usePickPocket) or (GetHealthPercentage(self.target) < 100) or (not strfind("Humanoid", creatureType) or not strfind("Undead", creatureType)) ) then
					if (not script_grind.adjustTickRate) then
						script_grind.tickRate = 50;
					end
				if (not CastSpellByName(self.stealthOpener)) then
					local x, y, z = GetPosition(GetUnitsTarget(GetLocalPlayer()));
					self.waitTimer = GetTimeEX() + 1250;
					script_grind.waitTimer = GetTimeEX() + 1250;
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
			if (GetDistance(targetObj) < 4) then
				if (not self.useStealth or not HasBuff(localObj, "Stealth")) and (localEnergy >= self.cpGeneratorCost) and (HasSpell(self.cpGenerator)) and (not IsSpellOnCD(self.cpGenerator)) and ( (self.usePickPocket and self.pickpocketUsed) or (not self.usePickPocket) or (GetHealthPercentage(self.target) < 100) or (not strfind("Humanoid", creatureType) or not strfind("Undead", creatureType)))then
					if (not CastSpellByName(self.cpGenerator)) then
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

		if (IsInCombat()) then
			self.pickpocketUsed = false;
		end

		-- now in combat 
		-- START OF COMBAT PHASE	
	
		else	

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
				if (localHealth < targetHealth and localHealth < 35) then
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
						return true;
					end 
				end
			end


	-- start of combat in melee range

			-- Check: If we are in meele range
			if (GetDistance(targetObj) < script_grind.meleeDistance) then 

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
				if (self.useSlice) and (cp < 5) and (cp > 0) and (HasSpell('Slice and Dice')) and (not IsSpellOnCD("Slice and Dice")) then 
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
				if (self.useExposeArmor) and (cp == self.exposeArmorStacks) and (not HasDebuff(targetObj, "Expose Armor")) and (not HasDebuff(targetObj, "Sunder Armor")) then
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
				if (self.useRupture) and (cp == self.ruptureStacks) and (not HasDebuff(targetObj, "Rupture")) then
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

	--Eat 
	if (not IsInCombat()) and (not IsEating() and localHealth <= self.eatHealth) then
		script_debug.debugCombat = "rest eat";
		ClearTarget();
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
				script_rogue:setTimers(1550);
				script_grind:restOn();
			end
		return;
		end
	return true;
	end

	if (IsEating()) and (HasSpell("Stealth")) and (not IsSpellOnCD("Stealth")) and (self.useStealth) and (not script_target:isThereLoot()) then
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

	script_grind:restOff();
	return false;
end

function script_rogue:menu()

	if (CollapsingHeader("Rogue Combat Menu")) then

		local wasClicked = false;
		Text("Melee Distance To Target    ");
		SameLine();
		wasClicked, self.useThrow = Checkbox("Use Throw", self.useThrow);

		script_grind.meleeDistance = SliderFloat("Melee Distance", 0, 5, script_grind.meleeDistance);

		-- show use stealth button
		if (HasSpell("Stealth")) then
			Separator();
			wasClicked, self.useStealth = Checkbox("Use Stealth", self.useStealth);

			-- if use stealth show stealth options
			if (self.useStealth) then
				SameLine();

				wasClicked, self.alwaysStealth = Checkbox("Always Stealth", self.alwaysStealth);

				if (HasSpell("Pick Pocket")) then
					SameLine();
					wasClicked, self.usePickPocket = Checkbox("Pick Pocket", self.usePickPocket);
				end

				Text("Stealth Range To Target");
				self.stealthRange = SliderInt("(yds)", 5, 100, self.stealthRange);
				Separator();

			end
		end

		-- sprint
		if (HasSpell("Sprint")) then
			if (not self.useStealth) then
				SameLine();
			end
			wasClicked, self.useSprint = Checkbox("Sprint To Target", self.useSprint);
		end

		if (HasSpell("Poisons")) and (HasSpell("Envenom")) then
			SameLine();
			wasClicked, self.useEnvenom = Checkbox("Use Envenom", self.useEnvenom);
		end

		-- feint
		if (HasSpell("Feint")) and (GetNumPartyMembers() >= 1) then
			SameLine();
			wasClicked, self.useFeint = Checkbox("Use Feint", self.useFeint);
		end

		-----------------------------------

		-- slice and dice
		if (HasSpell("Slice and Dice")) then
			Separator();
			wasClicked, self.useSlice = Checkbox("Slice & Dice", self.useSlice);
		end
		
		-- expose armor
		if (HasSpell("Expose Armor")) then
			SameLine();
			wasClicked, self.useExposeArmor = Checkbox("Expose Armor", self.useExposeArmor);
		end
		
		-- rupture
		if (HasSpell("Rupture")) then
			SameLine();
			wasClicked, self.useRupture = Checkbox("Rupture", self.useRupture);
		end

		-- combo point menu
		if (CollapsingHeader("|+| Combo Point Generator")) then
			Text("Combo Point ability");
			script_rogue.cpGenerator = InputText("CPA", script_rogue.cpGenerator);
			Text("Energy cost of CP-ability");
			script_rogue.cpGeneratorCost = SliderInt("Energy", 20, 50, script_rogue.cpGeneratorCost);
		end
			
		-- stealth opener menu
		if (HasSpell("Stealth")) then
			if(CollapsingHeader("|+| Stealth Ability Opener")) then
				Text("Stealth ability opener");
				script_rogue.stealthOpener = InputText("STO", script_rogue.stealthOpener);
			end
		end

		-- poisons menu
		if (GetLevel(GetLocalPlayer()) >= 20) and (HasSpell("Poisons")) then
			if (CollapsingHeader("|+| Posion Options")) then
				wasClicked, self.usePoisons = Checkbox("Use Poisons", self.usePoisons);
				Text("Poison on Main Hand");
				self.mainhandPoison = InputText("PMH", self.mainhandPoison);
				Text("Poison on Off Hand");
				self.offhandPoison = InputText("POH", self.offhandPoison);
			end
		end

		-- riposte menu
		if (HasSpell("Riposte")) then
			if (CollapsingHeader("|+| Riposte Skill Options")) then
				Text("Action Bar Slots 1 - 12");
				script_rogue.riposteActionBarSlot = InputText("RS", script_rogue.riposteActionBarSlot);	-- riposte
			end
		end
		
		-- envenom
		if (HasSpell("Envenom")) and (self.usePoisons) and (self.useEnvenom) then
			if (CollapsingHeader("|+| Envenom Options")) then
				Text("Use Envenom Below Target Health Percent");
				self.envenomHealth = SliderInt("ENVH", 0, 25, self.envenomHealth);
				Text("Name Of Poison Applied To Target");
				self.poisonName = InputText("Poison Name", self.poisonName);
			end
		end

		-- expose armor menu
		if (HasSpell("Expose Armor")) and (self.useExposeArmor) then
			if (CollapsingHeader("|+| Expose Armor Options")) then
				Text("Expose Armor Stacks On Target");
				self.exposeArmorStacks = SliderInt("EAXS", 0, 5, self.exposeArmorStacks);
			end
		end

		-- rupture menu
		if (HasSpell("Rupture")) and (self.useRupture) then
			if (CollapsingHeader("|+| Rupture Options")) then
				Text("Combo Points To Use Rupture");
				self.ruptureStacks = SliderInt("RUPS", 0, 5, self.ruptureStacks);
			end
		end


	end
end