script_paladin = {
	version = '0.1',
	message = 'Paladin Combat',
	palaExtra = include("scripts\\combat\\script_paladinEX.lua"),
	drinkMana = 50,
	eatHealth = 50,
	isSetup = false,
	waitTimer = 0,
	healHealth = 55,
	bopHealth = 20,
	lohHealth = 8,
	consecrationMana = 50,
	aura = " ",
	blessing = 0,
	useRotation = false,
	sealTimer = 0,
}

function script_paladin:draw()

end

function script_paladin:setTimers(miliseconds)

	self.waitTimer = GetTimeEX() + (miliseconds);
	script_grind.waitTimer = GetTimeEX() + (miliseconds);

end

function script_paladin:setup()

	self.waitTimer = GetTimeEX();
	self.sealTimer = GetTimeEX();
	script_paladinEX:setup();
	script_grind.moveToMeleeRange = true;

	self.isSetup = true;
end

function script_paladin:run(targetObj)

	if(not self.isSetup) then
		script_paladin:setup();
		return;
	end

	local localObj = GetLocalPlayer();
	local localMana = GetManaPercentage(localObj);
	local localHealth = GetHealthPercentage(localObj);
	local localLevel = GetLevel(localObj);

	-- Pre Check
	if (IsChanneling() or IsCasting() or self.waitTimer > GetTimeEX()) then
		return;
	end

	if (targetObj == 0) then
		targetObj = GetTarget();
	end

	local targetGUID = GetTargetGUID(targetObj);

	-- gift of naaru
	if (IsInCombat()) and ( (script_grindEX2.enemiesAttackingUs() >= 2 and GetHealthPercentage(GetLocalPlayer()) <= 75)
		or (GetHealthPercentage(GetLocalPlayer()) <= 40) ) then
		if (HasSpell("Gift of the Naaru")) and (not IsSpellOnCD("Gift of the Naaru")) then
			if (not IsSpellOnCD("Gift of the Naaru")) then
				Cast("Gift of the Naaru");
				CastSpellByName("Gift of the Naaru");
				script_paladin:setTimers(1550);
				return true;
			end			
		end
	end

	--Valid Enemy
	if (targetObj ~= 0 and targetObj ~= nil) then
	
		-- Cant Attack dead targets
		if (IsDead(targetObj)) then
			targetObj = 0;
			self.target = 0;
			return;
		end

		if (not CanAttack(targetObj)) then
			return;
		end
		
		targetHealth = GetHealthPercentage(targetObj);

		--Opener
		if (not IsInCombat()) then
			-- Auto Attack
			if (GetDistance(targetObj) < 40) then
				UnitInteract(targetObj);
				AutoAttackTarget(targetObj); end
			
			-- Opener
	
			-- Check: Exorcism
			if (GetCreatureType(targetObj) == "Demon" or GetCreatureType(targetObj) == "Undead") then
				if (GetDistance(targetObj) < 30 and HasSpell('Exorcism') and not IsSpellOnCD('Exorcism')) then
					if (Cast('Exorcism', targetGUID)) then
						script_paladin:setTimers(1550);
						self.message = "Pulling with Exocism...";
						return true;
					end
				end
			end

			-- cast seal of Rightneoussness if we dont have seal of the crusader
			if (not HasSpell('Seal of the Crusader') and localMana > 10) then
				if (GetDistance(targetObj) < 15 and not script_paladinEX:isBuff("Seal of Righteousness")) then
					if (not IsSpellOnCD("Seal of Righteousness")) and (self.sealTimer < GetTimeEX()) then
						if (not CastSpellByName('Seal of Righteousness')) then
							script_paladin:setTimers(1550);
						end
					end
				end 
			end

			-- cast seal of crusader so we can use judgement
			if (not script_target:hasDebuff("Judgement of the Crusder") and GetDistance(targetObj) < 15 and not script_paladinEX:isBuff("Seal of the Crusader")) and (localMana >= 20) then
				script_paladin:setTimers(1550);
				if (not IsSpellOnCD("Seal of the Crusader")) then
					if (not CastSpellByName('Seal of the Crusader')) then
						script_paladin:setTimers(1550);
					end
				end
			end 

			-- use judgement when we have seal of crusader
			if (GetDistance(targetObj) < 10  and script_paladinEX:isBuff('Seal of the Crusader') and not IsSpellOnCD('Judgement') and HasSpell('Judgement')) and (localMana >= 15) then
				if (CastSpellByName('Judgement')) then
					script_paladin:setTimers(2050);
					return true;
				end
			end

			-- use judgement when we have seal of righteousness
			if (GetDistance(targetObj) < 10  and script_paladinEX:isBuff('Seal of the Righteousness') and not IsSpellOnCD('Judgement') and HasSpell('Judgement')) and (localMana >= 45) and (GetHealthPercentage(targetObj) >= 10) then
				if (CastSpellByName('Judgement')) then
					script_paladin:setTimers(2050);
					return true;
				end
			end

			-- Check: Melee range
			-- If too far away move to the target then stop
			if (GetDistance(targetObj) > 5) and (not self.useRotation) then 
				if (script_grind.combatStatus ~= nil) then
					script_grind.combatStatus = 1;
				end
				MoveToTarget(targetObj); 
				return; 
			elseif (self.useRotation) then
				if (script_grind.combatStatus ~= nil) then
					script_grind.combatStatus = 0;
				end
				if (not IsMoving()) then
					FaceTarget(targetObj);
				end
				AutoAttack(targetObj);
			end
			
			return;

		-- Combat
		else	

			-- Check: Melee range
			-- If too far away move to the target then stop
			if (GetDistance(targetObj) > 5) and (not self.useRotation) then 
				if (script_grind.combatStatus ~= nil) then
					script_grind.combatStatus = 1;
				end
				local ax, ay, az = GetPosition(targetObj); 
				Move(ax, ay, az);
				return; 
			elseif (self.useRotation) then
				if (script_grind.combatStatus ~= nil) then
					script_grind.combatStatus = 0;
				end
				
			end 
			if (not IsMoving()) then
				FaceTarget(targetObj);
			end
			AutoAttack(targetObj);
			UnitInteract(targetObj);

			-- Check: Use Lay of Hands
			if (localHealth < self.lohHealth and HasSpell('Lay on Hands') and not IsSpellOnCD('Lay on Hands')) then 
				if (Cast('Lay on Hands', targetGUID)) then 
					script_paladin:setTimers(1550);
					self.message = "Cast Lay on Hands...";
					return true;
				end
			end
		
			-- Buff with Blessing
			if (self.blessing ~= 0 and HasSpell(self.blessing)) then
				if (localMana > 10 and not script_paladinEX:isBuff(self.blessing)) then
					if (Buff(self.blessing, localObj)) then
						script_paladin:setTimers(1550);
						return true;
					end
				end
			end
			
			-- Check: Divine Protection if BoP on CD
			if(localHealth < self.bopHealth and not HasDebuff(localObj, 'Forbearance')) then
				if (HasSpell('Divine Shield') and not IsSpellOnCD('Divine Shield')) then
					if (CastSpellByName('Divine Shield')) then
						script_paladin:setTimers(1550);
						self.message = "Cast Divine Shield...";
						return true;
					end
				elseif (HasSpell('Divine Protection') and not IsSpellOnCD('Divine Protection')) then
					if (CastSpellByName('Divine Protection')) then
						script_paladin:setTimers(1550);
						self.message = "Cast Divine Protection...";
						return true;
					end
				elseif (HasSpell('Blessing of Protection') and not IsSpellOnCD('Blessing of Protection')) then
					if (CastSpellByName('Blessing of Protection')) then
						script_paladin:setTimers(1550);
						self.message = "Cast Blessing of Protection...";
						return true;
					end
				end
			end

			-- Check: Heal ourselves if below heal health or we are immune to physical damage
			if (localHealth < self.healHealth or 
				((script_paladinEX:isBuff('Blessing of Protection') or script_paladinEX:isBuff('Divine Protection')) and localHealth < 90) ) and (localMana >= 10) then 

				-- Check: Stun with HoJ before healing if available
				if (GetDistance(targetObj) < 5 and HasSpell('Hammer of Justice') and not IsSpellOnCD('Hammer of Justice')) then
					if (Cast('Hammer of Justice', targetGUID)) then
						script_paladin:setTimers(1550);
						return true;
					end
				end
				
				if (Buff('Holy Light', localObj)) then 
					script_paladin:setTimers(4050);
					self.message = "Healing: Holy Light...";
					return true;
				end
			end

			-- Check: If we are in meele range, do meele attacks
			if (GetDistance(targetObj) <= 5) then
				if (script_paladinEX:meleeAttack(GetTargetGUID(targetObj))) then
					return true;
				end
			end
			
	
		end
	end
end

function script_paladin:rest()

	if (not self.isSetup) then
		script_paladin:setup();
		return true;
	end


	if (self.waitTimer > GetTimeEX() or IsCasting() or IsChanneling()) then
		return;
	end

	local localObj = GetLocalPlayer();
	local localMana = GetManaPercentage(localObj);
	local localHealth = GetHealthPercentage(localObj);

	-- Set aura
	if (self.aura ~= 0 and not IsMounted()) then
		if (not HasBuff(localObj, self.aura) and HasSpell(self.aura)) then
			if (CastSpellByName(self.aura)) then
				script_paladin:setTimers(1550);
				return true;
			end
		end
	end

	-- Buff with Blessing
	if (self.blessing ~= 0 and HasSpell(self.blessing) and not IsMounted()) then
		if (localMana > 10 and not HasBuff(localObj, self.blessing)) then
			if (Buff(self.blessing, localObj)) then
				script_paladin:setTimers(1550);
				return true;
			end
		end
	end
	
	-- Update rest values
	if (script_grind.restHp ~= 0) then
		self.eatHealth = script_grind.restHp;
	end

	if (script_grind.restMana ~= 0) then
		self.drinkMana = script_grind.restMana;
	end

	-- Heal up: Holy Light
	if (localMana > 20 and localHealth < 70 and HasSpell('Holy Light')) then
		if (not Buff('Holy Light', localObj)) then
			script_paladin:setTimers(1550);
			self.message = "Healing: Holy Light...";
		end
		script_grind:restOn();
		return true;
	end

	-- Heal up: Flash of Light
	if (localMana > 10 and localHealth < 90 and HasSpell('Flash of Light')) then
		if (not Buff('Flash of Light', localObj)) then
			script_paladin:setTimers(1550);
			self.message = "Healing: Flash of Light...";
		end
		script_grind:restOn();
		return true;
	end

	--Eat and Drink
	if (not IsDrinking() and localMana < self.drinkMana) and (not IsInCombat()) then
		if (IsMoving()) then
			StopMoving();
			script_grind:restOn();
			return true;
		end

		if(script_helper:drinkWater()) then
			script_paladin:setTimers(1550);
			script_grind:restOn();
			return true;
		end
	end

	if (not IsEating() and localHealth < self.eatHealth) and (not IsInCombat()) then	
		if (IsMoving()) then
			StopMoving();
			script_grind:restOn();
			return true;
		end
		
		if(script_helper:eat()) then
			script_paladin:setTimers(1550);
			script_grind:restOn();
			return true;
		end
	end

	if(localMana < self.drinkMana or localHealth < self.eatHealth) then
		if (IsMoving()) then
			StopMoving();				
		end
		script_grind:restOn();
		return true;
	end

	if(IsDrinking() and localMana < 98) then
		script_grind:restOn();
		return true;
	end

	if(IsEating() and localHealth < 98) then
		script_grind:restOn();
		return true;
	end
	
	script_grind:restOff();
	return false;
end

function script_paladin:menu()
	if (CollapsingHeader('[Paladin - Retribution')) then
		local wasClicked = false;
		Text('Aura and Blessing options:');
		self.aura = InputText("Aura", self.aura);
		self.blessing = InputText("Blessing", self.blessing);
		Separator();
		Text('HP percent to heal in combat:');
		self.healHealth = SliderFloat("HIC", 1, 99, self.healHealth);
		Text('Lay on Hands below HP percent');
		self.lohHealth = SliderFloat("LoH", 1, 99, self.lohHealth);
		Text('BoP below HP percent');
		self.bopHealth = SliderFloat("BoP", 1, 99, self.bopHealth);
	end
end