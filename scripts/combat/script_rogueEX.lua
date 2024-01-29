script_rogueEX = {
	useBandage = true
}

function script_rogueEX:menu()

	if (CollapsingHeader("Rogue Combat Menu")) then

		local wasClicked = false;

		if (script_rogue.hasBandage) then
			wasClicked, self.useBandage = Checkbox("Use Bandages", self.useBandage);
			SameLine();
		end
		--wasClicked, script_rogue.useThrow = Checkbox("Use Throw", script_rogue.useThrow);
		--SameLine();
		wasClicked, script_rogue.randomizeCombat = Checkbox("Try to Randomize Combat (cast all spells)", script_rogue.randomizeCombat);
		Text("Melee Distance To Target    ");
		script_grind.meleeDistance = SliderFloat("Melee Distance", 0, 5, script_grind.meleeDistance);

		-- show use stealth button
		if (HasSpell("Stealth")) then
			Separator();
			wasClicked, script_rogue.useStealth = Checkbox("Use Stealth", script_rogue.useStealth);

			-- if use stealth show stealth options
			if (script_rogue.useStealth) then
				SameLine();

				wasClicked, script_rogue.alwaysStealth = Checkbox("Always Stealth", script_rogue.alwaysStealth);

				if (HasSpell("Pick Pocket")) then
					SameLine();
					wasClicked, script_rogue.usePickPocket = Checkbox("Pick Pocket", script_rogue.usePickPocket);
				end

				Text("Stealth Range To Target");
				script_rogue.stealthRange = SliderInt("(yds)", 5, 100, script_rogue.stealthRange);
				Separator();

			end
		end

		-- sprint
		if (HasSpell("Sprint")) then
			if (not script_rogue.useStealth) then
				SameLine();
			end
			wasClicked, script_rogue.useSprint = Checkbox("Sprint To Target", script_rogue.useSprint);
		end

		if (HasSpell("Poisons")) and (HasSpell("Envenom")) then
			SameLine();
			wasClicked, script_rogue.useEnvenom = Checkbox("Use Envenom", script_rogue.useEnvenom);
		end

		-- feint
		if (HasSpell("Feint")) and (GetNumPartyMembers() >= 1) then
			SameLine();
			wasClicked, script_rogue.useFeint = Checkbox("Use Feint", script_rogue.useFeint);
		end

		-----------------------------------

		-- slice and dice
		if (HasSpell("Slice and Dice")) then
			Separator();
			wasClicked, script_rogue.useSlice = Checkbox("Slice & Dice", script_rogue.useSlice);
		end
		
		-- expose armor
		if (HasSpell("Expose Armor")) then
			SameLine();
			wasClicked, script_rogue.useExposeArmor = Checkbox("Expose Armor", script_rogue.useExposeArmor);
		end
		
		-- rupture
		if (HasSpell("Rupture")) then
			SameLine();
			wasClicked, script_rogue.useRupture = Checkbox("Rupture", script_rogue.useRupture);
		end

		-- combo point menu
		if (CollapsingHeader("|+| Combo Point Generator")) then
			Text("Combo Point ability");
			script_rogue.cpGenerator = InputText("CPA", script_rogue.cpGenerator);
			Text("Energy cost of CP-ability");
			script_rogue.cpGeneratorCost = SliderInt("Energy", 20, 50, script_rogue.cpGeneratorCost);
		end
			
		-- stealth opener menu
		if (HasSpell("Stealth")) then
			if(CollapsingHeader("|+| Stealth Ability Opener")) then
				Text("Stealth ability opener");
				script_rogue.stealthOpener = InputText("STO", script_rogue.stealthOpener);
			end
		end

		-- poisons menu
		if (GetLevel(GetLocalPlayer()) >= 20) and (HasSpell("Poisons")) then
			if (CollapsingHeader("|+| Posion Options")) then
				wasClicked, script_rogue.usePoisons = Checkbox("Use Poisons", script_rogue.usePoisons);
				Text("Poison on Main Hand");
				script_rogue.mainhandPoison = InputText("PMH", script_rogue.mainhandPoison);
				Text("Poison on Off Hand");
				script_rogue.offhandPoison = InputText("POH", script_rogue.offhandPoison);
			end
		end

		-- riposte menu
		if (HasSpell("Riposte")) then
			if (CollapsingHeader("|+| Riposte Skill Options")) then
				Text("Action Bar Slots 1 - 12");
				script_rogue.riposteActionBarSlot = InputText("RS", script_rogue.riposteActionBarSlot);	-- riposte
			end
		end
		
		-- envenom
		if (HasSpell("Envenom")) and (script_rogue.usePoisons) and (script_rogue.useEnvenom) then
			if (CollapsingHeader("|+| Envenom Options")) then
				Text("Use Envenom Below Target Health Percent");
				script_rogue.envenomHealth = SliderInt("ENVH", 0, 25, script_rogue.envenomHealth);
				Text("Name Of Poison Applied To Target");
				script_rogue.poisonName = InputText("Poison Name", script_rogue.poisonName);
			end
		end

		-- expose armor menu
		if (HasSpell("Expose Armor")) and (script_rogue.useExposeArmor) then
			if (CollapsingHeader("|+| Expose Armor Options")) then
				Text("Expose Armor Stacks On Target");
				script_rogue.exposeArmorStacks = SliderInt("EAXS", 1, 5, script_rogue.exposeArmorStacks);
			end
		end

		-- rupture menu
		if (HasSpell("Rupture")) and (script_rogue.useRupture) then
			if (CollapsingHeader("|+| Rupture Options")) then
				Text("Combo Points To Use Rupture");
				script_rogue.ruptureStacks = SliderInt("RUPS", 1, 5, script_rogue.ruptureStacks);
			end
		end
	end
end

function script_rogueEX:checkBandage()

	if (HasItem("Linen Bandage")) or 
		(HasItem("Heavy Linen Bandage")) or 
		(HasItem("Wool Bandage")) or 
		(HasItem("Heavy Wool Bandage")) or 
		(HasItem("Silk Bandage")) or 
		(HasItem("Heavy Silk Bandage")) or 
		(HasItem("Mageweave Bandage")) or 
		(HasItem("Heavy Mageweave Bandage")) or 
		(HasItem("Runecloth Bandage")) or 
		(HasItem("Heavy Runecloth Bandage")) then

		script_rogue.hasBandage = true;
	else
		script_rogue.hasBandge = false;
		script_rogue.useBandage = false;
	end

end

	-- debuffs that stop stealth...
function script_rogueEX:stopStealth()

	if (HasDebuff(GetLocalPlayer(), "Faerie Fire")) or (script_checkDebuffs:hasPoison()) then
		return true;
	end
return false;
end

function script_rogueEX:stopForThrow()
	local myTarget = GetUnitsTarget(GetLocalPlayer());
	if (script_rogue.useThrow) and (not IsInCombat()) and (not HasBuff(localObj, "Stealth")) and (myTarget ~= 0) and (myTarget ~= nil) then
		if (GetDistance(myTarget) <= 24) and (GetDistance(myTarget) >= 7) and (IsInLineOfSight(myTarget)) and (script_helper:inLineOfSight(myTarget))  then 
		return true;
		end
	end
return false;
end

function script_rogueEX:forceStealth()
	if (HasSpell("Stealth")) and (not IsInCombat()) and (not script_checkDebuffs:hasPoison()) and (GetDistance(script_grind.target) <= script_rogue.stealthRange) and (GetHealthPercentage(GetLocalPlayer()) > script_rogue.eatHealth) and (script_rogue.useStealth) and (not IsSpellOnCD("Stealth")) and (not HasBuff(localObj, "Stealth")) and (not script_rogueEX:stopStealth()) and (not script_target:isThereLoot()) then
		if (not CastSpellByName("Stealth")) then
			self.waitTimer = GetTimeEX() + 200;
			return true;
		end
	end
return false;
end


function script_rogueEX:useSprint()
	if (script_rogue.useSprint) and (HasBuff(localObj, "Stealth")) and (HasSpell("Sprint")) and (not IsSpellOnCD("Sprint")) and (GetDistance(script_grind.target) >= 20) then
		if (CastSpellByName("Sprint")) then
			return true;
		end
	end
return false;
end