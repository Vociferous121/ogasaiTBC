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

}

function script_rogue:setup()

	self.waitTimer = GetTimeEX();

	DEFAULT_CHAT_FRAME:AddMessage('script_rogue: loaded...');

--set backstab as opener
	if (GetLevel(GetLocalPlayer()) < 10) then
		self.stealthOpener = "Backstab";
	end

	if (not HasSpell("Ambush")) and (HasSpell("Garrote")) and (GetLevel(GetLocalPlayer()) >= 10) then
		self.stealthOpener = "Garrote";
	end

	if (HasSpell("Ambush")) and (not HasSpell("Riposte") or HasSpell("Ghostly Strike")) then
		self.stealthOpener = "Ambush";
	end

	if (HasSpell("Riposte")) and (not HasSpell("Cheap Shot")) then
		self.stealthOpener = "Garrote";
	end

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
	if (IsChanneling() or IsCasting() or self.waitTimer > GetTimeEX()) then
		return;
	end

	local targetGUID = GetTargetGUID(targetObj);

	-- Set pull range
	if (not self.useThrow) then
		script_grind.pullDistance = 4;
	elseif (not self.useThrow) then
		script_grind.pullDistance = 25;
	end

	--Valid Enemy
	if (targetObj ~= 0) then
		
		-- Cant Attack dead targets
		if (IsDead(targetObj)) then
			return;
		end
		
		if (not CanAttack(targetObj)) then
			return;
		end
		
		-- Dismount
		DismountEX();

		-- cast stealth
		if (not IsInCombat()) and (script_rogue.useStealth) and (HasSpell("Stealth")) and (not IsSpellOnCD("Stealth")) and (not HasBuff(localObj, "Stealth")) then
			if (CastSpellByName("Stealth")) then
				return;
			end
		end

		if (not script_grind.adjustTickRate) and (GetDistance(self.target) > 4) or (IsMoving()) and (IsInCombat()) then
			script_grind.tickRate = 50;
		end

		-- Apply poisons 
		if (not IsInCombat()) then
			if (script_rogue:checkPoisons()) then
				script_debug.debugCombat = "applying poisons";
				return;
			end
		end

		-- set tick rate for script to run
		if (not script_grind.adjustTickRate) then
	
			local tickRandom = random(256, 311);
	
			if (IsMoving()) or (not IsInCombat()) or (IsFleeing(targetObj)) then
				script_grind.tickRate = 135;
			elseif (not IsInCombat()) and (not IsMoving()) and (not IsFleeing(targetObj)) then
				script_grind.tickRate = tickRandom
			elseif (IsInCombat()) and (not IsMoving())and (not IsFleeing(targetObj)) then
				script_grind.tickRate = tickRandom;
			end
		end

		-- try to stop if we are stunned...
		if (IsStunned(GetLocalPlayer())) then
			return;
		end

		-- cold blood
		if (HasSpell("Cold Blood")) and (not IsSpellOnCD("Cold Blood")) and (not localObj:HasBuff("Cold Blood")) and (not IsInCombat()) then
			if (CastSpellByName("Cold Blood")) then
				return;
			end
		end


		-- Combat
		if (not IsInCombat()) then

			-- Check: Use Stealth before oponer
			if (self.useStealth and HasSpell('Stealth')) and (not HasBuff(localObj, 'Stealth')) and (GetDistance(self.target) <= self.stealthRange) then
				script_debug.debugCombat = "using stealth";
				if (CastSpellByName('Stealth')) then
					return;
				end
			else
				-- Check: Use Throw	
				if (self.useThrow and script_rogue:hasThrow()) then
					if (IsSpellOnCD('Throw')) then
						script_debug.debugCombat = "using throw";
						self.waitTimer = GetTimeEX() + 4000;
						return;	
					end
					if (IsMoving()) then
						StopMoving();
						return;
					end
					if (Cast('Throw', targetGUID)) then 
						return;
					end 
					return;
				end
			end

			-- Open with stealth opener
			if (GetDistance(targetObj) <= 5 and self.useStealth and HasSpell(self.stealthOpener) and HasBuff(localObj, "Stealth")) then
				if (CastSpellByName(self.stealthOpener)) then
					self.waitTimer = GetTimeEX() + 1500;
					script_grind.waitTimer = GetTimeEX() + 1250;
					return true;
				end
			end

			-- Use CP generator attack 
			if (not self.useStealth) or (not HasBuff(localObj, "Stealth")) and (localEnergy >= self.cpGeneratorCost) and (HasSpell(self.cpGenerator)) then
				if (CastSpellByName(self.cpGenerator)) then
					self.waitTimer = GetTimeEX() + 1500;
					script_grind.waitTimer = GetTimeEX() + 1250;
					return true;
				end
			end

			if (not self.useRotation) then
				if (GetDistance(targetObj) > 6) then
					-- Set the grinder to wait for momvement
					if (script_grind.waitTimer ~= 0) then
						script_grind.waitTimer = GetTimeEX()+1250;
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

			local cp = GetComboPoints(localObj);

			-- If too far away move to the target then stop
			if (not self.useRotation) then
				if (GetDistance(targetObj) > 6) then 
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
				if (localHealth < targetHealth and localHealth < 50) then
					script_debug.debugCombat = "use evasion";
					CastSpellByName('Evasion');
					return; 
				end
			end

			-- Check: Kick Spells
			if (HasSpell('Kick')) then
			local name, subText, text, texture, startTime, endTime, isTradeSkill, castID, notInterruptible = UnitCastingInfo("target");
				if (name ~= nil) then
					script_debug.debugCombat = "use kick";
					if (Cast('Kick', targetGUID)) then 
						return;
					end 
				end
			end

			if (HasSpell('Kidney Shot')) then
			local name, subText, text, texture, startTime, endTime, isTradeSkill, castID, notInterruptible = UnitCastingInfo("target");
				if (name ~= nil) then
					if (cp >= 1) and (not IsSpellOnCD('Kidney Shot')) and (localEnergy >= 25) then	
						if (Cast('Kidney Shot', targetObj)) then
							return;
						end
					end
				end
			end

			-- Check: gouge Spells
			if (HasSpell('Gouge')) then
			local name, subText, text, texture, startTime, endTime, isTradeSkill, castID, notInterruptible = UnitCastingInfo("target");
				if (name ~= nil) then
					script_debug.debugCombat = "use gouge";
					if (Cast('Gouge', targetGUID)) then 
						return;
					end 
				end
			end


	-- start of combat in melee range

			-- Check: If we are in meele range
			if (GetDistance(targetObj) < 5) then 

				-- Auto attack
				if (not self.useRotation) then
					script_debug.debugCombat = "unit interact";
					--UnitInteract(targetObj);
				end

				-- Check: Use Riposte whenever we can
				if (HasSpell("Riposte")) and (script_rogue:canRiposte() and not IsSpellOnCD("Riposte")) and (localEnergy >= 10) then 
					if (Cast("Riposte", targetObj)) then
						self.waitTimer = GetTimeEX() + 1500;
						return;					
					end
				end

				if (GetNumPartyMembers() >= 1) and (HasSpell("Feint")) and (script_grindEX2:isTargetingMe(targetObj))
					and (not IsSpellOnCD("Feint")) and (localEnergy >= 20) then
					CastSpellByName("Feint");
					return true;
				end

				if (HasSpell("Ghostly Strike")) and (not IsSpellOnCD("Ghostly Strike")) and (localEnergy >= 40) then
					if (CastSpellByName("Ghostly Strike")) then
						return true;
					end
				end

				
				local add = script_info:addTargetingMe(targetObj);

				if (add ~= nil and HasSpell('Blade Flurry') and not IsSpellOnCD('Blade Flurry')) then
					if (GetDistance(add) < 5) then
					script_debug.debugCombat = "blade flurry";
						CastSpellByName("Blade Flurry");
						return;
					end
				end

				if (script_info:nrTargetingMe() >= 3) then
					if (HasSpell('Adrenaline Rush') and not IsSpellOnCD('Adrenaline Rush')) then
						script_debug.debugCombat = "adrenaline rush";
						CastSpellByName('Adrenaline Rush');
					end
				end

				-- Use Riposte when we can
				if(script_rogue:canRiposte() and HasSpell("Riposte")) then
				script_debug.debugCombat = "Use riposte";
					CastSpellByName("Riposte");
					return;
				end

				-- Eviscerate
				if (HasSpell('Eviscerate') and ((cp == 5) or targetHealth <= cp*10)) then 
					if (localEnergy >= 35) then
						script_debug.debugCombat = "eviscerate";
						CastSpellByName('Eviscerate');
						return;
					else
						script_debug.debugCombat = "saving energy for eviscerate";
						-- save energy
						return;
					end
				end 

				-- Keep Slice and Dice up when 1-4 CP
				if (cp < 5 and cp > 0 and HasSpell('Slice and Dice') and targetHealth > 50) then 
					-- Keep Slice and Dice up
					if (not HasBuff(localObj, 'Slice and Dice') and targetHealth > 50 and localEnergy >= 25) then
						script_debug.debugCombat = "slice and dice";

						CastSpellByName('Slice and Dice'); 
					end 
				end

				-- Sinister Strike
				if (localEnergy >= self.cpGeneratorCost) then
					script_debug.debugCombat = "sinister strike";
					CastSpellByName(self.cpGenerator);
					script_grind.waitTimer = GetTimeEX() + 1250;
					self.waitTimer = GetTimeEX() + 1250;
				end 
			
			return;
			end
		return;
		end
	end
end

function script_rogue:rest()

	if(not self.isSetup) then script_rogue:setup(); return; end

	local localObj = GetLocalPlayer();
	local localHealth = GetHealthPercentage(localObj);

	-- Update rest values
	if (script_grind.restHp ~= 0) then
		self.eatHealth = script_grind.restHp;
	end

	--Eat 
	if (not IsInCombat()) and (not IsEating() and localHealth < self.eatHealth) then
		script_debug.debugCombat = "rest eat";
		if (IsMoving()) then
			StopMoving();
			script_grind:restOn();
			return true;
		end
		
		if (not IsInCombat()) then
			if(script_helper:eat()) then
				script_debug.debugCombat = "use script_helper:eat";
				script_grind.waitTimer = GetTimeEX() + 1500;
				script_grind:restOn();
				return true;
			end
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

		wasClicked, self.useStealth = Checkbox("Use Stealth", self.useStealth);

		SameLine();

		wasClicked, self.useThrow = Checkbox("Use Throw", self.useThrow);

		if (self.useStealth) then
			Text("Stealth Range To Target");
			self.stealthRange = SliderInt("(yds)", 5, 100, self.stealthRange);
		end

		if (self.useStealth) then
			self.useThrow = false;
		end
		if (self.useThrow) then
			self.useStealth = false;
		end

		if (CollapsingHeader("|+| Combo Point Generator")) then
			Text("Combo Point ability");
			script_rogue.cpGenerator = InputText("CPA", script_rogue.cpGenerator);
			Text("Energy cost of CP-ability");
			script_rogue.cpGeneratorCost = SliderInt("Energy", 20, 50, script_rogue.cpGeneratorCost);
		end
			
		if (HasSpell("Stealth")) then
			if(CollapsingHeader("|+| Stealth Ability Opener")) then
				Text("Stealth ability opener");
				script_rogue.stealthOpener = InputText("STO", script_rogue.stealthOpener);
			end
		end

		if (GetLevel(GetLocalPlayer()) >= 20) then
			if (CollapsingHeader("|+| Posion Options")) then
				Text("Poison on Main Hand");
				self.mainhandPoison = InputText("PMH", self.mainhandPoison);
				Text("Poison on Off Hand");
				self.offhandPoison = InputText("POH", self.offhandPoison);
			end
		end

		if (HasSpell("Riposte")) then
			if (CollapsingHeader("|+| Riposte Skill Options")) then
				Text("Action Bar Slots 1 - 12");
				script_rogue.riposteActionBarSlot = InputText("RS", script_rogue.riposteActionBarSlot);	-- riposte
			end
		end
	end
end