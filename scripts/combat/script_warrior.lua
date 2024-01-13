script_warrior = {
	version = '0.1',
	message = 'Warrior Combat',
	eatHealth = 50,
	isSetup = false,
	timer = 0,
	useCharge = true,
	useThrow = false,
	useRotation = false,
	meleeDistance = 3.5,
}

function script_warrior:setup()
	self.timer = GetTimeEX();

	script_grind.moveToMeleeRange = true;

	self.isSetup = true;
end

function script_warrior:hasThrow()

	local id, texture, checkRelic = GetInventorySlotInfo("RangedSlot")
	local durability, max = GetInventoryItemDurability(id);

	if (durability ~= nil) then
		if (durability > 0) then
			return true;
		end
	end

	return false;
end

function script_warrior:run(targetObj)

	if(not self.isSetup) then
		script_warrior:setup();
		return;
	end

	local localObj = GetLocalPlayer();
	local localRage = GetRage(localObj);
	local localHealth = GetHealthPercentage(localObj);
	local targetHealth = GetHealthPercentage(targetObj);

	-- Pre Check
	if (IsChanneling() or IsCasting() or self.timer > GetTimeEX()) then
		return;
	end

	if (targetObj == 0) then
		targetObj = GetTarget();
	end

	local targetGUID = GetTargetGUID(targetObj);

	-- Set pull range
	if (not HasSpell("Charge")) then
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
		
		-- Combat
		if (IsInCombat()) then

			if (not self.useRotation) then
				if (GetDistance(targetObj) <= self.meleeDistance) then
					if (IsMoving()) then
						StopMoving();
					end
				end
			end

			-- If too far away move to the target then stop
			if (not self.useRotation) then
				if (GetDistance(targetObj) > self.meleeDistance) then 
					if (script_grind.combatStatus ~= nil) then
						script_grind.combatStatus = 1;
					end
					if (GetDistance(targetObj) <= self.meleeDistance) then
						if (IsMoving()) then
							StopMoving();
						end
					end
					MoveToTarget(targetObj); 
					
					return; 

				else 
					if (script_grind.combatStatus ~= nil) then
						script_grind.combatStatus = 0;
					end
					if (IsMoving()) then 
						StopMoving(); 
					end 
				end 
			end

			-- Check: Keep Battle Shout up
			if (HasSpell("Battle Shout")) then 
				if (localRage >= 10 and not HasBuff(localObj, "Battle Shout")) then 
					CastSpellByName('Battle Shout'); 
					return; 
				end 
			end

			-- Check: Use Blood Rage
			if (HasSpell("Blood Rage") and  not IsSpellOnCD("Blood Rage")) then 
				if (localHealth > 70) then 
					CastSpellByName('Blood Rage'); 
					return; 
				end 
			end

			if (self.useRotation) and (GetDistance(targetObj) < self.meleeDistance)  then
				FaceTarget(targetObj);
				AutoAttack(targetObj);
			end

			-- Check: If we are in meele range
			if (GetDistance(targetObj) < self.meleeDistance) then 

				-- Auto attack
				if (not self.useRotation) and (not IsMoving()) then
					UnitInteract(targetObj);
				end
				

				local add = script_info:addTargetingMe(targetObj);

				if (add ~= nil and HasSpell('Thunder Clap')) then
					if (GetDistance(add) < 5) then
						if (localRage < 20) then
							return; -- save rage
						end
						if (not script_target:hasDebuff("Thunder Clap")) then
							CastSpellByName("Thunder Clap");
							return;
						end
					end
				end

				if (script_info:nrTargetingMe() >= 3) then
					if (HasSpell('Retaliation') and not IsSpellOnCD('Retaliation')) then
						CastSpellByName('Retaliation');
					end
				end

				if (HasSpell('Victory Rush')) then
					CastSpellByName('Victory Rush');
				end

				-- Execute
				if (HasSpell('Execute') and targetHealth < 20) then 
					CastSpellByName('Execute');
					return;
				end 

				-- Bloodthirst
				if (HasSpell('Bloodthirst') and not IsSpellOnCD('Bloodthirst')) then 
					CastSpellByName('Bloodthirst'); 
					return;
				end 

				-- Rend
				if (HasSpell('Rend') and not HasDebuff(targetObj, 'Rend') and targetHealth > 50) then
					CastSpellByName('Rend');
					return;
				end

				-- Heroic Strike
				if (not IsMoving()) then
					if (GetHealthPercentage(targetObj) <= 90)
						and (localRage >= 15)
						and (GetDistance(targetObj) <= self.meleeDistance)
					then
				
					FaceTarget(targetObj);
					CastSpellByName('Heroic Strike');
					StopMoving();
					end
				end 
			
				return;
			end
			
		-- Oponer
		else	
			-- Check Charge before Throw
			if (self.useCharge and HasSpell('Charge') and not IsSpellOnCD("Charge")) then
				if (GetDistance(targetObj) < 25 and GetDistance(targetObj) > 12) then
					if (CastSpell('Charge', targetObj)) then
						return;
					end
				end
			else
				-- Check: Use Throw	
				if (self.useThrow and script_warrior:hasThrow()) then
					if (IsSpellOnCD('Throw')) then
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
				if (GetDistance(targetObj) > self.meleeDistance) then
					-- Set the grinder to wait for momvement
					if (script_grind.waitTimer ~= 0) then
						script_grind.waitTimer = GetTimeEX()+1250;
					end
					if (GetDistance(targetObj) < self.meleeDistance) then
						if (IsMoving()) then
							StopMoving();
						end
					end
					MoveToTarget(targetObj);
					return;
				else
					-- Auto attack
					if (not IsMoving()) then
					UnitInteract(targetObj);
					end
				end
				if (GetDistance(targetObj) <= self.meleeDistance) then
					if (IsMoving()) then
						StopMoving();
					end
				end
			elseif (self.useRotation) and (GetDistance(targetObj) < self.meleeDistance) then
				FaceTarget(targetObj);
				AutoAttack(targetObj);
			end

			return;
			
		end
	end
end

function script_warrior:rest()

	if(not self.isSetup) then
		script_warrior:setup();
		return;
	end

	local localObj = GetLocalPlayer();
	local localHealth = GetHealthPercentage(localObj);

	-- Update rest values
	if (script_grind.restHp ~= 0) then
		self.eatHealth = script_grind.restHp;
	end

	--Eat 
	if (not IsEating() and localHealth < self.eatHealth) then	
		if (IsMoving()) then
			StopMoving();
			script_grind:restOn();
			return true;
		end
		
		if(script_helper:eat()) then
			script_grind:restOn();
			return true;
		end
	end

	if(localHealth < self.eatHealth) then
		if (IsMoving()) then
			StopMoving();				
		end
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

function script_warrior:mount()

end

function script_warrior:menu()

	if (CollapsingHeader("[Warrior - Fury")) then
		self.meleeDistance = SliderFloat("Melee Distance", 2, 8, self.meleeDistance);
		local clickCharge = false;
		local clickThrow = false;
		Text('Pull options:');
		clickCharge, self.useCharge = Checkbox("Use Charge", self.useCharge);
		SameLine();
		clickThrow, self.useThrow = Checkbox("Use Throw", self.useThrow);
		if (clickCharge) then self.useThrow = false; end
		if (clickThrow) then self.useCharge = false; end
		Separator();
	end

end
