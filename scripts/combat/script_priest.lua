script_priest = {
	version = '0.1',
	priestEXLoaded = include("scripts\\combat\\script_priestEX.lua"),
	message = 'Priest Combat',
	drinkMana = 50,
	eatHealth = 50,
	isSetup = false,
	waitTimer = 0,
	renewHP = 90,
	shieldHP = 80,
	flashHealHP = 75,
	lesserHealHP = 60,
	healHP = 45,
	greaterHealHP = 20,
	useWand = true,
	wandMana = 10,
	useRotation = false,
	wandHealth = 10,
}

function script_priest:draw()

end

function script_priest:setup()

	self.waitTimer = GetTimeEX();

	script_grind.moveToMeleeRange = false;


	self.isSetup = true;

end

function script_priest:setTimers(miliseconds)
	
	self.waitTimer = GetTimeEX() + miliseconds;
	script_grind.waitTimer = GetTimeEX() + miliseconds;

end

function script_priest:healAndBuff(targetObject, localMana)

	local targetHealth = GetHealthPercentage(targetObject);

	if (self.waitTimer > GetTimeEX() or IsCasting() or IsChanneling()) then
		return;
	end
	
	-- Buff Fortitude
	if (localMana > 30 and not IsInCombat()) then
		if (Buff('Power Word: Fortitude', targetObject)) then
			script_priest:setTimers(1550);
			return true; 
		end
	end

	-- Renew
	if (localMana > 10 and targetHealth < self.renewHP and not HasBuff(targetObject, "Renew")) then
		if (Buff('Renew', targetObject)) then
			script_priest:setTimers(1550);
			return true;
		end
	end

	-- Shield
	if (localMana > 10 and targetHealth < self.shieldHP and not HasDebuff(targetObject, "Weakened Soul") and IsInCombat()) then
		if (Buff('Power Word: Shield', targetObject)) then 
			script_priest:setTimers(1550);
			return true; 
		end
	end

	-- Greater Heal
	if (localMana > 20 and targetHealth < self.greaterHealHP) then
		if (script_priest:heal('Heal', targetObject)) then
			script_priest:setTimers(1550);
			return true;
		end
	end

	-- Heal
	if (localMana > 15 and targetHealth < self.healHP) then
		if (script_priest:heal('Heal', targetObject)) then
			script_priest:setTimers(1550);
			return true;
		end
	end

	-- Lesser Heal
	if (localMana > 10 and targetHealth < self.lesserHealHP) then
		if (script_priest:heal('Lesser Heal', targetObject)) then
			script_priest:setTimers(1550);
			return true;
		end
	end

	-- Flash Heal
	if (localMana > 8 and targetHealth < self.flashHealHP) then
		if (script_priest:heal('Flash Heal', targetObject)) then
			script_priest:setTimers(1550);
			return true;
		end
	end
	
	return false;
end

function script_priest:heal(spellName, target, killTarget)
	if (HasSpell(spellName)) then 
		if (IsSpellInRange(target, spellName)) then 
			if (not IsSpellOnCD(spellName)) then 
				if (not IsAutoCasting(spellName)) then
					if (not IsMoving()) then
						TargetEnemy(target); 
						CastSpellByName(spellName); 
						-- Wait for global CD before next spell cast
						TargetEnemy(killTarget); 
						return true; 
					end
				end 
			end 
		end 
	end
	return false;
end


function script_priest:run(targetObj)
	if(not self.isSetup) then
		script_priest:setup();
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
	
	--Valid Enemy
	if (targetObj ~= 0) then
		
		-- Cant Attack dead targets
		if (IsDead(targetObj)) then
			return;
		end
		if (not CanAttack(targetObj)) then
			return;
		end
		
		targetHealth = GetHealthPercentage(targetObj);

		if (HasSpell("Shadowform") and not HasBuff(localObj, "Shadowform")) and (localMana >= 20) then
			CastSpellByName("Shadowform");
			script_priest:setTimers(1550);
			return true;
		end
		
		--Opener
		if (not IsInCombat()) then
			-- Auto Attack
			if (GetDistance(targetObj) < 40) then
				AutoAttack(targetObj);
			end
			
			-- Opener
	
			if (Cast('Devouring Plague', targetGUID)) and (localMana >= 10) then
				script_priest:setTimers(1550);
				return true;
			end

			-- Mind Blast
			if (Cast('Mind Blast', targetGUID)) and (localMana >= 10)then
				script_priest:setTimers(1550);
				return true;
			end

			if (not HasBuff(localObj, "Shadowform")) and (localMana >= 20) then
				if (Cast('Smite', targetGUID)) then
					script_priest:setTimers(1550);
					return true;
				end
			end
			
			return;

		-- Combat
		else	

			-- Desperate prayer
			if (HasSpell("Desperate Prayer") and not IsSpellOnCD("Desperate Prayer") and not HasBuff(localObj, "Shadowform")) then
				if (localHealth < 10) and (localMana >= 10) then
					CastSpellByName("Desperate Prayer");
					script_priest:setTimers(1550);
					return true;
				end
			end			

			-- Cant heal with while in shadowform, use shield
			if (not HasBuff(localObj, "Shadowform")) and (localMana >= 20) then	
				if (script_priest:healAndBuff(localObj, localMana)) then 
					script_priest:setTimers(550);
					return true; 
				end
			else
				-- Shield
				if (localMana > 10 and localHealth < self.shieldHP and not HasDebuff(localObj, "Weakened Soul")) then
					if (Buff('Power Word: Shield', localObj)) then 
						script_priest:setTimers(1550);
						return true; 
					end
				end
			end

			-- Check: Keep Shadow Word: Pain up
			if (not script_target:hasDebuff("Shadow Word: Pain")) and (localMana >= 10) then
				if (Cast('Shadow Word: Pain', targetGUID)) then 
					script_priest:setTimers(1550);
					return true; 
				end
			end

			-- Check: Keep Vampiric Embrace up
			if (not script_target:hasDebuff("Vampiric Embrace") and not IsSpellOnCD("Vampiric Embrace")) and (localMana >= 10) then
				if (Cast('Vampiric Embrace', targetGUID)) then 
					script_priest:setTimers(1550);
					return true; 
				end
			end

			-- Check: Keep Vampiric Touch up
			if (not script_target:hasDebuff("Vampiric Touch")) and (localMana >= 10) then
				if (Cast('Vampiric Touch', targetGUID)) then 
					script_priest:setTimers(1550);
					return true; 
				end
			end

			-- Wand if low mana or target is low
			local max = 0;
			local dur = 0;
			if (GetInventoryItemDurability(18) ~= nil) then
				dur, max = GetInventoryItemDurability(18);
			end

			if (self.useWand and dur > 0 and (localMana < self.wandMana or targetHealth <= self.wandHealth)) then

				if (not script_target:autoCastingWand()) then 
					self.message = "Using wand...";
					FaceTarget(targetObj);
					CastSpell("Shoot", targetObj);
					self.waitTimer = GetTimeEX() + 500; 
					return;
				end
				
				return;
			end

			-- Auto Attack if no mana
			if (localMana < 10) then
				if (not self.useRotation) then
					UnitInteract(targetObj);
				elseif (self.useRotation) then
					FaceTarget(targetObj);
					AutoAttack(targetObj);
				end
			end

			-- Cast: Mind Blast
			if (Cast('Mind Blast', targetGUID)) and (localMana >= 10) then
				script_priest:setTimers(1550);
				return true; 
			end

			-- Mind Flay
			if (GetDistance(targetObj) < 20) then
				if (Cast('Mind Flay', targetGUID)) and (localMana >= 10) then 
					script_priest:setTimers(1550);
					return true; 
				end
			end

			-- Cast: Smite (last choice e.g. at level 1)
			if (not HasBuff(localObj, "Shadowform")) and (localMana >= 10) then
				if (Cast('Smite', targetGUID)) then 
					script_priest:setTimers(1550);
					return true; 
				end
			end
			
			return;	
		end
	
	end
end

function script_priest:rest()
	if(not self.isSetup) then
		script_priest:setup();
		return true;
	end

	local localObj = GetLocalPlayer();
	local localMana = GetManaPercentage(localObj);
	local localHealth = GetHealthPercentage(localObj);

	if (self.waitTimer > GetTimeEX() or IsCasting() or IsChanneling()) then
		return;
	end

	if (localHealth < self.eatHealth and HasBuff(localObj, "Shadowform")) then
		CastSpellByName("Shadowform");
		script_priest:setTimers(1550);
		script_grind:restOn();
		return true;
	end

	if (not HasBuff(localObj, "Shadowform")) then
		if (script_priest:healAndBuff(localObj, localMana)) then
			script_priest:setTimers(550); 
			script_grind:restOn();
			return true;
		end
	end

	if (GetLevel(GetLocalPlayer()) < 6) then
		script_grind.restMana = 10;
	end
	
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
			script_priest:setTimers(1550);
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
			script_priest:setTimers(1550);
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
