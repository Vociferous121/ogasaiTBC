script_paladinEX = {
	isSetup = false
}

function script_paladinEX:setup()
	-- Sort Aura  
	if (not HasSpell('Retribution Aura') and not HasSpell('Sanctity Aura')) then
		script_paladin.aura = 'Devotion Aura';	
	elseif (not HasSpell('Sanctity Aura') and HasSpell('Retribution Aura')) then
		script_paladin.aura = 'Retribution Aura';
	elseif (HasSpell('Sanctity Aura')) then
		script_paladin.aura = 'Sanctity Aura';	
	end

	-- Sort Blessing  
	if (HasSpell('Blessing of Wisdom')) then
		script_paladin.blessing = 'Blessing of Wisdom';
	elseif (HasSpell("Blessing of Might")) then
		script_paladin.blessing = 'Blessing of Might';
	end

	-- Set pull range
	script_grind.pullDistance = 4;

	DEFAULT_CHAT_FRAME:AddMessage('script_paladinEX: loaded...');

	self.isSetup = true;
end

function script_paladinEX:isBuff(buff)
	for i=1,40 do
  		local name, icon, _, _, _, etime = UnitBuff("player", i);
  		if name == buff and name ~= nil then
    			return true;
  		end
	end
	
	return false;
end

function script_paladinEX:meleeAttack(targetGUID)
	targetObj = GetGUIDTarget(targetGUID);

	local targetHealth = GetHealthPercentage(targetObj);
	local localMana = GetManaPercentage(GetLocalPlayer());

	if ((IsCasting(targetObj) or IsFleeing(targetObj)) and HasSpell('Hammer of Justice') and not IsSpellOnCD('Hammer of Justice')) and (localMana >= 10) then
		if (not Cast('Hammer of Justice', targetGUID)) then
			self.hJtime = GetTimeEX() + 4000;
			script_paladin:setTimers(1550);
			return true;
		end
	end

	if (HasSpell('Hammer of Wrath') and not IsSpellOnCD('Hammer of Wrath') and targetHealth < 20) and (localMana >= 10) then
		if (not Cast('Hammer of Wrath', targetGUID)) then
			script_paladin:setTimers(1550);
			return true;
		end
	end

	-- Combo Check 1: Stun the target if we have HoJ and SoC
	if (HasSpell('Hammer of Justice') and not IsSpellOnCD('Hammer of Justice') and targetHealth > 50 and script_paladinEX:isBuff('Seal of Command') and localMana > 50 and not IsSpellOnCD('Judgement')) then
		if (not Cast('Hammer of Justice', targetGUID)) then
			script_paladin:setTimers(1550);
			return true;
		end
	end
		
	-- Combo Check 2: Use Judgement on the stunned target
	if (script_paladinEX:isBuff('Seal of Command') and GetDistance(targetObj) < 10 and script_target:hasDebuff("Hammer of Justice")) and (localMana >= 10) then
		if (not CastSpellByName('Judgement')) then
			script_paladin:setTimers(1550);
			return true;
		end
	end

	-- Check: Seal of the Crusader until we used judgement
	if (not script_target:hasDebuff("Judgement of the Crusader") and targetHealth > 20 and (localMana >= 10)
		and not script_paladinEX:isBuff("Seal of the Crusader") and HasSpell('Seal of the Crusader')) then
		if (not CastSpellByName('Seal of the Crusader')) then
			script_paladin:setTimers(1550);
			return true;
		end
	end 

	-- Check: Judgement when we have crusader
	if (GetDistance(targetObj) < 10  and script_paladinEX:isBuff('Seal of the Crusader') and
		not IsSpellOnCD('Judgement') and HasSpell('Judgement')) and (localMana >= 10) then
		if (not CastSpellByName('Judgement')) then
			script_paladin:setTimers(1550);
			return true;
		end
	end

	-- Check: Seal of Righteousness (before we have SoC)
	if (not script_paladinEX:isBuff("Seal of Righteousness") and not script_paladinEX:isBuff("Seal of the Crusader") and not HasSpell('Seal of Command')) and (localMana >= 10) then 
		if (not CastSpellByName('Seal of Righteousness')) then
			script_paladin:setTimers(1550);
			return true;
		end
	end

	-- Check: Judgement with Righteousness or Command if we have a lot of mana
	if ((script_paladinEX:isBuff("Seal of Righteousness") or script_paladinEX:isBuff("Seal of Command"))
		 and not IsSpellOnCD('Judgement') and localMana > 80) then 
		if (not CastSpellByName('Judgement')) then
			script_paladin:setTimers(1550);
			return true; 
		end
	end

	-- Check: Use judgement if we are buffed with Righteousness or Command and the target is low
	if ((script_paladinEX:isBuff('Seal of Righteousness') or script_paladinEX:isBuff('Seal of Command'))
		and GetDistance(targetObj) < 10 and (targetHealth < 25 or targetHealth > 55)) and (localMana >= 10) then
		if (not Cast('Judgement', targetGUID)) then
			script_paladin:setTimers(1550);
			return true;
		end
	end

	-- Check: Seal of Command
	if (not script_paladinEX:isBuff("Seal of Command") and not script_paladinEX:isBuff("Seal of the Crusader")) and (localMana >= 10) then 
		if (not CastSpellByName('Seal of Command')) then
			script_paladin:setTimers(1550);
			return true;
		end
	end

	if (localMana >= 10) then
		if (not Cast("Crusader Strike", targetGUID)) then
			script_paladin:setTimers(1550);
			return true;
		end 
	end

	return false;
end