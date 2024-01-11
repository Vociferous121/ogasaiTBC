script_warlock = {
	version = '1.0 by Vociferous',
	message = 'Warlock Combat Script',
	warlockDOTS = include("scripts\\combat\\script_warlockDOTS.lua"),
	drinkMana = 50,
	eatHealth = 50,
	isSetup = false,
	waitTimer = 0,
	healthStone = {},
	numStone = 0,
	stoneHealth = 40,
	useWand = true,
	corruptionCastTime = 0,
	siphonTime = 0,
	agonyTime = 0,
	corruptTime = 0,
	immoTime = 0,
	useFelguard = false,
	useVoid = false,
	useImp = false,
	useLifeTap = true,
	stoneTime = 0,
	useRotation = false,
	useWandHealth = 15,
	useWandMana = 10,
	corruptionCastTime = 2,
	useCorruption = true,
	useImmolate = true,
	useDrainLife = true,
	useSiphonLife = true,
	useCurseOfAgony = true,
	lifeTapMana = 75,
	lifeTapHealth = 80,
}

function script_warlock:addHealthStone(name)
	self.healthStone[self.numStone] = name;
	self.numStone = self.numStone + 1;
end

function script_warlock:setup()

	script_warlock:addHealthStone('Master Healthstone');
	script_warlock:addHealthStone('Major Healthstone');
	script_warlock:addHealthStone('Greater Healthstone');
	script_warlock:addHealthStone('Healthstone');
	script_warlock:addHealthStone('Lesser Healthstone');
	script_warlock:addHealthStone('Minor Healthstone');

	script_warlock.waitTimer = GetTimeEX();
	script_warlocksiphonTime = GetTimeEX();
	script_warlockagonyTime = GetTimeEX();
	script_warlockcorruptTime = GetTimeEX();
	script_warlockimmoTime = GetTimeEX();
	script_warlockstoneTime = GetTimeEX();

	local level = GetLevel(GetLocalPlayer());
	if (level == 10) then
		self.corruptionCastTime = 1600;
	end
	if (level >= 11) then
		self.corruptionCastTime = 1500;
	end

	if (HasSpell("Summon Imp")) and (not HasSpell("Summon Voidwalker")) then
		self.useImp = true;
	end
	if (HasSpell("Summon Voidwalker")) and (not HasSpell("Summon Felguard")) then
		self.useVoid = true;
	end
	if (HasSpell("Summon Felguard")) then
		self.useFelguard = true;
	end

	DEFAULT_CHAT_FRAME:AddMessage('script_warlock: loaded...');

	self.isSetup = true;
end

function script_warlock:run(targetObj)

	if(not self.isSetup) then
		script_warlock:setup();
		return;
	end

	if (targetObj == 0) or (IsDead(targetObj)) then
		targetObj = GetTarget();
	end

	local targetGUID = GetTargetGUID(targetObj);

	local localObj = GetLocalPlayer();
	local localMana = GetManaPercentage(localObj);
	local localHealth = GetHealthPercentage(localObj);
	local localLevel = GetLevel(localObj);

	local hasPet = false;
	if(GetPet() ~= 0) then
		hasPet = true;
	end

	-- Check: Do we have a pet?
	local pet = GetPet(); local petHP = 0;
	if (pet ~= nil and pet ~= 0) then
		petHP = GetHealthPercentage(pet);
	end

	-- Pre Check
	if (IsChanneling() or IsCasting() or self.waitTimer > GetTimeEX() + (script_grind.tickRate*1000)) then
		return;
	end

	-- force bot to attack pets target
	local playerHasTarget = GetUnitsTarget(GetLocalPlayer());
	local petHasTarget = GetUnitsTarget(GetPet());
	if (GetNumPartyMembers() == 0) and (IsInCombat()) and (GetPet() ~= 0 and GetHealthPercentage(GetPet()) >= 1) and (playerHasTarget == 0) then
		if (petHasTarget ~= 0) then
			if (GetDistance(GetPet()) > 10) then
				AssistUnit("pet");
				PetFollow();
			end
		elseif (petHasTarget == 0) then
			AssistUnit("pet");
			self.message = "Stuck in combat! WAITING!";
			return;
		end
	end
	

	-- Use Soul Link
	if (HasSpell('Soul Link')) and (not HasBuff(localObj, 'Soul Link')) and (petHP > 0) then
		if (CastSpellByName('Soul Link')) then
			self.waitTimer = GetTimeEX() + 1550;
			return true;
		end
	end	
	
	--Valid Enemy
	if (targetObj ~= 0) then

	--script_warlockDOTS:corruption(targetObj);

		
		-- Cant Attack dead targets
		if (IsDead(targetObj)) then
			return;
		end
		if (not CanAttack(targetObj)) then
			return;
		end
		
		targetHealth = GetHealthPercentage(targetObj);

		-- Check: When channeling, cancel Health Funnel when low HP
		if (hasPet) then
			if (HasBuff(GetPet(), "Health Funnel") and localHealth < 40) and (not self.useRotation) then
				local _x, _y, _z = GetPosition(localObj);
				if (MoveToTarget(_x + 1, _y + 1, _z)) then
					self.waitTimer = GetTimeEX() + 500;
					return true;
				end
			end
		end

		if (GetPet() ~= 0) and (GetHealthPercentage(GetPet()) > 1) then
			if (IsInCombat()) and (not IsInLineOfSight(targetObj) or not IsInLineOfSight(GetPet())) then
				PetFollow();
				return;
	
			end
		end

		--Opener
		if (not IsInCombat()) then
			if (GetUnitsTarget(GetLocalPlayer()) ~= 0) then
				PetAttack();
			end
			if (HasSpell('Unstable Affliction')) and (not script_target:hasDebuff("Unstable Affliction")) then
				if (Cast("Unstable Affliction", targetGUID)) then
					if (GetPet() ~= nil) then
						PetAttack();
					end
					self.waitTimer = GetTimeEX() + 1550;
					return true;
				end
			end
			if (self.useSiphonLife) and (HasSpell("Siphon Life")) and (not script_target:hasDebuff("Siphon Life")) then
				if (Cast("Siphon Life", targetGUID)) then
					if (GetPet() ~= nil) then
						PetAttack();
					end
					FaceTarget(targetObj);
					self.waitTimer = GetTimeEX() + 1550;
					return true;
				end
			end
			if (self.useCurseOfAgony) and (HasSpell("Curse of Agony"))  and (not script_target:hasDebuff("Curse of Agony")) then
				if (Cast('Curse of Agony', targetGUID)) then
					if (GetPet() ~= nil) then
						PetAttack();
					end
					FaceTarget(targetObj);
					self.waitTimer = GetTimeEX() + 1550;
					return true;
				end
			end
			if (self.useImmolate) and (HasSpell("Immolate")) and (GetTimeEX() > self.immoTime) then
				if (not IsSpellOnCD("Immolate")) and (not IsCasting()) and (not IsChanneling()) and (not IsInCombat()) and (GetHealthPercentage(targetObj) >= 100) and (not script_target:hasDebuff("Immolate")) and (not IsMoving()) and (IsInLineOfSight(targetObj)) then
					FaceTarget(targetObj);
					CastSpellByName('Immolate');
					if (GetPet() ~= nil) then
						PetAttack();
					end;
					if (IsCasting()) then
						self.waitTimer = GetTimeEX() + 2050;
						script_grind:setWaitTimer(2500);
					end
				end
			end

			if (Cast('Shadow Bolt', targetGUID)) and (not IsSpellOnCD("Shadow Bolt")) then
				FaceTarget(targetObj);
				if (GetPet() ~= nil) then
					PetAttack();
				end
				self.waitTimer = GetTimeEX() + 2550;
				return true;
			end

		-- Combat
		else	
			-- Set the pet to attack
			if (hasPet) and (GetUnitsTarget(GetLocalPlayer()) ~= 0) then
				PetAttack();
			end

			-- if pet goes too far then recall
			if (GetPet() ~= 0 and self.hasPet and GetHealthPercentage(GetPet()) > 1) and (self.useVoid or self.useImp or self.useSuccubus or self.useFelhunter) and (GetDistance(GetPet()) > 40) then
				PetFollow();
			end


			-- Amplify Curse on CD
			if (HasSpell("Amplify Curse")) and (not IsSpellOnCD("Amplify Curse")) and (GetUnitsTarget(localObj) ~= 0) then
				if (CastSpellByName("Amplify Curse")) then
					self.waitTimer = GetTimeEX() + 1550;
					script_warlock:petAttack();
					return true;
				end
			end

			-- Check: If we got Nightfall buff then cast Shadow Bolt
			if (HasBuff(localObj, "Shadow Trance")) then
				if (Cast('Shadow Bolt', targetGUID)) then
					self.waitTimer = GetTimeEX() + 2550;
					return true;
				end
			end	

			-- Use Healthstone
			if (localHealth < self.stoneHealth and self.stoneTime < GetTimeEX()) then
				for i=0,self.numStone do
					if(HasItem(self.healthStone[i])) then
						if (UseItem(self.healthStone[i])) then
							self.stoneTime = GetTimeEX() + 125000;
							self.waitTimer = GetTimeEX() + 1550;
							return true;
						end
					end
				end
			end

			-- Check: If we don't got a soul shard, try to make one
			if (targetHealth < 25) and (HasSpell("Drain Soul")) and (not script_warlock:haveSoulshard()) then
				if (Cast('Drain Soul', targetGUID)) then
					self.waitTimer = GetTimeEX() + 1550;
					return true;
				end
			end

			-- Check: Heal the pet if it's below 50 perc and we are above 50 perc
			local petHP = 0; 
			if (hasPet) then
				local petHP = GetHealthPercentage(GetPet());
			end
			if (hasPet and petHP > 0 and petHP < 50 and HasSpell("Health Funnel") and localHealth > 50) then
				if (GetDistance(GetPet()) > 20 or not IsInLineOfSight(GetPet())) and (not self.useRotation) then
					if (MoveToTarget(GetPet())) then
						script_grind.waitTimer = GetTimeEX() + 2000;
						self.waitTimer = GetTimeEX() + 2000;
						return true;
					end
				else
					StopMoving();
				end
				if (CastSpellByName("Health Funnel")) then
					self.waitTimer = GetTimeEX() + 1550;
					return true;
				end
			end

			local max = 0;
			local dur = 0;
			if (GetInventoryItemDurability(18) ~= nil) then
				dur, max = GetInventoryItemDurability(18);
			end

			if (self.useWand and dur > 0) then
				if (localMana <= self.useWandMana or targetHealth <= self.useWandHealth) then
					if (not script_target:autoCastingWand()) then 
						FaceTarget(targetObj);
						CastSpell("Shoot", targetObj);
						self.waitTimer = GetTimeEX() + 500; 
						return;
					end
					return;
				end
			end

			-- Check: Keep Siphon Life up (30 s duration)
			if (self.useSiphonLife) then
				if (not script_target:hasDebuff('Siphon Life') and self.siphonTime < GetTimeEX() and targetHealth > 20) then
					FaceTarget(targetObj);
					if (Cast('Siphon Life', targetGUID)) then
						self.siphonTime = GetTimeEX()+5000;
						self.waitTimer = GetTimeEX() + 1550;
						return true;
					end
				end
			end

			-- Check: Keep the Curse of Agony up (24 s duration)
			if (self.useCurseOfAgony) then
				if (not script_target:hasDebuff('Curse of Agony') and self.agonyTime < GetTimeEX() and targetHealth > 20) then
					FaceTarget(targetObj);
					if (Cast('Curse of Agony', targetGUID)) then
						self.agonyTime = GetTimeEX()+5000;
						self.waitTimer = GetTimeEX() + 1550;
						return true;
					end
				end
			end
			-- Check: Keep the Corruption DoT up (15 s duration)
			if (self.useCorruption) then
			if (not script_target:hasDebuff('Corruption') and self.corruptTime < GetTimeEX() and targetHealth > 20) then
				FaceTarget(targetObj);
				if (Cast('Corruption', targetGUID)) then
					self.corruptTime = GetTimeEX()+5000;
					self.waitTimer = GetTimeEX() + self.corruptionCastTime;
					if (IsCasting()) then
						script_grind:setWaitTimer(2000);
					end
				return true;
				end
			end
			end

			-- Check: Keep the Immolate DoT up (15 s duration)
			if (self.useImmolate) then
			if (not script_target:hasDebuff('Immolate') and self.immoTime < GetTimeEX() and targetHealth > 20) then
				FaceTarget(targetObj);
				if (Cast('Immolate', targetGUID)) then
					self.immoTime = GetTimeEX()+5000;
					self.waitTimer = GetTimeEX() + 2050;
					if (IsCasting()) then
						script_grind:setWaitTimer(2000);
					end
				return true;
				end
			end
			end
	
			
			-- life tap in combat
			if self.useLifeTap and HasSpell("Life Tap") and not IsSpellOnCD("Life Tap") and localHealth > 35 and localMana < 15 then
				if (not IsSpellOnCD("Life Tap")) then
					if (not CastSpellByName("Life Tap")) then
					self.waitTimer = GetTimeEX() + 1550;
					script_grind.waitTimer = GetTimeEX() + 1650;
					self.message = "Using Life Tap!";
					return true;
					end
				end
			end

			-- Cast: Drain Life, don't use Drain Life if we need a soul shard
			if (self.useDrainLife) then
			if (HasSpell("Drain Life") and script_warlock:haveSoulshard() and GetCreatureType(targetObj) ~= "Mechanic") then
				if (GetDistance(targetObj) < 20) then
					if (IsMoving()) then
						StopMoving();
						return;
					end
					if (Cast('Drain Life', targetGUID)) then
						self.waitTimer = GetTimeEX() + 1550;
						return;
					end
				else
					if (not self.useRotation) then
						MoveToTarget(targetObj); 
						return;
					end
				end
			end
			end
			-- Cast: Shadow Bolt
			if (localMana >= 10) and (GetHealthPercentage(targetObj) >= 5) then
				if (Cast('Shadow Bolt', targetGUID)) then
					self.waitTimer = GetTimeEX() + 2550;
				end
			end
			-- Auto Attack if no mana
			if (localMana < 10) then
				if (not self.useRotation) then
					UnitInteract(targetObj);
					AutoAttack(targetObj);
				elseif (self.useRotation) then
					AutoAttack(targetObj);
				end
			end
		return;
		end
	end
end

function script_warlock:lifeTap(localHealth, localMana)
	if (localMana < localHealth and self.useLifeTap) then
		if (HasSpell("Life Tap") and localHealth > 50 and localMana < 90 and not IsInCombat())
			or (HasSpell("Life Tap") and localHealth > 60 and localMana < 30 and IsInCombat()) and (IsSpellOnCD("Life Tap")) then
				script_grind.tickRate = 0;
				if (CastSpellByName("Life Tap")) then
					return true;
				end
			
		end
	end
	return false;
end


function script_warlock:haveSoulshard()
	for i = 0,4 do 
		for y=0,GetContainerNumSlots(i) do 
			if (GetContainerItemLink(i,y) ~= nil) then
				local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType,
   				itemStackCount, itemEquipLoc, itemTexture = GetItemInfo(GetContainerItemLink(i,y));
				if (itemName == "Soul Shard") then
					return true;
				end
			end
		end 
	end
	return false;
end

function script_warlock:rest()
	if(not self.isSetup) then
		script_warlock:setup();
		return true;
	end

	if (self.waitTimer > GetTimeEX() or IsCasting() or IsChanneling()) then
		return;
	end

	local localObj = GetLocalPlayer();
	local localMana = GetManaPercentage(localObj);
	local localHealth = GetHealthPercentage(localObj);

	-- Check: Do we have a pet?
	local pet = GetPet(); local petHP = 0;
	local hasPet = false;
	if (pet ~= nil and pet ~= 0) then
		hasPet = true;
		petHP = GetHealthPercentage(pet);
	end

	-- Update rest values
	if (script_grind.restHp ~= 0) then
		self.eatHealth = script_grind.restHp;
	end
	if (script_grind.restMana ~= 0) then

		self.drinkMana = script_grind.restMana;

		if (GetLevel(GetLocalPlayer()) >= 10) then
			script_grind.restMana = 35;
			self.drinkMana = 35;
		end
	end

	-- Cast: Life Tap if conditions are right
	if (self.useLifeTap) and (localMana < self.lifeTapMana) and (HasSpell("Life Tap")) and (localHealth > self.lifeTapHealth) then
		if (not IsInCombat()) and (not IsEating()) and (not IsDrinking()) and (IsStanding()) then
			if (not IsSpellOnCD("Life Tap")) then
				script_grind.tickRate = 0;
				if (CastSpellByName("Life Tap")) then
					--self.waitTimer = GetTimeEX() + 1550;
					--script_grind.waitTimer = GetTimeEX() + 1650;
					return;
				end
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

	-- Check: If the pet is an Imp, require Firebolt to be in slot 4
	local petIsImp = false;
	local petIsVoid = false;
	if (hasPet) then
		name, __, __, __, __, __, __ = GetPetActionInfo(4);
		if (name == "Firebolt") then
			petIsImp = true;
		end
		if (name == "Torment") then
			petIsVoid = true;
		end
	end
	
	-- Check: Summon our Demon if we are not in combat (Voidwalker is Summoned in favor of the Imp)
	if (not IsEating() and not IsDrinking() and not IsMounted() and not hasPet) then

		local localMana = GetManaPercentage(GetLocalPlayer());

		if ((not hasPet or petIsVoid or petIsImp) and self.useFelguard and HasSpell('Summon Felguard') and script_warlock:haveSoulshard()) then
			if (not IsStanding() or IsMoving()) then
				StopMoving();
			end
			if (localMana > 40) then
				if (not CastSpellByName("Summon Felguard")) then
					script_path.savedPos['time'] = GetTimeEX();
					self.waitTimer = GetTimeEX() + 12000;
					script_grind:restOn();
					return true;
				end
			end
		end
		if ((not hasPet or petIsImp) and self.useVoid and HasSpell("Summon Voidwalker") and HasItem("Soul Shard")) then
			if (not IsStanding() or IsMoving()) then
				StopMoving();
			end
			if (localMana > 40) then
				if (CastSpellByName("Summon Voidwalker")) then
					script_path.savedPos['time'] = GetTimeEX();
					self.waitTimer = GetTimeEX() + 12000;
					script_grind:restOn();
					return true;
				end
			end
		end
		if (not hasPet and HasSpell("Summon Imp")) and (GetPet() == 0) then
			if (not IsStanding() or IsMoving()) then
				StopMoving();
			end
			if (localMana > 30) and (not hasPet) and (GetPet() == 0) then
				if (not CastSpellByName("Summon Imp")) then
					script_path.savedPos['time'] = GetTimeEX();
					script_grind:restOn();
					self.waitTimer = GetTimeEX() + 12000;
					return true;
				end
			end
		end
	end

	--Create Healthstone
	local stoneIndex = -1;
	for i=0,self.numStone do
		if (HasItem(self.healthStone[i])) then
			stoneIndex= i;
			break;
		end
	end
	if (stoneIndex == -1 and HasItem("Soul Shard")) then 
		if (localMana > 10 and not IsDrinking() and not IsEating() and not AreBagsFull()) then
			if (HasSpell('Create Healthstone') and IsMoving()) then
				StopMoving();
				script_grind:restOn();
				return true;
			end
			if (HasSpell('Create Healthstone')) then
				CastSpellByName('Create Healthstone')
				script_grind:restOn();
				return true;
			end
		end
	end

	-- Do buffs if we got some mana 
	if (localMana > 30) then
		if(HasSpell("Demon Armor")) then
			if (not HasBuff(localObj, "Demon Armor")) then
				if (Buff("Demon Armor", localObj)) then
					self.waitTimer = GetTimeEX() + 1550;
					script_grind:restOn();
					return true;
				end
			end
		end
	end
	if (localMana > 30) then
		if (not HasSpell("Demon Armor")) and (not HasBuff(localObj, 'Demon Skin') and HasSpell('Demon Skin')) and (not IsSpellOnCD("Demon Skin")) then
			if (Buff('Demon Skin', localObj)) then
				self.waitTimer = GetTimeEX() + 1550;
				script_grind.waitTimer = GetTimeEX() + 2000;
				script_grind:restOn();
			end
		end
	end
	if (localMana > 30) then
		--if (HasSpell("Unending Breath")) then
			--if (not HasBuff(localObj, 'Unending Breath')) then
				--if (Buff('Unending Breath', localObj)) then
					--self.waitTimer = GetTimeEX() + 1550;
					--return true;
				--end
			--end
		--end
	end

	-- Check: Health funnel on the pet or wait for it to regen if lower than 70 perc
	local petHP = 0;
	if (GetPet() ~= 0) then
		petHP = GetHealthPercentage(GetPet());
	end
	if (hasPet and petHP > 0) then
		if (petHP < 70) then
			if (GetDistance(GetPet()) > 8) then
				PetFollow();
				self.waitTimer = GetTimeEX() + 1550; 
				script_grind:restOn();
				return true;
			end
			if (GetDistance(GetPet()) < 20 and localMana > 10) then
				if (hasPet and petHP < 70 and petHP > 0) then
					DEFAULT_CHAT_FRAME:AddMessage('script_Warlock: Pet health below 70 percent, resting...');
					if (HasSpell('Health Funnel')) then CastSpellByName('Health Funnel'); end
					self.waitTimer = GetTimeEX() + 1550; 
					script_grind:restOn();
					return true;
				end
			end
		end
	end

	
	script_grind:restOff();
	return false;
end

function script_warlock:menu()

	if (CollapsingHeader("Warlock Combat Menu")) then

		local wasClicked = false;
		
		if (HasSpell("Create Healthstone")) then
			Text("Use Healthstones below HP percent");
			self.stoneHealth = SliderFloat("HSHP", 1, 99, self.stoneHealth);
			Separator();
		end

		-- wand
		local max = 0;
		local dur = 0;
		if (GetInventoryItemDurability(18) ~= nil) then
			dur, max = GetInventoryItemDurability(18);
		end

		if (dur > 0) then
			wasClicked, self.useWand = Checkbox("Use Wand", self.useWand);
		end
		if (dur > 0) then
			SameLine();
		end

		-- life tap
		if (HasSpell("Life Tap")) then
			wasClicked, self.useLifeTap = Checkbox("Use Life Tap", self.useLifeTap);
		end

		-- drain life
		if (HasSpell("Drain Life")) then
			SameLine();
			wasClicked, self.useDrainLife = Checkbox("Use Drain Life", self.useDrainLife);
		end

		Separator();

		if (self.useFelguard) then
			self.useVoid = false;
			self.useImp = false;
		end
			
		if (self.useVoid) then
			self.useFelguard = false;
			self.useImp = false;
		end
		if (self.useImp) then
			self.useFelguard = false;
			self.useVoid = false;
		end

		if (HasSpell("Summon Imp")) then
			wasClicked, self.useImp = Checkbox("Use Imp", self.useImp);
		end
		if (HasSpell("Summon Voidwalker")) then
			SameLine();
			wasClicked, self.useVoid = Checkbox("Use Voidwalker", self.useVoid);
		end
		if (HasSpell("Summon Felguard")) then
			SameLine();
			wasClicked, self.useFelguard = Checkbox("Use Felguard", self.useFelguard);
		end
		
		
		if (CollapsingHeader("|+| DoT Options")) then
			if (HasSpell("Immolate")) then
				wasClicked, self.useImmolate = Checkbox("Use Immolate", self.useImmolate);
			end
			if (HasSpell("Corruption")) then
				SameLine();
				wasClicked, self.useCorruption = Checkbox("Use Corruption", self.useCorruption)
			end
			if(HasSpell("Curse of Agony")) then
				wasClicked, self.useCurseOfAgony = Checkbox("Use Agony", self.useCurseOfAgony);
			end
			if (HasSpell("Siphon Life")) then
				SameLine();
				wasClicked, self.useSiphonLife = Checkbox("Use Siphon Life", self.useSiphonLife);
			end			
		end

		if (self.useWand) then
			if (CollapsingHeader("|+| Wand Options")) then
				Text("Use Wand Below Target Health Percent");
				self.useWandHealth = SliderInt("Wand Health", 0, 100, self.useWandHealth);
				Text("Use Wand Below Self Mana Percent");
				self.useWandMana = SliderInt("Wand Mana", 0, 100, self.useWandMana);
			end
		end

		if (HasSpell("Life Tap")) and (self.useLifeTap) then
			if (CollapsingHeader("|+| Life Tap Options (out of combat)")) then
				Text("Use Life Tap Above Self Health Percent");
				self.lifeTapHealth = SliderInt("LTM", 1, 100, self.lifeTapHealth);
				Text("Use Life Tap Below Self Mana Percent");
				self.lifeTapMana = SliderInt("LTH", 1, 100, self.lifeTapMana);
			end
		end
	end
end

function script_warlock:summonPet()

	if (not IsEating() and not IsDrinking() and not IsMounted()) and (not IsCasting()) and (not IsChanneling()) then
			local localMana = GetManaPercentage(GetLocalPlayer());
			local hasPet = false;
			if(GetPet() ~= 0) then
				hasPet = true;
			end
			local petIsImp = false;
			local petIsVoid = false;
			if (hasPet) then
				name, __, __, __, __, __, __ = GetPetActionInfo(4);
				if (name == "Firebolt") then
					petIsImp = true;
				end
				if (name == "Torment") then
					petIsVoid = true;
				end
			end

			if ((not hasPet or petIsVoid or petIsImp)
				and script_warlock.useFelguard and HasSpell('Summon Felguard')
				and script_warlock:haveSoulshard()) then
				if (not IsStanding() or IsMoving()) then
					StopMoving();
				end
				if (localMana > 40) then
					if (not CastSpellByName("Summon Felguard")) then
						self.waitTimer = GetTimeEX() + 12000;
						script_path.savedPos['time'] = GetTimeEX() + 10000;
						script_grind:restOn();
						return true;
					end
				end
			end
			if ((not hasPet or petIsImp)
				and script_warlock.useVoid and HasSpell("Summon Voidwalker")
				and script_warlock:haveSoulshard()) then
				if (not IsStanding() or IsMoving()) then
					StopMoving();
				end
				if (localMana > 40) then
					if (not CastSpellByName("Summon Voidwalker")) then
						self.waitTimer = GetTimeEX() + 12000;
						script_path.savedPos['time'] = GetTimeEX() + 10000;
						script_grind:restOn();
						return true;
					end
				end
			end
			if (script_warlock.useImp) and (not hasPet and HasSpell("Summon Imp")) and (GetPet() == 0) then
				if (not IsStanding() or IsMoving()) then
					StopMoving();
				end
				if (localMana > 30) and (not hasPet) and (GetPet() == 0) then
					if (not CastSpellByName("Summon Imp")) then
						script_grind:restOn();
						self.waitTimer = GetTimeEX() + 12000;
						script_path.savedPos['time'] = GetTimeEX() + 10000;
						return true;
					end
				end
			end
		end
	return false;
end
