script_druidEX = {}

function script_druidEX:menu()

	if (CollapsingHeader("[Druid - Feral")) then
		Text('Healing Tresh Holds:');
		Separator();
		Text('Healing while Shapeshifted');
		self.healHealthWhenShifted = SliderFloat("HPS percent", 1, 99, self.healHealthWhenShifted);
		Text('Healing Touch');
		self.healHealth = SliderFloat("HT percent", 1, 99, self.healHealth);
		Text('Regrowth');
		self.regrowthHealth = SliderFloat("RG percent", 1, 99, self.regrowthHealth);
		Text('Rejuvenation');
		self.rejuHealth = SliderFloat("RJ percent", 1, 99, self.rejuHealth);
	end

end