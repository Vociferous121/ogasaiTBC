script_hunterEX = {
	message = "Hunter extra functions",
	arcaneMana = 40,
	useCheetah = false,
	markTimer = 0,
	serpentTimer = 0,
	mendTimer = 0,
	feedTimer = 0,
	petTimer = 0,
	wingTimer = 0,
	hasPet = true,
	ammoName = 'Rough Arrow',
	ammoIsArrow = true,
	buyWhenAmmoEmpty = true,
	useRotation = false,
	waitTimer = GetTimeEX(),
	huntersMarkMana = 55,
	useHuntersMark = true,
	useArcaneShot = true,
	useSerpentSting = true,
	serpentStingMana = 25,
}

-- this file includes functions used by script_hunter

function script_hunterEX:setup()

	self.feedTimer = GetTimeEX();
	self.markTimer = GetTimeEX();
	self.serpentTimer = GetTimeEX();
	self.mendTimer = GetTimeEX();
	self.petTimer = GetTimeEX();
	self.wingTimer = GetTimeEX();

end

function script_hunterEX:doInCombatRoutine(targetGUID, localMana) 
	local targetObj = GetGUIDTarget(targetGUID);
	self.message = "Killing target...";
	local targetHealth = GetHealthPercentage(targetObj); -- update target's HP
	local pet = GetPet(); -- get pet

	if (script_hunter.waitTimer > GetTimeEX()) then
		return;
	end

	if (self.useArcaneShot) and (not self.hasPet and HasSpell('Arcane Shot') and GetDistance(targetObj) > 13) then -- arcane early when no pet
		if (Cast('Arcane Shot', targetGUID)) then
			script_hunter:setTimers(1550);
			return true;
		end
	end

	if (self.hasPet and script_hunterEX:mendPet(GetManaPercentage(GetLocalPlayer()), GetHealthPercentage(pet))) then
		script_hunter:setTimers(1550);
		return true;
	end

	-- Check: If pet is too far away set it to follow us, else attack
	if (self.hasPet and GetPet() ~= 0) then
		if (GetDistance(pet) > 34) then
			PetFollow();
		else
			PetAttack();
		end
	end

	-- Check: Use Rapid Fire 
	if (HasSpell('Rapid Fire') and not IsSpellOnCD('Rapid Fire') and targetHealth > 80) then
		CastSpellByName('Rapid Fire');
		script_hunter:setTimers(1550);
		return true;
	end

	-- Check: If pet is stunned, feared etc use Bestial Wrath
	if (self.hasPet and GetPet() ~= 0 and GetPet() ~= nil) then
		if ((IsStunned(pet) or IsConfused(pet) or IsFleeing(pet)) and UnitExists("Pet") and HasSpell('Bestial Wrath') and not IsSpellOnCD('Bestial Wrath')) then
			CastSpellByName('Bestial Wrath');
			script_hunter:setTimers(1550);
			return true;
		end
	end

	-- Check: If in range, use range attacks
	if (GetDistance(targetObj) <= 34 and GetDistance(targetObj) >= 9) then
		if(script_hunterEX:doRangeAttack(targetGUID, localMana)) then
			script_hunter:setTimers(1550);
		return true;
		end 
	end

	if (GetDistance(targetObj) <= 8) and (GetDistance(targetObj) >= 3)
		and ( (GetPet() == 0) or (GetPet() ~= 0 and not GetUnitsTarget(targetObj) == GetPet()) ) then
		return false;
	end

	-- Check: If we are in melee range, use meele abilities
	if (GetDistance(targetObj) <= 4) then
		if (GetPet() == 0) or (GetPet() ~= 0 and not GetUnitsTarget(targetObj) == GetPet()) then
			-- Meele Skill: Raptor Strike
			if (localMana > 10 and GetHealthPercentage(targetObj) <= 80 and not IsSpellOnCD('Raptor Strike')) then 
				if (Cast('Raptor Strike', targetGUID)) then
					script_hunter:setTimers(1550); 
					return true; 
				end 
			end
		end
		-- Meele Skill: Wing Clip (keeps the debuff up)
		if (self.wingTimer < GetTimeEX() and localMana > 10 and not HasDebuff(targetObj, 'Wing Clip') and HasSpell('Wing Clip')) then 
			if (Cast('Wing Clip', targetGUID)) then 
				script_hunter:setTimers(1550);
				self.wingTimer = GetTimeEX() + 10000;
				return true; 
			end 
		end
	end

	-- Return false and run close to target
	if (GetDistance(targetObj) > 35) then 
		return false;
	end

	-- Return true if in melee range
	if (GetDistance(targetObj) < 5) then 
		return true;
	end
end

function script_hunterEX:doRangeAttack(targetGUID, localMana)
	local targetObj = GetGUIDTarget(targetGUID);

	if (self.waitTimer > GetTimeEX() or IsCasting() or IsChanneling()) then
		return;
	end

	if (GetDistance(targetObj) <= 5) and (GetPet() == 0) then
		AutoAttack(targetObj);
		UnitInteract(targetObj);
	end

	-- Keep up the debuff: Hunter's Mark 
	if (self.useHuntersMark) and (localMana >= self.huntersMarkMana) and (HasSpell("Hunter's Mark") and self.markTimer < GetTimeEX()) then 
		if (Cast("Hunter's Mark", targetGUID)) then
			script_hunter:setTimers(1550);
			self.markTimer = GetTimeEX() + 20000;
			return true;
		end 
	end

	-- Check: Let pet get aggro, dont use special attacks before the mob has less than 95 percent HP
	if (GetHealthPercentage(targetObj) > 95 and UnitExists("Pet")) then return true; end

	-- Check: Intimidation is ready and mob HP high
	if (not IsSpellOnCD('Intimidation') and GetHealthPercentage(targetObj) > 50) then 
		if (Cast('Intimidation', targetGUID)) then
			script_hunter:setTimers(1550);
			return true;
		end 
	end	
	
	-- Special attack: Serpent Sting (Keep the DOT up!)
	if (self.useSerpentSting) and (localMana >= self.serpentStingMana) and (self.serpentTimer < GetTimeEX() and not IsSpellOnCD('Serpent Sting') 
		and GetCreatureType(targetObj) ~= 'Elemental') and (GetHealthPercentage(targetObj) >= 30) then 
		if (Cast('Serpent Sting', targetGUID)) then
			script_hunter:setTimers(1550);
			self.serpentTimer = GetTimeEX() + 15000;
			return true;
		end 
	end

	-- Special attack: Arcane Shot 
	if (self.useArcaneShot) and (not IsSpellOnCD('Arcane Shot') and localMana > self.arcaneMana) then 
		if (Cast('Arcane Shot', targetGUID)) then
			script_hunter:setTimers(1550);
			return true;
		end
	end

	-- Attack: Use Auto Shot 
	if (not IsAutoCasting('Auto Shot')) and (not IsMoving()) and (not IsLooting()) then
		if (Cast('Auto Shot', targetGUID)) then
			script_hunter:setTimers(550);
			return true;
		else
			return false;
		end
	end

	return false;
end

function script_hunterEX:mendPet(localMana, petHP)
	local mendPet = HasSpell("Mend Pet");

	if (mendPet and IsInCombat() and self.hasPet and petHP > 0 and self.mendTimer < GetTimeEX()) then
		if (GetHealthPercentage(GetPet()) < 50) then
			self.message = "Pet has lower than 50 percenet HP, mending pet...";
			-- Check: If in range to mend the pet 
			if (GetDistance(GetPet()) < 45 and localMana > 10 and IsInLineOfSight(GetPet())) then 
				if (IsMoving()) then StopMoving(); return true; end 
				CastSpellByName("Mend Pet"); 
				script_hunter:setTimers(1550);
				self.mendTimer = GetTimeEX() + 15000;
				return true;
			elseif (localMana > 10) then 
				local x, y, z = GetPosition(GetPet());
				MoveToTarget(x, y, z); 
				return true; 
			end 
			
		end
	end

	return false;
end

function script_hunterEX:doOpenerRoutine(targetGUID) 
	local targetObj = GetGUIDTarget(targetGUID);

	if (GetDistance(targetObj) <= 5) and (GetPet() == 0) then
		AutoAttack(targetObj);
		UnitInteract(targetObj);
	end

	-- Let pet loose early to get aggro (even before we are in range ourselves)
	if (self.hasPet and GetDistance(targetObj) < 50) then
		PetAttack();
	end	

	if (script_hunterEX:doPullAttacks(targetGUID)) then
		script_hunter:setTimers(1550);
		return true;
	end
 
	-- Attack: Use Auto Shot 
	if (not IsAutoCasting('Auto Shot') and GetDistance(targetObj) < 35 and GetDistance(targetObj) > 13) then
		if (Cast('Auto Shot', targetGUID)) then
			script_hunter:setTimers(550);
			return true;
		else
			return false;
		end
	end

	-- Check: If we are already in meele range before pull, use Raptor Strike
	if (GetDistance(targetObj) <= 5) then
			AutoAttack(targetObj);
			UnitInteract(targetObj);
		if (Cast('Raptor Strike', targetGUID)) then
			script_hunter:setTimers(1550);
			return true;
		end 
	end

	-- Move to the target if not in range
	if (GetPet() ~= 0 and GetDistance(targetObj) > 35 or (GetDistance(targetObj) <= 5 and not GetUnitsTarget(targetObj) == GetPet()))
		or (GetDistance(targetObj) > 35 or GetDistance(targetObj) <= 9 and GetPet() == 0) then
		return false;
	end 

	-- return true so we dont move closer to the mob
	return true; 
end

function script_hunterEX:doPullAttacks(targetGUID)

	local targetObj = GetGUIDTarget(targetGUID);
	local localMana = GetManaPercentage(GetLocalPlayer());

	-- Pull with Concussive Shot to make it easier for pet to get aggro
	if (HasSpell('Concussive Shot')) then
		if (Cast('Concussive Shot', targetGUID)) then
			script_hunter:setTimers(1550);
			return true;
		end
	end

	-- If no concussive shot pull with Serpent Sting
	if (HasSpell('Serpent Sting')) and (self.useSerpentSting) and (localMana >= self.serpentStingMana) then
		if (GetCreatureType(targetObj) ~= 'Elemental') then
			if (Cast('Serpent Sting', targetGUID)) then
				script_hunter:setTimers(1550);
				return true;
			end
		end
	end

	-- If no special attacks available for pull use Auto Shot
	if (Cast('Auto Shot', targetGUID)) then
		script_hunter:setTimers(550);
		return true;
	end

	return false;
end

function script_hunterEX:chooseAspect(targetGUID)
	local targetObj = GetGUIDTarget(targetGUID);
	local localObj = GetLocalPlayer();

	if (not IsStanding()) then
		return false;
	end

	hasHawk, hasMonkey, hasCheetah = HasSpell("Aspect of the Hawk"), HasSpell("Aspect of the Monkey"), HasSpell("Aspect of the Cheetah");

	if (hasMonkey and GetLevel(localObj) < 10) then 
		if (not HasBuff(localObj, 'Aspect of the Monkey')) then  
			CastSpellByName('Aspect of the Monkey'); 
			script_hunter:setTimers(1550);
			return true; 
		end	
	elseif (hasMonkey and (targetObj ~= nil and targetObj ~= 0)) then
		if (GetDistance(targetObj) < 5 and IsInCombat() and not self.hasPet) then
			if (not HasBuff(localObj, 'Aspect of the Monkey')) then  
				CastSpellByName('Aspect of the Monkey'); 
				script_hunter:setTimers(1550);
				return true; 
			end
		else
			if (hasHawk and IsInCombat()) then 
				if (not HasBuff(localObj, 'Aspect of the Hawk')) then 
					CastSpellByName('Aspect of the Hawk'); 
					script_hunter:setTimers(1550);
					return true; 
				end 
			end
		end
	elseif (hasCheetah and not IsInCombat() and self.useCheetah) then 
		if (not HasBuff(localObj, 'Aspect of the Cheetah')) then 
			CastSpellByName('Aspect of the Cheetah'); 
			script_hunter:setTimers(1550);
			return true;  
		end 
	end

	return false;
end

function script_hunterEX:petChecks()
	local localObj = GetLocalPlayer();
	local localMana = GetManaPercentage(localObj);
	local pet = GetPet();
	local petHP = 0;

	if (IsMounted()) then
		return false;
	end

	if (pet ~= nil and pet ~= 0) then
		petHP = GetHealthPercentage(pet);
	end

	-- Check hasPet
	if (self.hasPet) then
		if (GetLevel(localObj) < 10) then
			self.hasPet = false;
		end
	end

	-- Check: If pet is dismissed then Call pet 
	if (GetPet() == nil and self.hasPet) then
		self.message = "Pet is missing, calling pet...";
		CastSpellByName('Call Pet');
		script_hunter:setTimers(1550);
		return true;
	end

	-- Check: If pet is dismissed/dead, call then revive pet
	if (self.hasPet and GetPet() == 0 and not IsInCombat() and HasSpell("Revive Pet")) then	
		self.message = "Pet is dead, reviving pet...";
		if (IsMoving() or not IsStanding()) then 
			StopMoving(); 
			return true; 
		end
		CastSpellByName("Call Pet");
		script_hunter:setTimers(12000);
		if (localMana > 60) then 
			CastSpellByName('Revive Pet'); 
			return true; 
		else 
			self.message = "Pet is dead, need more mana to ress it...";
			return true; 
		end
	end

	-- Check: Stop if we ran out of pet food in the "pet food slot"
	if (script_hunter.stopWhenNoPetFood and self.hasPet and not IsInCombat()) then
		local texture, itemCount, locked, quality, readable = GetContainerItemInfo(script_hunter.bagWithPetFood-1, GetContainerNumSlots(script_hunter.bagWithPetFood-1));
		if (itemCount == nil) then
			self.message = "No more pet food, stopping the bot..."; 
			if (IsMoving() or not IsStanding()) then StopMoving(); return true; end
			Logout(); 
			StopBot(); 
			return true;  
		end
	end	

	-- Check: If pet isn't happy, feed it 
	if (petHP > 0 and self.hasPet) then
		local happiness, damagePercentage, loyaltyRate = GetPetHappiness();	
		if (not IsDead(pet) and self.feedTimer < GetTimeEX() and not IsInCombat()) then
			if (happiness < 3 or loyaltyRate < 0) then
				self.message = "Pet is not happy, feeding the pet...";
				if (not IsStanding()) then StopMoving(); return true; end
			--	DEFAULT_CHAT_FRAME:AddMessage('script_hunter: Feeding the pet, and resting for 20 seconds...');
				CastSpellByName("Feed Pet"); 
				UseContainerItem(script_hunter.bagWithPetFood-1, script_hunter.slotWithPetFood, "Pet");
				-- Set a 20 seconds timer for this check (Feed Pet duration)
				self.feedTimer = GetTimeEX() + 20000; 
				return true;
			end
		end
	end	

	-- If we have the skill Mend Pet
	local mendPet = HasSpell("Mend Pet");
	if (mendPet and self.hasPet) then
		-- Check: Mend the pet if it has lower than 70 percent HP and out of combat
		if (self.hasPet and petHP < 70 and petHP > 0 and not IsInCombat() and self.mendTimer < GetTimeEX()) then
			if (GetDistance(GetPet()) > 8) then
				PetFollow();
				return true;
			end
			if (GetDistance(GetPet()) < 45 and localMana > 10) then
				if (self.hasPet and petHP < 70 and not IsInCombat() and petHP > 0) then
					self.message = "Pet has lower than 70 percent HP, mending pet...";
					if (IsMoving() or not IsStanding()) then StopMoving(); return true; end
					CastSpellByName('Mend Pet');
					self.mendTimer = GetTimeEX() + 15000;
					return true;
				end
			end
		end
	else
		if (petHP < 85 and self.hasPet) then
			if (self.hasPet and self.petTimer < GetTimeEX()) then
			--	DEFAULT_CHAT_FRAME:AddMessage('script_hunter: Pet has < 85 percent HP, lets wait...');
				self.petTimer = GetTimeEX() + 10000;
			end
			return true;
		end
	end

	return false;
end


function script_hunterEX:menu()
	if (CollapsingHeader("Hunter - Beastmaster")) then
		local wasClicked = false;
		
		if (HasSpell("Hunter's Mark")) then
			wasClicked, script_hunterEX.useHuntersMark = Checkbox("Use Hunter's Mark", script_hunterEX.useHuntersMark);
		end

		if (HasSpell("Arcane Shot")) then
			SameLine();
			wasClicked, script_hunterEX.useArcaneShot = Checkbox("Use Arcane Shot", script_hunterEX.useArcaneShot);
		end

		if (HasSpell("Serpent Sting")) then
			wasClicked, script_hunterEX.useSerpentSting = Checkbox("Use Serpent Sting", script_hunterEX.useSerpentSting);
		end
		
		if (HasSpell("Aspect of the Cheetah")) then
			SameLine();
			wasClicked, script_hunterEX.useCheetah = Checkbox("Use Cheetah", script_hunterEX.useCheetah);
		end

		Separator();

		if (HasSpell("Arcane Shot")) and (script_hunterEX.useArcaneShot) then
			Text("Use Arcane Shot Above Mana Percent");
			script_hunterEX.arcaneMana = SliderInt("ASM", 1, 100, script_hunterEX.arcaneMana);
			Separator();
		end
		if (HasSpell("Hunter's Mark")) and (script_hunterEX.useHuntersMark) then
			Text("Use Hunter's Mark Above Mana Percent");
			script_hunterEX.huntersMarkMana = SliderInt("HMM", 1, 100, script_hunterEX.huntersMarkMana);
			Separator();
		end
		if (HasSpell("Serpent Sting")) and (script_hunterEX.useSerpentSting) then
			Text("Use Serpent Sting Above Mana Percent");
			script_hunterEX.serpentStingMana = SliderInt("SSM", 1, 100, script_hunterEX.serpentStingMana);
			Separator();
		end
		Text("Bag# with pet food (1-5)");
		script_hunter.bagWithPetFood = InputText("BPF", script_hunter.bagWithPetFood);
		Text("Slot# with pet food (1-MaxSlot)");
		script_hunter.slotWithPetFood = InputText("SPF", script_hunter.slotWithPetFood);
		Text('Pet food name:');
		script_hunter.foodName = InputText("PFN", script_hunter.foodName);
		Separator();
		Text("Bag# for quiver (2-5)");
		script_hunter.quiverBagNr = InputText("QS", script_hunter.quiverBagNr);
		Separator();
		wasClicked, script_hunter.buyWhenAmmoEmpty = Checkbox("Buy ammo when almost out", script_hunter.buyWhenAmmoEmpty);
		SameLine(); wasClicked, script_hunter.ammoIsArrow = Checkbox("Ammo is Arrows", script_hunter.ammoIsArrow);
		script_hunter.ammoName = InputText("Ammo Name", script_hunter.ammoName); 
		if (CollapsingHeader("|+| Stop Settings")) then
			Text('Stop settings:');
			wasClicked, script_hunter.stopWhenBagsFull = Checkbox("Stop when bags are full", script_hunter.stopWhenBagsFull);
			wasClicked, script_hunter.stopWhenQuiverEmpty = Checkbox("Stop when we run out of ammo", script_hunter.stopWhenQuiverEmpty);
			wasClicked, script_hunter.stopWhenNoPetFood = Checkbox("Stop when we run out of pet food", script_hunter.stopWhenNoPetFood);
		end	
	end
end