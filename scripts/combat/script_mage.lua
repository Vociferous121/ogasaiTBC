script_mage = {
	version = '0.1',
	message = 'Mage Combat',
	mageExtra = include("scripts\\combat\\script_mageEX.lua"),
	drinkMana = 50,
	eatHealth = 50,
	water = {},
	numWater = 0,
	food = {},
	numfood = 0,
	manaGem = {},
	numGem = 0,
	isSetup = false,
	useManaShield = true,
	iceBlockHealth = 35,
	iceBlockMana = 35,
	evocationMana = 15,
	evocationHealth = 40,
	manaGemMana = 20,
	useFireBlast = true,
	useWand = true,
	gemTimer = 0,
	waitTimer = 0,
	useRotation = false,
	useFrostNova = true,
	useWandMana = 10,
	useWandHealth = 8,
	useBlink = true,
	useEvocation = true,
	useConeOfCold = true,
	coneOfColdMana = 35,
	coneOfColdHealth = 15,	
}

function script_mage:setup()
	self.iceBlockHealth = 35;
	self.iceBlockMana = 35;
	self.evocationMana = 15;
	self.evocationHealth = 40;
	self.manaGemMana = 20;


	self.waitTimer = GetTimeEX();
	self.gemTimer = GetTimeEX();

	script_grind.moveToMeleeRange = false;

	self.isSetup = true;

	script_mageEX:setup();
end

function script_mage:coneOfCold(spellName) -- cone of cold function needed to work properly
	if (HasSpell(spellName)) then
		if (not IsSpellOnCD(spellName)) then
			if (not IsAutoCasting(spellName)) then
				CastSpellByName(spellName);
				return true;
			end
		end
	end
	return false;
end


function script_mage:runBackwards(targetObj, range)
-- run backwards
	-- Check: Move away from targets affected by frost nova
	if (script_target:hasDebuff('Frost Nova') or script_target:hasDebuff('Frostbite')) then
		local xT, yT, zT = GetPosition(targetObj);
 		local xP, yP, zP = GetPosition(localObj);
		local distance = GetDistance(targetObj);
 		local xV, yV, zV = xP - xT, yP - yT, zP - zT;	
		local vectorLength = math.sqrt(xV^2 + yV^2 + zV^2)
		local xUV, yUV, zUV = (1/vectorLength)*xV, (1/vectorLength)*yV, (1/vectorLength)*zV;		
 		local moveX, moveY, moveZ = xT + xUV*15, yT + yUV*15, zT + zUV;	
		if (distance < 7 and IsInLineOfSight(targetObj)) then 
			if (not script_grind.adjustTickRate) then
				script_grind.tickRate = 0;
			end
			Move(moveX, moveY, moveZ);
			self.waitTimer = GetTimeEX() + 250;
 			return;
 		end
	end
return false;
end

function script_mage:setTimers(miliseconds)

	script_mage.waitTimer = GetTimeEX() + miliseconds;
	script_grind.waitTimer = GetTimeEX() + miliseconds;

end

function script_mage:run(targetObj)

	if (not self.isSetup) then
		script_mage:setup();
	end

	local localObj = GetLocalPlayer();
	local localMana = GetManaPercentage(localObj);
	local localHealth = GetHealthPercentage(localObj);
	local localLevel = GetLevel(localObj);

	if (targetObj == 0) then
		targetObj = GetTarget();
	end

	local targetGUID = GetTargetGUID(targetObj);

	targetHealth = GetHealthPercentage(targetObj);

	-- runbackwards when target has frost nova
	if (GetNumPartyMembers() < 1) and (self.useFrostNova) then
		if (HasDebuff(targetObj, "Frostbite") or HasDebuff(targetObj, "Frost Nova")) and (targetHealth > 10 or localHealth < 35) and (not HasBuff(localObj, 'Evocation')) and (not IsSwimming()) and (IsInLineOfSight(targetObj)) then
			if (not script_grind.adjustTickRate) then
				script_grind.tickRate = 0;
			end
			self.waitTimer = GetTimeEX();
			script_grind.waitTimer = GetTimeEX();
			if (script_mage:runBackwards(targetObj, 8)) then
				return true;
			end
		end
	end

	-- Pre Check
	if (IsChanneling() or IsCasting() or self.waitTimer > GetTimeEX() + (script_grind.tickRate*1000)) or (HasBuff(localObj, "Ice Block")) then
		return;
	end

	-- gift of naaru
	if (IsInCombat()) and ( (script_grindEX2.enemiesAttackingUs() >= 2 and GetHealthPercentage(GetLocalPlayer()) <= 75)
		or (GetHealthPercentage(GetLocalPlayer()) <= 40) ) then
		if (HasSpell("Gift of the Naaru")) and (not IsSpellOnCD("Gift of the Naaru")) then
			if (not IsSpellOnCD("Gift of the Naaru")) then
				Cast("Gift of the Naaru");
				CastSpellByName("Gift of the Naaru");
				script_mage:setTimers(1550);
				return true;
			end			
		end
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

		-- Check: Keep Ice Barrier up if possible
		if (HasSpell("Ice Barrier") and not IsSpellOnCD("Ice Barrier") and not HasBuff(localObj, "Ice Barrier")) then
			if (CastSpellByName('Ice Barrier')) then
				script_mage:setTimers(1550);
				return true;
			end
		-- Check: If we have Cold Snap use it to clear the Ice Barrier CD
		elseif (HasSpell("Ice Barrier") and IsSpellOnCD("Ice Barrier") and HasSpell('Cold Snap') and 
			not IsSpellOnCD("Cold Snap") and not HasBuff(localObj, 'Ice Barrier')) then
			if (CastSpellByName('Cold Snap')) then
				script_mage:setTimers(1550);
				return true;
			end
		end

		local pet = GetPet(); 
		local petHP = 0;
		if (pet ~= nil and pet ~= 0) then
			petHP = GetHealthPercentage(pet);
		end

		-- Summon Elemental
		if (HasSpell("Summon Water Elemental") and not IsSpellOnCD("Summon Water Elemental") and not (petHP > 0)) then
			if (CastSpellByName("Summon Water Elemental")) then
				script_mage:setTimers(1550);
				return true;
			end
		end
		
		--Opener
		if (not IsInCombat()) then
			
			if (not IsInCombat()) and (not self.useRotation) and (HasSpell("Frostbolt"))
				and (IsSpellInRange(self.target, "Frostbolt")) and (GetDistance(self.target) <= 27) and (IsInLineOfSight(self.target)) then
				if (IsMoving()) then
					StopMoving();
				end
			end

			--Cast Spell
			if (localMana >= 8) then
				if (not Cast('Frostbolt', targetGUID)) then
					script_mage:setTimers(2250);
					return true;
				end
			end

			if (localMana >= 10) then
				if (Cast('Fireball', targetGUID)) then
					script_mage:setTimers(2250);
					return true;
				end
			end
			
		-- Combat
		else	
			-- Use Mana Gem when low on mana
			if (localMana < self.manaGemMana and GetTimeEX() > self.gemTimer) then
				for i=0,self.numGem do
					if(HasItem(self.manaGem[i])) then
						if (UseItem(self.manaGem[i])) then
							script_mage:setTimers(1550);
							self.gemTimer = GetTimeEX() + 120000;
						return true;
						end
					end
				end
			end
			
			if (targetHealth <= 15 or targetHealth >= 65) and (localMana >= 8) and (HasSpell('Fire Blast')) and (self.useFireBlast) then
				if (Cast('Fire Blast', targetGUID)) then
					script_mage:setTimers(1550);
					return true;
				end
			end
	
			-- Check: Frostnova when the target is close
			if (self.useFrostNova) and (GetDistance(targetObj) < 5 and not script_target:hasDebuff("Frostbite") and HasSpell("Frost Nova") and not IsSpellOnCD("Frost Nova") and targetHealth > 15) then
				if (not script_grind.adjustTickRate) then
					script_grind.tickRate = 0;
				end
				self.waitTimer = GetTimeEX();
				script_grind.waitTimer = GetTimeEX();
				self.message = "Frost nova the target(s)...";
				CastSpellByName("Frost Nova");
			return true;
			end

			-- Check: Move backwards if the target is affected by Frost Nova or Frost Bite
			if (GetNumPartyMembers() < 1) and (self.useFrostNova) then
				if (HasDebuff(targetObj, "Frostbite") or HasDebuff(targetObj, "Frost Nova")) and (targetHealth > 10 or localHealth < 35) and (not HasBuff(localObj, 'Evocation')) and (not IsSwimming()) and (IsInLineOfSight(targetObj)) then
					if (not script_grind.adjustTickRate) then
						script_grind.tickRate = 0;
					end
					self.waitTimer = GetTimeEX();
					script_grind.waitTimer = GetTimeEX();
					if (script_mage:runBackwards(targetObj, 8)) then -- Moves if the target is closer than 7 yards

						self.message = "Moving away from target...";
						if (not IsSpellOnCD("Frost Nova")) and (GetDistance(targetObj) < 9) and (not HasDebuff(targetObj, "Frostbite")) then
							CastSpellByName("Frost Nova");
						end
						if (GetDistance(targetObj) > 7) and (not IsMoving()) then
							FaceTarget(targetObj);
						end
					return true;
					end 
				end	
			end

			

			-- counterspell if target is casting
			if (HasSpell("Counterspell")) and (not IsSpellOnCD("Counterspell")) and (localMana > 15) and (IsCasting(targetObj)) then
				if (Cast("Counterspell", targetObj)) then
					script_mage:setTimers(1550);
					return true;
				end
			end

			-- Use Evocation if we have low Mana but still a lot of HP left
			if (self.useEvocation) and (localMana < self.evocationMana and localHealth > self.evocationHealth and HasSpell("Evocation") and not IsSpellOnCD("Evocation")) and (targetHealth >= 15) and (IsInCombat()) then		
				self.message = "Using Evocation...";
				if (CastSpellByName("Evocation")) then
					script_mage:setTimers(1550);
					return true;
				end
			end

			-- Use Mana Shield if mana > 35 procent mana and no active Ice Barrier
			if (not HasBuff(localObj, 'Ice Barrier') and HasSpell('Mana Shield') and localMana > 35 and 
				not HasBuff(localObj, 'Mana Shield') and GetDistance(targetObj) < 15) then
				if (not script_target:hasDebuff('Frost Nova') and not script_target:hasDebuff('Frostbite')) then
					if (CastSpellByName('Mana Shield')) then
						script_mage:setTimers(1550);
						return true;
					end
				end
			end
			
			-- Ice Block
			if (HasSpell('Ice Block') and not IsSpellOnCD('Ice Block') and 
				localHealth < self.iceBlockHealth and localMana < self.iceBlockMana) then
				self.message = "Using Ice Block...";
				if (CastSpellByName('Ice Block')) then
					script_mage:setTimers(1550);
					return true;
				end
			end

			-- blink to move away from target if frost nova is on CD
			if (self.useBlink) and (not IsCasting()) and (not IsChanneling()) and (IsInCombat()) and (targetHealth >= 20) then
				if (IsSpellOnCD("Frost Nova")) and (HasSpell("Blink")) and (not HasDebuff(targetObj, "Frost Nova")) and (not HasDebuff(targetObj, "Frostbite")) and (GetDistance(targetObj) <= 6) and (localMana >= 20) and (not IsSpellOnCD("Blink")) then
					local angle = GetAngle(targetObj);
					FaceAngle(angle);
					if (CastSpellByName("Blink")) then
						script_mage:setTimers(1550);
						return true;
					end
				end
			end
				
			local max = 0;
			local dur = 0;
			if (GetInventoryItemDurability(18) ~= nil) then
				dur, max = GetInventoryItemDurability(18);
			end

			--Cone of Cold
			if (self.useConeOfCold) and (HasSpell('Cone of Cold')) and (localMana >= self.coneOfColdMana) and (targetHealth >= self.coneOfColdHealth) then
				if (GetDistance(targetObj) < 9) and (not HasDebuff(targetObj, "Frostbite")) and (not HasDebuff(targetObj, "Frost Nova")) then
						FaceTarget(targetObj);
						script_mage:coneOfCold('Cone of Cold');
						script_mage:setTimers(1550);
						return true;
					
				end
			end

			if (self.useWand and dur > 0) then
				if (localMana <= self.useWandMana or targetHealth <= self.useWandHealth) then
					if (not script_target:autoCastingWand()) then 
						self.message = "Using wand...";
						FaceTarget(targetObj);
						CastSpell("Shoot", targetObj);
						self.waitTimer = GetTimeEX() + 500;
						return;
					end
					return;
				end
			end

			-- Auto Attack if no mana
			if (localMana < 5) and (not HasDebuff(targetObj, "Frost Nova")) and (not HasDebuff(targetObj, "Frost Bite")) and (not self.useRotation) then
				UnitInteract(targetObj);
				
			else
				if (localMana < 5) and (self.useRotation) then
					FaceTarget(targetObj);
					AutoAttack(targetObj);
				end
			end

			--Cast Spell
			if (not IsMoving()) and (localMana >= 10) then
				if (not Cast('Frostbolt', targetGUID)) then
					script_mage:setTimers(1550);
					return true;
				end
			end
			
			-- Fireball at level 1
			if (not IsMoving()) and (not HasSpell("Frostbolt")) and (localMana >= 20) then
				if (Cast('Fireball', targetGUID)) then
					script_mage:setTimers(1550);
					return true;
				end
			end
		end
	
	end

	return;
end

function script_mage:rest()

	if(not self.isSetup) then
		script_mage:setup();
		return true;
	end
	
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
	--Create Water
	local waterIndex = -1;
	for i=0,self.numWater do
		if (HasItem(self.water[i])) then
			waterIndex = i;
			break;
		end
	end
	
	if (waterIndex == -1) then 
		if (HasSpell('Conjure Water') and not AreBagsFull()) and (not IsMoving()) then
			if (localMana > 10 and not IsDrinking() and not IsEating() and not AreBagsFull()) then
				if (IsMoving()) then
					StopMoving();
					script_grind:restOn();
					return true;
				end
				if (not IsStanding()) then
					StopMoving();
					script_grind:restOn();
					return true;
				end
				if (not CastSpellByName('Conjure Water')) then
					script_grind.waitTimer = GetTimeEX() + 1550;
					self.waitTimer = GetTimeEX() + 1550;
					script_grind:restOn();
					return true;
				end
			else
				script_grind:restOn();
				return true;
			end
		end
	end

	
	--Create Food
	local foodIndex = -1;
	for i=0,self.numfood do
		if (HasItem(self.food[i])) then
			foodIndex = i;
			break;
		end
	end
	if (foodIndex == -1 and HasSpell('Conjure Food') and not AreBagsFull()) then 
		if (IsMoving()) then
			StopMoving();
			script_grind:restOn();
			return true;
		end
		if (not IsStanding()) then
			StopMoving();
			script_grind:restOn();
			return true;
		end
		if (localMana > 10 and not IsDrinking() and not IsEating() and not AreBagsFull()) then
			if (not CastSpellByName('Conjure Food')) then
				self.waitTimer = GetTimeEX() + 1550;
				script_grind.waitTimer = GetTimeEX() + 1550;
				script_grind:restOn();
				return true;
			end
		end
	end

	--Create Mana Gem
	local gemIndex = -1;
	for i=0,self.numGem do
		if (HasItem(self.manaGem[i])) then
			gemIndex = i;
			break;
		end
	end
	if (gemIndex == -1 and (HasSpell('Conjure Mana Ruby') 
		or HasSpell('Conjure Mana Citrine') 
		or HasSpell('Conjure Mana Jade')
		or HasSpell('Conjure Mana Agate'))) then 
		self.message = "Conjuring mana gem...";
		if (IsMoving()) then
			script_grind:restOn();
			StopMoving();
			return;
		end
		if (not IsStanding()) then
			StopMoving();
			script_grind:restOn();
			return;
		end
		if (localMana > 20 and not IsDrinking() and not IsEating() and not AreBagsFull()) then
			if (HasSpell('Conjure Mana Ruby')) then
				if (CastSpellByName('Conjure Mana Ruby')) then
					self.waitTimer = GetTimeEX() + 1550;
					script_grind.waitTimer = GetTimeEX() + 1550;
					script_grind:restOn();
					return true;
				end
			elseif (HasSpell('Conjure Mana Citrine')) then
				if (CastSpellByName('Conjure Mana Citrine')) then
					self.waitTimer = GetTimeEX() + 1550;
					script_grind.waitTimer = GetTimeEX() + 1550;
					script_grind:restOn();
					return true;
				end
			elseif (HasSpell('Conjure Mana Jade')) then
				if (CastSpellByName('Conjure Mana Jade')) then
					self.waitTimer = GetTimeEX() + 1550;
					script_grind.waitTimer = GetTimeEX() + 1550;
					script_grind:restOn();
					return true;
				end
			elseif (HasSpell('Conjure Mana Agate')) then
				if (CastSpellByName('Conjure Mana Agate')) then
					self.waitTimer = GetTimeEX() + 1550;
					script_grind.waitTimer = GetTimeEX() + 1550;
					script_grind:restOn();
					return true;
				end
			end
		end
	end

	--Eat and Drink
	if (not IsDrinking() and localMana < self.drinkMana) and (not IsInCombat()) then
		if (IsMoving()) then
			StopMoving();
			script_grind:restOn();
			return true;
		end

		if(script_helper:drinkWater()) then
			self.waitTimer = GetTimeEX() + 1550;
			script_grind.waitTimer = GetTimeEX() + 1550;
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
			self.waitTimer = GetTimeEX() + 1550;
			script_grind.waitTimer = GetTimeEX() + 1550;
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

	if (IsDrinking() and localMana < 92) or (IsEating() and localHealth < 92) then
		return;
	elseif (not IsStanding()) then
		local x, y, z = GetPosition(GetLocalPlayer());
		Move(x-1, y, z)
	end

	if (localMana < self.drinkMana and not IsDrinking()) and (localHealth < self.eatHealth and not IsEating()) then
		script_grind.message = "No food/water or none included in helper...";
	end


	-- Do Buff
	if (not IsInCombat()) then
		if (Buff('Arcane Intellect', localObj)) then
			self.waitTimer = GetTimeEX() + 1550;
			script_grind.waitTimer = GetTimeEX() + 1550;
			return true;
		end
		if (Buff('Dampen Magic', localObj)) then
			self.waitTimer = GetTimeEX() + 1550;
			script_grind.waitTimer = GetTimeEX() + 1550;
			return true;
		end
		if (HasSpell('Ice Armor')) then
			if (Buff('Ice Armor', localObj)) then
				self.waitTimer = GetTimeEX() + 1550;
				script_grind.waitTimer = GetTimeEX() + 1550;
				return true;
			end
		
		end
		if (not HasSpell("Ice Armor")) then
			if (Buff('Frost Armor', localObj)) then
				self.waitTimer = GetTimeEX() + 1550;
				script_grind.waitTimer = GetTimeEX() + 1550;
				return true;
			end
		end
	end
	
	script_grind:restOff();
	return false;
end