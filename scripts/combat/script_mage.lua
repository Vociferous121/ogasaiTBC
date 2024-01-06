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
	timer = 0,
	useRotation = false,
	useFrostNova = true,
}

function script_mage:setup()
	self.iceBlockHealth = 35;
	self.iceBlockMana = 35;
	self.evocationMana = 15;
	self.evocationHealth = 40;
	self.manaGemMana = 20;

	self.timer = GetTimeEX();
	self.gemTimer = GetTimeEX();

	DEFAULT_CHAT_FRAME:AddMessage('script_mage: loaded...');
	self.isSetup = true;

	script_mageEX:setup();
end

function script_mage:run(targetObj)

	if(not self.isSetup) then
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

	-- Timer
	if (self.timer > GetTimeEX()) then
		return;
	end

	-- Check: Move away from targets affected by frost nova
	if (script_target:hasDebuff('Frost Nova') or script_target:hasDebuff('Frostbite')) then
			local xT, yT, zT = GetPosition(targetObj);
 			local xP, yP, zP = GetPosition(localObj);
			local distance = GetDistance(targetObj);
 			local xV, yV, zV = xP - xT, yP - yT, zP - zT;	
 			local vectorLength = math.sqrt(xV^2 + yV^2 + zV^2)
			local xUV, yUV, zUV = (1/vectorLength)*xV, (1/vectorLength)*yV, (1/vectorLength)*zV;		
 			local moveX, moveY, moveZ = xT + xUV*30, yT + yUV*30, zT + zUV;	
			if (distance < 7 and IsInLineOfSight(targetObj)) then 
				if (script_grind.waitTimer ~= 0) then
					script_grind.waitTimer = GetTimeEX() + 1000;
				end
				Move(moveX, moveY, moveZ);
				self.timer = GetTimeEX() + 250;
 				return;
 			end
	end

	-- Pre Check
	if (IsChanneling() or IsCasting() or HasBuff(localObj, 'Ice Block')) then
		return;
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
			CastSpellByName('Ice Barrier');
			return;
		-- Check: If we have Cold Snap use it to clear the Ice Barrier CD
		elseif (HasSpell("Ice Barrier") and IsSpellOnCD("Ice Barrier") and HasSpell('Cold Snap') and 
			not IsSpellOnCD("Cold Snap") and not HasBuff(localObj, 'Ice Barrier')) then
				CastSpellByName('Cold Snap');
				return;
		end

		local pet = GetPet(); 
		local petHP = 0;
		if (pet ~= nil and pet ~= 0) then petHP = GetHealthPercentage(pet); end

		-- Summon Elemental
		if (HasSpell("Summon Water Elemental") and not IsSpellOnCD("Summon Water Elemental") and not (petHP > 0)) then
			CastSpellByName("Summon Water Elemental");
			return;
		end
		
		--Opener
		if (not IsInCombat()) then
			
			if (not IsInCombat()) and (not self.useRotation) and (HasSpell("Frostbolt"))
				and (IsSpellInRange(self.target, "Frostbolt")) and (GetDistance(self.target) <= 27) then
				if (IsMoving()) then
					StopMoving();
					return true;
				end
			end

			--Cast Spell
			if (localMana >= 10) then
				if (Cast('Frostbolt', targetGUID)) then
					script_grind.waitTimer = GetTimeEX() + 3000;
					return;
				end
			end

			if (localMana >= 10) then
				if (Cast('Fireball', targetGUID)) then
					script_grind.waitTimer = GetTimeEX() + 3000;
					return;
				end
			end
			
		-- Combat
		else	
			-- Use Mana Gem when low on mana
			if (localMana < self.manaGemMana and GetTimeEX() > self.gemTimer) then
				for i=0,self.numGem do
					if(HasItem(self.manaGem[i])) then
						UseItem(self.manaGem[i]);
						self.gemTimer = GetTimeEX() + 120000;
						return;
					end
				end
			end
			
			if (targetHealth <= 15 or targetHealth >= 65) and (HasSpell('Fire Blast')) and (self.useFireBlast) then
				if (Cast('Fire Blast', targetGUID)) then
					return;
				end
			end
	
			-- Check: Frostnova when the target is close
			if (self.useFrostNova) and (GetDistance(targetObj) < 5 and not script_target:hasDebuff("Frostbite") and HasSpell("Frost Nova") and not IsSpellOnCD("Frost Nova") and targetHealth > 12) then
				self.message = "Frost nova the target(s)...";
				CastSpellByName("Frost Nova");
				return;
			end

			-- Use Evocation if we have low Mana but still a lot of HP left
			if (localMana < self.evocationMana and localHealth > self.evocationHealth and HasSpell("Evocation") and not IsSpellOnCD("Evocation")) then		
				self.message = "Using Evocation...";
				CastSpellByName("Evocation"); 
				return;
			end

			-- Use Mana Shield if mana > 35 procent mana and no active Ice Barrier
			if (not HasBuff(localObj, 'Ice Barrier') and HasSpell('Mana Shield') and localMana > 35 and 
				not HasBuff(localObj, 'Mana Shield') and GetDistance(targetObj) < 15) then
				if (not script_target:hasDebuff('Frost Nova') and not script_target:hasDebuff('Frostbite')) then
					CastSpellByName('Mana Shield');
					return;
				end
			end
			
			-- Ice Block
			if (HasSpell('Ice Block') and not IsSpellOnCD('Ice Block') and 
				localHealth < self.iceBlockHealth and localMana < self.iceBlockMana) then
				self.message = "Using Ice Block...";
				CastSpellByName('Ice Block');
				return;
			end

			
			local max = 0;
			local dur = 0;
			if (GetInventoryItemDurability(18) ~= nil) then
				dur, max = GetInventoryItemDurability(18);
			end

			if (self.useWand and dur > 0) then
				if (localMana <= 5 or targetHealth <= 5) then
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
			if (localMana < 5) and (not self.useRotation) then
				UnitInteract(targetObj);
				self.interactTimer = GetTimeEX() + 2500;
				
			elseif (localMana < 5) and (self.useRotation) then
				FaceTarget(targetObj);
				AutoAttack(targetObj);
			end

			--Cast Spell
			if (not IsMoving()) and (localMana >= 10) then
				if (Cast('Frostbolt', targetGUID)) then
					return;
				end
			end
			
			-- Fireball at level 1
			if (not IsMoving()) and (not HasSpell("Frostbolt")) and (localMana >= 20) then
				if (Cast('Fireball', targetGUID)) then
					return;
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
	
	--Create Water
	local waterIndex = -1;
	for i=0,self.numWater do
		if (HasItem(self.water[i])) then
			waterIndex = i;
			break;
		end
	end
	
	if (waterIndex == -1) then 
		if (HasSpell('Conjure Water') and not AreBagsFull()) then
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
				if (CastSpellByName('Conjure Water')) then
					script_grind.waitTimer = GetTimeEX() + 1650;
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
			if (CastSpellByName('Conjure Food')) then
				self.waitTimer = GetTimeEX() + 1650;
				script_grind.waitTimer = GetTimeEX() + 1650;
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
				CastSpellByName('Conjure Mana Ruby')
				script_grind:restOn();
				return;
			elseif (HasSpell('Conjure Mana Citrine')) then
				CastSpellByName('Conjure Mana Citrine')
				script_grind:restOn();
				return;
			elseif (HasSpell('Conjure Mana Jade')) then
				CastSpellByName('Conjure Mana Jade')
				script_grind:restOn();
				return;
			elseif (HasSpell('Conjure Mana Agate')) then
				CastSpellByName('Conjure Mana Agate')
				script_grind:restOn();
				return;
			end
		end
	end

	--Eat and Drink
	if (not IsDrinking() and localMana < self.drinkMana) then
		if (IsMoving()) then
			StopMoving();
			script_grind:restOn();
			return true;
		end

		if(script_helper:drinkWater()) then
			self.waitTimer = GetTimeEX() + 1500;
			script_grind.waitTimer = GetTimeEX() + 1500;
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
			self.waitTimer = GetTimeEX() + 1500;
			script_grind.waitTimer = GetTimeEX() + 1500;
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

	-- Do Buff
	if (Buff('Arcane Intellect', localObj)) then
		self.waitTimer = GetTimeEX() + 1650;
		script_grind.waitTimer = GetTimeEX() + 1650;
		return true;
	elseif (Buff('Dampen Magic', localObj)) then
		self.waitTimer = GetTimeEX() + 1650;
		script_grind.waitTimer = GetTimeEX() + 1650;
		return true;
	end
	if (HasSpell('Ice Armor')) then
		if (Buff('Ice Armor', localObj)) then
			self.waitTimer = GetTimeEX() + 1650;
			script_grind.waitTimer = GetTimeEX() + 1650;
			return true;
		end
	
	else
		if (Buff('Frost Armor', localObj)) then
			self.waitTimer = GetTimeEX() + 1650;
			script_grind.waitTimer = GetTimeEX() + 1650;
			return true;
		end
	end
	
	script_grind:restOff();
	return false;
end


function script_mage:menu()

	local localObj = GetLocalPlayer();
	if (CollapsingHeader('Mage Combat Options')) then
		local wasClicked = false;	
		Text('Skills options:');
		Separator();

		if (GetInventoryItemDurability(18) ~= nil) then
			wasClicked, self.useWand = Checkbox('Use Wand', self.useWand);
		end

		if (HasSpell("Fire Blast")) then
			wasClicked, self.useFireBlast = Checkbox('Use Fire Blast', self.useFireBlast);
		end

		--if (script_path.raycastPathing) then
		--	self.frostNova = false;
		--end

		if (HasSpell("Frost Nova")) then
			SameLine();
			wasClicked, self.useFrostNova = Checkbox("Use Frost Nova", self.useFrostNova);
		end

		if (HasSpell("Mana Shield")) then
			wasClicked, self.useManaShield = Checkbox('Use Mana Shield', self.useManaShield);
		end

		if (HasSpell("Evocation")) then
			Separator();
			Text('Evocation above health percent');
			self.evocationHealth = SliderInt('EH', 1, 90, self.evocationHealth);
			Text('Evocation below mana percent');
			self.evocationMana = SliderInt('EM', 1, 90, self.evocationMana);
		end

		if (HasSpell("Ice Block")) then
			Text('Ice Block below health percent');
			self.iceBlockHealth = SliderInt('IBH', 5, 90, self.iceBlockHealth);
			Text('Ice Block below mana percent');
			self.iceBlockMana = SliderInt('IBM', 5, 90, self.iceBlockMana);
		end

		if (HasSpell("Mana Gem")) then
			Text('Mana Gem below mana percent');
			self.manaGemMana = SliderInt('MG', 1, 90, self.manaGemMana);
		end
	end

end