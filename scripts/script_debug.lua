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


		Separator();
	end


	if (script_grindMenu.debug) then
		--garbage data..
		Text("Garbage Data Lost (object manager) ");
		SameLine();
		local gc = gcinfo();
		Text(gc);
	end
		Separator();


	Text("target angle..." ..GetUnitsTarget(GetLocalPlayer(GetAngle)).. " ..Unstuck info");
	Text("my angle...    " ..GetLocalPlayer(GetAngle));

		Separator();


	local atime = math.floor(script_grind.currentTime2 - script_paranoid.currentTime + script_grind.setLogoutTime);
		Text("Paranoia Logout Timer  -  ");
		SameLine();
		Text(""..atime);
		Separator();

	Text("Grinder CurrentTime2 - " ..math.floor(script_grind.currentTime2 / 1000));
	Text("Paranoid CurrentTime - " ..math.floor(script_paranoid.currentTime / 1000));

	--nav mesh progress
	--if (GetLoadNavmeshProgress() ~= nil) and (GetLoadNavmeshProgress() ~= 0) then
	--	local qqq = math.floor(GetLoadNavmeshProgress()*100);
	--	if (qqq ~= nil) and (qqq ~= 100) and (qqq ~= 200) and (not qqq > 200) then
	--		Text("Navmesh Loading Progress Percent... " ..qqq);
	--	end
	--	if (qqq > 200) then
	--		Text("Please Reload Game - Navmesh errors");
	--	end
	--end
	local path = script_pather.updatePathDist;
	Text("Pather update path distance " ..path);
end