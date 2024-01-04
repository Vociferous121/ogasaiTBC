script_rogue = {
	version = '0.1',
	message = 'Rogue Combat',
	eatHealth = 50,
	isSetup = false,
	timer = 0,
	useStealth = true,
	useThrow = false,
	mainhandPoison = "Instant Poison",
	offhandPoison = "Instant Poison",
	useRotation = false,
	stealthRange = 100,
}

function script_rogue:setup()
	self.timer = GetTimeEX();
	DEFAULT_CHAT_FRAME:AddMessage('script_rogue: loaded...');
	self.isSetup = true;
end

function script_rogue:canRiposte()
	for i=1,132 do 
		local texture = GetActionTexture(i); 
		if texture ~= nil and string.find(texture,"Ability_Warrior_Challange") then
			local isUsable, _ = IsUsableAction(i); 
			if (isUsable == 1 and not IsSpellOnCD(Riposte)) then 
				return true; 
			end 
		end 
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
		self.timer = GetTimeEX() + 6000; 
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
		self.timer = GetTimeEX() + 6000;  
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

	if(not self.isSetup) then script_rogue:setup(); return; end

	local localObj = GetLocalPlayer();
	local localEnergy = GetEnergy(localObj);
	local localHealth = GetHealthPercentage(localObj);
	local targetHealth = GetHealthPercentage(targetObj);

	-- Pre Check
	if (IsChanneling() or IsCasting() or self.timer > GetTimeEX()) then
		return;
	end

	local targetGUID = GetTargetGUID(targetObj);

	-- Set pull range
	if (not self.useThrow) then
		script_grind.pullDistance = 4;
	else
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

		if (not IsInCombat()) and (script_rogue.useStealth) and (HasSpell("Stealth")) and (not IsSpellOnCD("Stealth")) then
			if (CastSpellByName("Stealth")) then
				return;
			end
		end

		if (not script_grind.adjustTickRate) and (GetDistance(self.target) > 4) then
			script_grind.tickRate = 50;
		end
		
		-- Combat
		if (IsInCombat()) then

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


			-- Check: If we are in meele range
			if (GetDistance(targetObj) < 5) then 

				-- Auto attack
				if (not self.useRotation) then
					script_debug.debugCombat = "unit interact";
					UnitInteract(targetObj);
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

				local cp = GetComboPoints(localObj);

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
				if (localEnergy >= 45) then
					script_debug.debugCombat = "sinister strike";
					CastSpellByName('Sinister Strike');
					script_grind.waitTimer = GetTimeEX() + 1250;
				end 
			
				return;
			end

			
			
		-- Opener
		else	


			-- Apply poisons 
			if (script_rogue:checkPoisons()) then
				script_debug.debugCombat = "applying poisons";
				return;
			end

			-- Check: Use Stealth before oponer
			if (self.useStealth and HasSpell('Stealth') and not HasBuff(localObj, 'Stealth')) and (GetDistance(self.target) <= self.stealthRange) then
				script_debug.debugCombat = "using stealth";
				if (CastSpellByName('Stealth')) then
					return;
				end
			else
				-- Check: Use Throw	
				if (self.useThrow and script_rogue:hasThrow()) then
					if (IsSpellOnCD('Throw')) then
						script_debug.debugCombat = "using throw";
						self.timer = GetTimeEX() + 4000;
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
					UnitInteract(targetObj);
					script_debug.debugCombat = "unit interact";
	
					if (localEnergy >= 45) and (GetDistance(self.target) <= 7) then
						if (not HasSpell("Cheap Shot")) and (HasSpell("BackStab")) then
							if (Cast("BackStab", self.target)) then
								self.waitTimer = GetTimeEX() + 500;
							end
						elseif (HasSpell("Cheap Shot")) then
							if (Cast("Cheap Shot", self.target)) then
								self.waitTimer = GetTimeEX() + 500;
							end
						else
							if (Cast('Sinister Strike', targetGUID)) then 
								script_grind.waitTimer = GetTimeEX() + 1250;
								script_debug.debugCombat = "sinister strike";
								return; 
							end
						end
					end
				end
			elseif (self.useRotation) then
				if (GetDistance(targetObj) < 7) and (localEnergy >= 45) then
					if (not HasSpell("Cheap Shot")) and (HasSpell("BackStab")) then
						if (Cast("BackStab", self.target)) then
							self.waitTimer = GetTimeEX() + 500;
						end
					elseif (HasSpell("Cheap Shot")) then
						if (Cast("Cheap Shot", self.target)) then
							self.waitTimer = GetTimeEX() + 500;
						end
					else
						if (Cast('Sinister Strike', targetGUID)) then 
							script_grind.waitTimer = GetTimeEX() + 1250;
							script_debug.debugCombat = "sinister strike";
							return; 
						end
					end
				end
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
	if (CollapsingHeader("[Rogue - Combat")) then

		Separator();

		Text('Pull options:');

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

		Separator();

		Text("Poison on Main Hand");
		self.mainhandPoison = InputText("PMH", self.mainhandPoison);
		Text("Poison on Off Hand");
		self.offhandPoison = InputText("POH", self.offhandPoison);
	end
end