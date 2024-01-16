script_shamanEX = {}

function script_shamanEX:menu()

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
