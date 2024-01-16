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

	if (script_checkDebuffs:hasDisabledMovement()) or (script_checkDebuffs:hasSilence()) or (IsStunned(GetLocalPlayer())) then
		return false;
	end

	-- hammer of justice if target is fleeing or low health
	if ((IsCasting(targetObj) or IsFleeing(targetObj) or targetHealth <= 20) and HasSpell('Hammer of Justice') and not IsSpellOnCD('Hammer of Justice')) and (localMana >= 15) then
		if (not Cast('Hammer of Justice', targetGUID)) then
			script_paladin.hJtime = GetTimeEX() + 4000;
			script_paladin:setTimers(1550);
			return true;
		end
	end

	-- hammer of wrath
	if (HasSpell('Hammer of Wrath')) and (not IsSpellOnCD('Hammer of Wrath')) and (targetHealth < 20) and (localMana >= 20) then
		if (not Cast('Hammer of Wrath', targetGUID)) then
			script_paladin:setTimers(1550);
			return true;
		end
	end

	-- Combo 1: Stun the target if we have HoJ and SoC
	if (HasSpell('Hammer of Justice') and not IsSpellOnCD('Hammer of Justice') and targetHealth > 50 and script_paladinEX:isBuff('Seal of Command') and localMana > 50 and not IsSpellOnCD('Judgement')) then
		if (not Cast('Hammer of Justice', targetGUID)) then
			script_paladin:setTimers(1650);
			return true;
		end
	end
		
	-- Combo 2: Use Judgement on the stunned target
	if (script_paladin.useJudgement) and (script_paladinEX:isBuff('Seal of Command') and GetDistance(targetObj) < 10 and script_target:hasDebuff("Hammer of Justice")) and (localMana >= 15) then
		if (not CastSpellByName('Judgement')) then
			script_paladin:setTimers(1650);
			return true;
		end
	end

	-- Seal of the Crusader until we used judgement
	if (script_paladin.useCrusader) and (not script_target:hasDebuff("Judgement of the Crusader") and targetHealth > 20 and (localMana >= 15)
		and not script_paladinEX:isBuff("Seal of the Crusader") and HasSpell('Seal of the Crusader')) then
		if (not CastSpellByName('Seal of the Crusader')) then
			script_paladin:setTimers(1550);
			return true;
		end
	end 

	-- Judgement when we have crusader
	if (script_paladin.useJudgement) and (HasSpell("Seal of the Crusader")) and (GetDistance(targetObj) < 10  and script_paladinEX:isBuff('Seal of the Crusader') and
		not IsSpellOnCD('Judgement') and HasSpell('Judgement')) and (localMana >= 15) then
		if (not CastSpellByName('Judgement')) then
			script_paladin:setTimers(1650);
			return true;
		end
	end

	-- Seal of Righteousness (before we have SoC)
	if (script_paladin.useRighteousness) and (not script_paladinEX:isBuff("Seal of Righteousness") and not script_paladinEX:isBuff("Seal of the Crusader") and not HasSpell('Seal of Command')) and (localMana >= 15) then 
		if (not CastSpellByName('Seal of Righteousness')) then
			script_paladin:setTimers(1550);
			return true;
		end
	end

	-- Judgement with Righteousness or Command if we have a lot of mana
	if (script_paladin.useJudgement) and ((script_paladinEX:isBuff("Seal of Righteousness") or script_paladinEX:isBuff("Seal of Command"))
		 and not IsSpellOnCD('Judgement') and localMana > 80) then 
		if (not CastSpellByName('Judgement')) then
			script_paladin:setTimers(1550);
			return true; 
		end
	end

	-- Use judgement if we are buffed with Righteousness or Command and the target is low health
	if (script_paladin.useJudgement) and ((script_paladinEX:isBuff('Seal of Righteousness') or script_paladinEX:isBuff('Seal of Command'))
		and GetDistance(targetObj) < 10 and (targetHealth < 25 or targetHealth > 55)) and (localMana >= 15) then
		if (not Cast('Judgement', targetGUID)) then
			script_paladin:setTimers(1550);
			return true;
		end
	end

	-- Seal of Command
	if (script_paladin.useCommand) and (HasSpell("Seal of Command")) and (not script_paladinEX:isBuff("Seal of Command") and not script_paladinEX:isBuff("Seal of the Crusader")) and (localMana >= 15) then 
		if (not CastSpellByName('Seal of Command')) then
			script_paladin:setTimers(1550);
			return true;
		end
	end

	-- crusader strike
	if (localMana >= 15) and (HasSpell("Crusader Strike")) and (not IsSpellOnCD("Crusader Strike")) then
		if (not Cast("Crusader Strike", targetGUID)) then
			script_paladin:setTimers(1550);
			return true;
		end 
	end

return false;
end

function script_paladinEX:menu()

	if (CollapsingHeader("Paladin Combat Menu")) then

		local wasClicked = false;

		-- seal of righteousness
		wasClicked, script_paladin.useRighteousness = Checkbox("Use Righteousness", script_paladin.useRighteousness);

		-- judgement
		if (HasSpell("Judgement")) then
			SameLine();
			wasClicked, script_paladin.useJudgement = Checkbox("Use Judgement", script_paladin.useJudgement);
		end

		-- seal of crusader
		if (HasSpell("Seal of the Crusader")) then
			wasClicked, script_paladin.useCrusader = Checkbox("Use Crusader", script_paladin.useCrusader);
		end

		-- seal of command
		if (HasSpell("Seal of Command")) then
			SameLine();
			wasClicked, script_paladin.useCommand = Checkbox("Use Command", script_paladin.useCommand);
		end

		-- auras and blessings
		if (CollapsingHeader("|+| Aura + Blessing Options")) then
			Text("Aura");
			script_paladin.aura = InputText("Aura", script_paladin.aura);
			Separator();
			Text("Blessing");
			script_paladin.blessing = InputText("Blessing", script_paladin.blessing);
		end

		Text("Use Holy Light Below Self Health Percent");
		script_paladin.healHealth = SliderInt("HIC", 1, 99, script_paladin.healHealth);

		Text("Use Holy Light Above Self Mana Percent");
		script_paladin.holyLightMana = SliderInt("HLM", 1, 100, script_paladin.holyLightMana);

		Separator();

		Text("Use Lay On Hands Below Self Health Percent");
		script_paladin.lohHealth = SliderInt("LoH", 1, 99, script_paladin.lohHealth);

		Text("Use Shields Below Self Health Percent");
		script_paladin.bopHealth = SliderInt("BoP", 1, 99, script_paladin.bopHealth);

	end
end