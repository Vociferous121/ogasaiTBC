script_warlockEX = {}

function script_warlockEX:menu()

	if (CollapsingHeader("Warlock Combat Menu")) then

		local wasClicked = false;
		
		if (HasSpell("Create Healthstone")) then
			Text("Use Healthstones below HP percent");
			script_warlock.stoneHealth = SliderFloat("HSHP", 1, 99, script_warlock.stoneHealth);
			Separator();
		end

		-- wand
		local max = 0;
		local dur = 0;
		if (GetInventoryItemDurability(18) ~= nil) then
			dur, max = GetInventoryItemDurability(18);
		end

		if (dur > 0) then
			wasClicked, script_warlock.useWand = Checkbox("Use Wand", script_warlock.useWand);
		end
		if (dur > 0) then
			SameLine();
		end

		-- life tap
		if (HasSpell("Life Tap")) then
			wasClicked, script_warlock.useLifeTap = Checkbox("Use Life Tap", script_warlock.useLifeTap);
		end

		-- drain life
		if (HasSpell("Drain Life")) then
			SameLine();
			wasClicked, script_warlock.useDrainLife = Checkbox("Use Drain Life", script_warlock.useDrainLife);
		end

		Separator();

		if (script_warlock.useFelguard) then
			script_warlock.useVoid = false;
			script_warlock.useImp = false;
		end
			
		if (script_warlock.useVoid) then
			script_warlock.useFelguard = false;
			script_warlock.useImp = false;
		end
		if (script_warlock.useImp) then
			script_warlock.useFelguard = false;
			script_warlock.useVoid = false;
		end

		if (HasSpell("Summon Imp")) then
			wasClicked, script_warlock.useImp = Checkbox("Use Imp", script_warlock.useImp);
		end
		if (HasSpell("Summon Voidwalker")) then
			SameLine();
			wasClicked, script_warlock.useVoid = Checkbox("Use Voidwalker", script_warlock.useVoid);
		end
		if (HasSpell("Summon Felguard")) then
			SameLine();
			wasClicked, script_warlock.useFelguard = Checkbox("Use Felguard", script_warlock.useFelguard);
		end
		
		
		if (CollapsingHeader("|+| DoT Options")) then
			if (HasSpell("Immolate")) then
				wasClicked, script_warlock.useImmolate = Checkbox("Use Immolate", script_warlock.useImmolate);
			end
			if (HasSpell("Corruption")) then
				SameLine();
				wasClicked, script_warlock.useCorruption = Checkbox("Use Corruption", script_warlock.useCorruption)
			end
			if(HasSpell("Curse of Agony")) then
				wasClicked, script_warlock.useCurseOfAgony = Checkbox("Use Agony", script_warlock.useCurseOfAgony);
			end
			if (HasSpell("Siphon Life")) then
				SameLine();
				wasClicked, script_warlock.useSiphonLife = Checkbox("Use Siphon Life", script_warlock.useSiphonLife);
			end			
		end

		if (script_warlock.useWand) then
			if (CollapsingHeader("|+| Wand Options")) then
				Text("Use Wand Below Target Health Percent");
				script_warlock.useWandHealth = SliderInt("Wand Health", 0, 100, script_warlock.useWandHealth);
				Text("Use Wand Below Self Mana Percent");
				script_warlock.useWandMana = SliderInt("Wand Mana", 0, 100, script_warlock.useWandMana);
			end
		end

		if (HasSpell("Life Tap")) and (script_warlock.useLifeTap) then
			if (CollapsingHeader("|+| Life Tap Options (out of combat)")) then
				Text("Use Life Tap Above Self Health Percent");
				script_warlock.lifeTapHealth = SliderInt("LTM", 1, 100, script_warlock.lifeTapHealth);
				Text("Use Life Tap Below Self Mana Percent");
				script_warlock.lifeTapMana = SliderInt("LTH", 1, 100, script_warlock.lifeTapMana);
			end
		end
	end
end