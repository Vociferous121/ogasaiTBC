script_shaman = {
	version = '0.1',
	message = 'Enhancement Combat',
	drinkMana = 50,
	eatHealth = 50,
	isSetup = false,
	waitTimer = 0,
	enhanceWeapon = 'Rockbiter Weapon',
	totem = 'no totem yet',
	totemBuff = '',
	healingSpell = 'Healing Wave',
	useRotation = false,
	useLightningBolt = false,
	useChainLightning = false,
	lightningBoltMana = 10,
	lightningBoltHealth = 10,
	chainLightningMana = 50,
}



function script_shaman:setup()

	self.waitTimer = GetTimeEX();
	script_shaman:setSpells();
	DEFAULT_CHAT_FRAME:AddMessage('script_shaman: loaded...');
	self.isSetup = true;
end

function script_shaman:setSpells()
	-- Set weapon enhancement
	if (HasSpell('Windfury Weapon')) then
		self.enhanceWeapon = 'Windfury Weapon';
	elseif (HasSpell('Flametongue Weapon')) then
		self.enhanceWeapon = 'Flametongue Weapon';
	end

	-- Set totem
	if (HasSpell('Strength of Earth Totem') and HasItem('Earth Totem')) then
		self.totem = 'Strength of Earth Totem';
		self.totemBuff = 'Strength of Earth';
	elseif (HasSpell('Grace of Air Totem') and HasItem('Air Totem')) then
		self.totem = 'Grace of Air Totem';
		self.totemBuff = 'Grace of Air';
	end

	-- Set healing spell
	if (HasSpell('Lesser Healing Wave')) then
		self.healingSpell = 'Lesser Healing Wave';
	end

	self.useLightningBolt = true;
end

-- Checks and apply enhancement on the meele weapon
function script_shaman:checkEnhancement()
	hasMainHandEnchant, _, _, _, _, _ = GetWeaponEnchantInfo();
	if (hasMainHandEnchant == nil) then 
		-- Apply enhancement
		if (HasSpell(self.enhanceWeapon)) then

			-- Check: Stop moving, sitting
			if (not IsStanding() or IsMoving()) then 
				StopMoving(); 
				return true;
			end 

			CastSpellByName(self.enhanceWeapon);
			self.message = "Applying " .. self.enhanceWeapon .. " on weapon...";
			script_shaman:setTimers(1550);
		else
			return false;
		end
		return true;
	end
	return false;
end

function script_shaman:setTimers(miliseconds)
	
	self.waitTimer = GetTimeEX() + miliseconds;
	script_grind.waitTimer = GetTimeEX() + miliseconds;

end

function script_shaman:run(targetObj)

	if(not self.isSetup) then
		script_shaman:setup();
	end

	local localObj = GetLocalPlayer();
	local localMana = GetManaPercentage(localObj);
	local localHealth = GetHealthPercentage(localObj);
	local localLevel = GetLevel(localObj);

	targetHealth = GetHealthPercentage(targetObj);

	if (targetObj == 0) then
		targetObj = GetTarget();
	end

	local targetGUID = GetTargetGUID(targetObj);

	-- Pre Check
	if (IsChanneling() or IsCasting() or self.waitTimer > GetTimeEX()) then
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
		
		-- Dismount
		DismountEX();
		
		--Opener
		if (not IsInCombat()) then

			-- Update enhancement spells/totems
			script_shaman:setSpells();
			
			-- Enhancement on weapon
			if (script_shaman:checkEnhancement()) then
				return true;
			end

			-- Pull with: Lighting Bolt
			if (self.useLightningBolt) and (localMana >= self.lightningBoltMana) and (targetHealth >= self.lightningBoltHealth) then
				if (Cast("Lightning Bolt", targetGUID)) then
					script_shaman:setTimers(2050);
					return true;
				end
			end

			-- Check move into meele range
			if (GetDistance(targetObj) > 5) and (not self.useRotation) and (not self.useLightningBolt or localMana <= 10 or script_grind.moveToMeleeRange) then
				if (script_grind.waitTimer ~= 0) then
					script_grind.waitTimer = GetTimeEX() + 1250;
				end
				MoveToTarget(targetObj);
				return;
			elseif  (not self.useLightningBolt or localMana <= 10) then
				FaceTarget(targetObj);
				AutoAttack(targetObj);
			end
			
			
		-- Combat
		else	

			-- Check: Lightning Shield
			if (HasSpell("Lightning Shield")) and (not HasBuff(localObj, 'Lightning Shield')) then
				if (Buff("Lightning Shield", localObj)) then
					script_shaman:setTimers(1550);
					return true;
				end
			end
			
			-- Earth Shock
			if (HasSpell("Earth Shock")) then
			local name, subText, text, texture, startTime, endTime, isTradeSkill, castID, notInterruptible = UnitCastingInfo("target");
				if (name ~= nil) then
					if (Cast("Earth Shock", targetGUID)) then
						script_shaman:setTimers(1550);
						return true;
					end
				end
			end

			-- If too far away move to the target then stop
			if (GetDistance(targetObj) > 5) and (not self.useRotation) and (not self.useLightningBolt or localMana <= 10 or script_grind.moveToMeleeRange) then
				if (script_grind.waitTimer ~= 0) then
					script_grind.waitTimer = GetTimeEX()+1250;
				end
				MoveToTarget(targetObj); 
				return; 
			elseif (not self.useRotation) and (not self.useLightningBolt or localMana <= 10 or script_grind.moveToMeleeRange) then
				if (IsMoving()) then 
					StopMoving(); 
				end 
			end 

			if (self.useLightningBolt) and (localMana >= 10) then
				if (not Cast("Lightning Bolt", targetGUID)) then
					script_shaman:setTimers(1550);
					return true;
				end
			end

			-- Check: If we are in meele range, do meele attacks
			if (GetDistance(targetObj) < 5) then
				
				FaceTarget(targetObj);
				AutoAttack(targetObj);

				-- Totem
				if (HasSpell(self.totem) and not HasBuff(localObj, self.totemBuff)) then
					if (CastSpellByName(self.totem)) then
						script_shaman:setTimers(1550);
					end
				end

				-- Stormstrike
				if (HasSpell('Stormstrike') and not IsSpellOnCD('Stormstrike')) then
					if (Cast("Stormstrike", targetGUID)) then
						script_shaman:setTimers(1550);
						return true;
					end
				end

				if (self.useLightningBolt) and (localMana >= 10) then
					if (Cast("Lightning Bolt", targetGUID)) then
						script_shaman:setTimers(1550);
						return true;
					end
				end
			end

			return;
			
		end
	
	end
end

function script_shaman:rest()

	if(not self.isSetup) then
		script_shaman:setup();
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

	-- Keep us buffed: Lightning Shield
	if (Buff("Lightning Shield", localObj)) then
		return true;
	end

	if (script_shaman:checkEnhancement()) then
		return true;
	end
	
	script_grind:restOff();
	return false;
end

function script_shaman:mount()

end

function script_shaman:menu()

	if (CollapsingHeader("[Shaman - Enhancement")) then
		local wasClicked = false;	
		Text("Should we walk into melee range or cast spells at range?");
		wasClicked, script_grind.moveToMeleeRange = Checkbox("Move To Melee Range", script_grind.moveToMeleeRange);
		Separator();
		wasClicked, self.useLightningBolt = Checkbox("Use Lightning Bolt", self.useLightningBolt);
		if (self.useLightningBolt) then
		Text("Use Lightning Bolt Above Self Mana");
		self.lightningBoltMana = SliderInt("LBM", 0, 100, self.lightningBoltMana);
		Text("Use Lightning Bolt Above Target Health");
		self.lightningBoltHealth = SliderInt("LBH", 0, 100, self.lightningBoltHealth);
		end
		Separator();
	end
end
