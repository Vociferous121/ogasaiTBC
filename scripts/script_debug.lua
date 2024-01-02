script_debug = {

	debugPather = "Pather",
	debugGrind = "Grind",
	debugPath = "Path",
	debugCombat = "combat",

}

function script_debug:menu()

	wasClicked, script_grind.adjustTickRate = Checkbox("Adjust Tick Rate", script_grind.adjustTickRate);
	script_grind.tickRate = SliderInt("Grinder Tick Rate", 0, 5000, script_grind.tickRate);
	if (CollapsingHeader("Debug")) then
		Text("Grinder Debug - ");
		Text(self.debugGrind);

		Separator();

		Text("Path Debug - ");
		Text(self.debugPath);

		Separator();

		Text("Pather Debug - ");
		Text(self.debugPather);

		Separator();

		Text("Combat Debug - ");
		Text(self.debugCombat);
	end
end