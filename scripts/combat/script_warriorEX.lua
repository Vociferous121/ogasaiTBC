script_warriorEX = {}

function script_warriorEX:menu()

	if (CollapsingHeader("[Warrior - Fury")) then
		script_warrior.meleeDistance = SliderFloat("Melee Distance", 2, 8, script_warrior.meleeDistance);
		local clickCharge = false;
		local clickThrow = false;
		Text('Pull options:');
		clickCharge, script_warrior.useCharge = Checkbox("Use Charge", script_warrior.useCharge);
		SameLine();
		clickThrow, script_warrior.useThrow = Checkbox("Use Throw", script_warrior.useThrow);
		if (clickCharge) then script_warrior.useThrow = false; end
		if (clickThrow) then script_warrior.useCharge = false; end
		Separator();
	end

end