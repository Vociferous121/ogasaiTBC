script_mageEX = {
	isSetup = false,
}

function script_mageEX:addWater(name)
	script_mage.water[script_mage.numWater] = name;
	script_mage.numWater = script_mage.numWater + 1;
end

function script_mageEX:addFood(name)
	script_mage.food[script_mage.numfood] = name;
	script_mage.numfood = script_mage.numfood + 1;
end

function script_mageEX:addManaGem(name)
	script_mage.manaGem[script_mage.numGem] = name;
	script_mage.numGem = script_mage.numGem + 1;
end

function script_mageEX:setup()
	script_mageEX:addWater('Conjured Glacier Water');
	script_mageEX:addWater('Conjured Crystal Water');
	script_mageEX:addWater('Conjured Sparkling Water');
	script_mageEX:addWater('Conjured Mineral Water');
	script_mageEX:addWater('Conjured Spring Water');
	script_mageEX:addWater('Conjured Purified Water');
	script_mageEX:addWater('Conjured Fresh Water');
	script_mageEX:addWater('Conjured Water');
	
	script_mageEX:addFood('Conjured Croissant');
	script_mageEX:addFood('Conjured Cinnamon Roll');
	script_mageEX:addFood('Conjured Sweet Roll');
	script_mageEX:addFood('Conjured Sourdough')
	script_mageEX:addFood('Conjured Pumpernickel');
	script_mageEX:addFood('Conjured Rye');
	script_mageEX:addFood('Conjured Bread');
	script_mageEX:addFood('Conjured Muffin');
	
	script_mageEX:addManaGem('Mana Ruby');
	script_mageEX:addManaGem('Mana Agate');
	script_mageEX:addManaGem('Mana Citrine');
	script_mageEX:addManaGem('Mana Jade');
	script_mageEX:addManaGem('Mana Ruby');

	script_mageEX.isSetup = true;
end

function script_mageEX:menu()

	local localObj = GetLocalPlayer();
	if (CollapsingHeader('Mage Combat Menu')) then
		local wasClicked = false;	
		Text('Skills options:');
		Separator();

		if (GetInventoryItemDurability(18) ~= nil) then
			wasClicked, script_mage.useWand = Checkbox('Use Wand', script_mage.useWand);
		end

		if (HasSpell("Fire Blast")) then
			SameLine();
			wasClicked, script_mage.useFireBlast = Checkbox('Use Fire Blast', script_mage.useFireBlast);
		end

		if (HasSpell("Frost Nova")) then
			SameLine();
			wasClicked, script_mage.useFrostNova = Checkbox("Use Frost Nova", script_mage.useFrostNova);
		end

		if (HasSpell("Blink")) then
			wasClicked, script_mage.useBlink = Checkbox("Use Blink", script_mage.useBlink);
		end

		if (HasSpell("Mana Shield")) then
			SameLine();
			wasClicked, script_mage.useManaShield = Checkbox('Use Mana Shield', script_mage.useManaShield);
		end

		if (HasSpell("Evocation")) then
			SameLine();
			wasClicked, script_mage.useEvocation = Checkbox("Use Evocation", script_mage.useEvocation);
		end
	
		if (HasSpell("Cone of Cold")) then
			wasClicked, script_mage.useConeOfCold = Checkbox("Use Cone of Cold", script_mage.useConeOfCold);
		end

		if (script_mage.useEvocation) and (HasSpell("Evocation")) then
			if (CollapsingHeader("|+| Evocation Options")) then
				Text('Evocation above health percent');
				script_mage.evocationHealth = SliderInt('EH', 1, 90, script_mage.evocationHealth);
				Text('Evocation below mana percent');
				script_mage.evocationMana = SliderInt('EM', 1, 90, script_mage.evocationMana);
			end
		end

		if (HasSpell("Ice Block")) then
			Text('Ice Block below health percent');
			script_mage.iceBlockHealth = SliderInt('IBH', 5, 90, script_mage.iceBlockHealth);
			Text('Ice Block below mana percent');
			script_mage.iceBlockMana = SliderInt('IBM', 5, 90, script_mage.iceBlockMana);
		end

		if (HasSpell("Mana Gem")) then
			Text('Mana Gem below mana percent');
			script_mage.manaGemMana = SliderInt('MG', 1, 90, script_mage.manaGemMana);
		end

		if (HasSpell("Cone of Cold")) then
			if (script_mage.useConeOfCold) then
				if (CollapsingHeader("|+| Cone of Cold Options")) then
					Text("Cone of Cold Above Target Health Percent");
					script_mage.coneOfColdHealth = SliderInt("COCH", 0, 100, script_mage.coneOfColdHealth);
					Text("Cone of Cold Above Self Mana Percent");
					script_mage.coneOfColdMana = SliderInt("COCM", 0, 100, script_mage.coneOfColdMana);
				end
			end
		end

		if (script_mage.useWand) then
			if (CollapsingHeader("|+| Wand Options")) then
				Text("Use Wand Below Target Health Percent");
				script_mage.useWandHealth = SliderInt("WH", 0, 100, script_mage.useWandHealth);
				Text("Use Wand Below Self Mana Percent");
				script_mage.useWandMana = SliderInt("WM", 0 , 100, script_mage.useWandMana);
			end
		end
	end

end