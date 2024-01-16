script_priestEX = {}

function script_priestEX:menu()
	if (CollapsingHeader("[Priest - Shadow")) then
		local wasClicked = false;
		Text('Skills options:');
		Separator();
		wasClicked, script_priest.useWand = Checkbox("Use Wand", script_priest.useWand);
		script_priest.wandMana = SliderInt("Mana to Wand", 1, 99, script_priest.wandMana);
		script_priest.wandHealth = SliderInt("Health to Wand", 1, 99, script_priest.wandHealth);
		script_priest.renewHP = SliderInt("Renew HP", 1, 99, script_priest.renewHP);
		script_priest.shieldHP = SliderInt("Shield HP", 1, 99, script_priest.shieldHP);
		script_priest.flashHealHP = SliderInt("Flash HP", 1, 99, script_priest.flashHealHP);
		script_priest.lesserHealHP = SliderInt("Lesser HP", 1, 99, script_priest.lesserHealHP);
		script_priest.healHP = SliderInt("Heal HP", 1, 99, script_priest.healHP);
		script_priest.greaterHealHP = SliderInt("Greater HP", 1, 99, script_priest.greaterHealHP);
	end
end