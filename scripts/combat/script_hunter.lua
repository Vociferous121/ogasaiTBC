script_hunter = {
	version = '1.0',
	message = 'Hunter Combat',
	bagWithPetFood = 4, -- 2nd last slot to the left
	slotWithPetFood = GetContainerNumSlots(3), -- last slot in the bag
	foodName = 'PET FOOD NAME',
	quiverBagNr = 5, -- last bag slot to the left
	drinkMana = 50,
	eatHealth = 50,
	isSetup = false,
	waitTimer = 0,
	stopWhenNoPetFood = false,
	stopWhenQuiverEmpty = false,
	stopWhenBagsFull = false,
	buyWhenAmmoEmpty = true,
	ammoName = "",
	ammoIsArrow = true,
	extraScript = include("scripts\\combat\\script_hunterEX.lua"),
	useRotation = false,
}

-- Only the functions setup, run, rest and menu are located in this file
-- See script_hunterEX for more "hunter" functions

-- Run backwards if the target is within range
function script_hunter:runBackwards(targetObj, range) 
	local localObj = GetLocalPlayer();
 	if (targetObj ~= 0) and (not script_checkDebuffs:hasDisabledMovement()) then
 		local xT, yT, zT = GetPosition(targetObj);
 		local xP, yP, zP = GetPosition(localObj);
 		local distance = GetDistance(targetObj);
 		local xV, yV, zV = xP - xT, yP - yT, zP - zT;	
 		local vectorLength = math.sqrt(xV^2 + yV^2 + zV^2);
 		local xUV, yUV, zUV = (1/vectorLength)*xV, (1/vectorLength)*yV, (1/vectorLength)*zV;		
 		local moveX, moveY, moveZ = xT + xUV*25, yT + yUV*25, zT + zUV;		
 		if (distance < range) then
 			Move(moveX, moveY, moveZ);
			return;
 		end
	end
	return false;
end

function script_hunter:setTimers(miliseconds)

	self.waitTimer = GetTimeEX() + miliseconds;
	script_grind.waitTimer = GetTimeEX() + miliseconds;

end

function script_hunter:setup()

	script_hunterEX:setup();


	-- Save the name of ammo we use, only checks the last slot on the bag
	local bagSlot = GetContainerNumSlots(self.quiverBagNr-1);
	if (GetContainerItemLink(self.quiverBagNr-1, bagSlot)  ~= nil) then
		local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType,
   		itemStackCount, itemEquipLoc, itemTexture = GetItemInfo(GetContainerItemLink(self.quiverBagNr-1, bagSlot));
		self.ammoName = itemName;
		--DEFAULT_CHAT_FRAME:AddMessage('script_hunter: Ammo name is set to: "' .. self.ammoName .. '" ...');
		if (not strfind(itemName, "Arrow")) then
		--	DEFAULT_CHAT_FRAME:AddMessage('script_hunter: Ammo will be bought at "Bullet" vendors...');
			self.ammoIsArrow = false;
			script_vendorEX.bulletName = itemName;
		else
			--DEFAULT_CHAT_FRAME:AddMessage('script_hunter: Ammo will be bought at "Arrow" vendors...');
			script_vendorEX.arrowName = itemName;
		end
	end

	-- Save the name of pet food we use
	if (GetContainerItemLink(self.bagWithPetFood-1, self.slotWithPetFood)  ~= nil) then
		local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType,
   		itemStackCount, itemEquipLoc, itemTexture = GetItemInfo(GetContainerItemLink(self.bagWithPetFood-1, self.slotWithPetFood));
		self.foodName = itemName;
		--DEFAULT_CHAT_FRAME:AddMessage('script_hunter: Pet food name is set to: "' .. self.foodName .. '" ...');
	else
		--DEFAULT_CHAT_FRAME:AddMessage('script_hunter: Please set the pet food name in hunter options...');
	end

	self.waitTimer = GetTimeEX();
	script_grind.moveToMeleeRange = false;

	self.isSetup = true;
end

function script_hunter:buyAmmo()
	-- Quiver check : should we go buy ammo?
	if (self.buyWhenAmmoEmpty and self.ammoName ~= 0) then
		local ammoNr = 0;
		for y=1,GetContainerNumSlots(self.quiverBagNr-1) do
			local texture, itemCount, locked, quality, readable = GetContainerItemInfo(self.quiverBagNr-1,y);
			if (itemCount ~= nil) then 
				ammoNr = ammoNr + 1; 
			end 
		end

		-- Go buy ammo if we have just 1 stack of ammo left
		if (ammoNr <= 1 and self.ammoName ~= 0) then
			if (self.ammoIsArrow and script_vendorEX.arrowVendor ~= 0) then
				script_vendor:buy(self.ammoName, (GetContainerNumSlots(self.quiverBagNr-1)-1), false, false, true, false);
				return true;
			elseif (script_vendorEX.bulletVendor ~= 0) then
				script_vendor:buy(self.ammoName, (GetContainerNumSlots(self.quiverBagNr-1)-1), false, false, false, true);
				return true;
			end
			return false;
		end 
	end
end

function script_hunter:run(targetObj)
	if(not self.isSetup) then
		script_hunter:setup();
		return;
	end

	local localObj = GetLocalPlayer();
	local localMana = GetManaPercentage(localObj);
	local localHealth = GetHealthPercentage(localObj);
	local localLevel = GetLevel(localObj);

	-- stuck in combat
	if (IsInCombat()) and (GetPet() ~= 0) and (not self.useRotation) then
		if (GetUnitsTarget(localObj) == 0) and (GetUnitsTarget(GetPet()) == 0) and (GetNumPartyMembers() < 1) then
			if (GetUnitsTarget(GetPet()) ~= 0) then
				AssistUnit("pet");
			end
			self.message = "No Target - stuck in combat! WAITING!";
			if (IsMoving()) then
				StopMoving();
				return true;
			end
			return;
		end
	end

	if (targetObj == 0) then
		targetObj = GetTarget();
	end

	local targetGUID = GetTargetGUID(targetObj);

	-- Check: Do we have a pet?
	if (script_hunterEX.hasPet) then if (localLevel < 10) then script_hunterEX.hasPet = false; end end
	local pet = GetPet(); local petHP = 0;
	if (pet ~= nil and pet ~= 0) then petHP = GetHealthPercentage(pet); end

	-- Pre Check
	if (IsChanneling() or IsCasting() or self.waitTimer > GetTimeEX()) then
		return;
	end
	
	--Valid Enemy
	if (targetObj ~= 0) then
		-- Cant Attack dead targets
		if (IsDead(targetObj)) then return; end
		if (not CanAttack(targetObj)) then return; end
		
		targetHealth = GetHealthPercentage(targetObj);
		script_hunterEX:chooseAspect(targetGUID);

		-- Check if we have ammo
		local hasAmmo = script_helper:hasAmmo();

		-- walk away from target if pet target guid is the same guid as target targeting me
		if (IsInCombat()) and (GetPet() ~= 0) and (GetDistance(targetObj) <= 10) and (GetUnitsTarget(targetObj) == GetPet())
			and (not script_checkDebuffs:hasDisabledMovement()) then
			script_hunter:runBackwards(targetObj, 12);
				self.message = "Moving away from target for range attacks...";
				script_hunter:setTimers(1550);
				if (not IsMoving()) then
					if (not IsSpellOnCD("Arcane Shot")) then
						CastSpellByName("Arcane Shot");
					end
				end
			return;
		end
		
		--Opener
		if (not IsInCombat()) then

			if (hasAmmo) then
				if (script_hunterEX:doOpenerRoutine(targetGUID)) then
					PetAttack(targetObj);
					script_hunter:setTimers(1550);
					return;
				end
			end

			-- Check move into meele range
			if (not self.useRotation) then
				if (GetDistance(targetObj) > 5) then
					if (script_grind.waitTimer ~= 0) then
						script_grind.waitTimer = GetTimeEX() + 1250;
					end
					MoveToTarget(targetObj);
					return;
				else
					if (not IsMoving()) then
						FaceTarget(targetObj);
					end
					AutoAttack(targetObj);
					if (Cast('Raptor Strike', targetGUID)) then 
						return; 
					end
				end
			elseif (self.useRotation) then
				if (not IsMoving()) then
					FaceTarget(targetObj);
				end
				AutoAttack(targetObj);
				if (Cast('Raptor Strike', targetGUID)) then 
					return; 
				end
			end

		-- Combat
		else	

			if (GetDistance(self.target) <= 6) and (GetPet() == 0) then
				AutoAttack(targetObj);
				UnitInteract(targetObj);
				return true;
			end

			if (script_hunterEX:mendPet(localMana, petHP)) then
				return;
			end
			
			if (script_hunterEX:doInCombatRoutine(targetGUID, localMana)) then
				return;
			else
				if (script_grind.waitTimer ~= 0) then
					script_grind.waitTimer = GetTimeEX() + 1250;
				end
				if (not self.useRotation) then
					MoveToTarget(targetObj);
				end
				return;
			end

			return;	
		end
	
	end
end

function script_hunter:rest()
	if(not self.isSetup) then script_hunter:setup(); return true; end

	local localObj = GetLocalPlayer();
	local localMana = GetManaPercentage(localObj);
	local localHealth = GetHealthPercentage(localObj);

	-- Update rest values
	if (script_grind.restHp ~= 0) then
		self.eatHealth = script_grind.restHp;
	end
	if (script_grind.restMana ~= 0) then
		self.drinkMana = script_grind.restMana;
	end

	if (self.waitTimer > GetTimeEX() or IsCasting() or IsChanneling()) then
		return;
	end

	-- Check: Let the feed pet duration last, don't engage new targets
	if (script_hunterEX.feedTimer > GetTimeEX() and not IsInCombat() and script_hunterEX.hasPet and GetPet() ~= 0) then 
		self.message = "Feeding the pet, pausing...";
		if (GetDistance(GetPet()) > 8) then
			PetFollow();
			script_hunter:setTimers(1550);
			script_grind:restOn();
			return true;
		end
		script_grind:restOn();
		return true;
	end


	-- Eat and Drink
	if (not IsDrinking() and localMana < self.drinkMana) then
		if (IsMoving()) then
			StopMoving();
			script_grind:restOn();
			return true;
		end

		if(script_helper:drinkWater()) then
			script_grind:restOn();
			return true;
		end
	end

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

	-- Check hunter bags if they are full
	local inventoryFull = script_helper:areBagsFull(self.quiverBagNr);

	if (inventoryFull) then
		script_grind:turnfOffLoot("bags are full...");
		if (self.stopWhenBagsFull) then
			self.message = "Bags are full...";
			if (IsMoving()) then StopMoving(); return true; end
			Logout(); StopBot(); return true; 
		end
	end

	-- Quiver check : Stop when out of ammo
	if (self.stopWhenQuiverEmpty and not IsInCombat() and not script_helper:hasAmmo()) then
		Logout(); StopBot(); return true; 	
	end


	-- Check for pet food, change bag/slot if we have too
	if (GetContainerItemLink(self.bagWithPetFood-1, self.slotWithPetFood)  == nil) then
		bagNr = 0;
		bagSlot = 0;
		for i = 0, 4 do
			if i ~= self.quiverBagNr-1 then
				for y = 0, GetContainerNumSlots(i) do
					if (GetContainerItemLink(i, y) ~= nil) then
						local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType,
   							itemStackCount, itemEquipLoc, itemTexture = GetItemInfo(GetContainerItemLink(i, y));
						if (self.foodName == itemName) then
							self.bagWithPetFood = i+1;
							self.slotWithPetFood = y;
							break;
						end
					end
				end
			end
		end
	end

	-- Pet checks
	if (script_hunterEX:petChecks()) then script_grind:restOn(); return true; end

	-- Aspect check
	script_hunterEX:chooseAspect(targetObj);

	-- Check if we should buy ammo, don't call more than once
	if (script_vendor.status == 0) then
		if (script_hunter:buyAmmo()) then
			self.waitTimer = GetTimeEX() + 10000;
			return false;
		end 
	end

	script_grind:restOff();
	return false;
end
