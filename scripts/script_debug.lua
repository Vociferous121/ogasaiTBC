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

	Text("");
	local mytarget = GetUnitsTarget(GetLocalPlayer());

	Text("target angle..." ..math.floor(GetAngle(mytarget)).. " ..Unstuck info");
	Text("my angle...    " ..math.floor(GetAngle(GetLocalPlayer())));
	local test2 = math.floor(GetAngle(mytarget) - GetAngle(GetLocalPlayer()));
	Text(test2);
	

	
	Text("");
		Separator();



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


	Separator();
	Text("Paranoia Time...");
	local paraTime = script_grind.currentTime;
	local paraTime2 = script_grind.currentTime2;
	Text(""..paraTime);
	Text(""..paraTime2);

	local testTimer = (script_grind.currentTime + script_grind.setLogoutTime) - script_grind.currentTime2;
	Text(""..testTimer);
end