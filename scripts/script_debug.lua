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


		local curMap = GetZoneText();
		Text("Current GetZoneText()"..curMap);
	end
		Separator();


	if (CollapsingHeader("Unstuck Debuf")) then
		Text("Face Angle (rogue/mage)");
		local mytarget = GetUnitsTarget(GetLocalPlayer());
	
		Text("target angle..." ..math.floor(GetAngle(mytarget)).. " ..Unstuck info");
		Text("my angle...    " ..math.floor(GetAngle(GetLocalPlayer())));
		local test2 = math.floor(GetAngle(mytarget) - GetAngle(GetLocalPlayer()));
		Text("Target Angle - My Angle - "..test2);
		Separator();
	end



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


	if (CollapsingHeader("Path Script Debug")) then
		Text("Update Path Dist");
		local path = script_pather.updatePathDist;
		Text("Pather update path distance " ..path);
		Separator();
	end


	if (CollapsingHeader("Timers")) then
		Text("Paranoia Time...");
		local paraTime = script_grind.currentTime;
		local paraTime2 = script_grind.currentTime2;
		Text("Grind Current Time - "..paraTime);
		Text("Grind Current Time 2 - "..paraTime2);
		local testTimer = (script_grind.currentTime + script_grind.setLogoutTime) - script_grind.currentTime2;
		Text("Paranoia Logout Timer - "..testTimer);

		Text("script wait timers");
		Text("Grinder Wait Timer - "..script_grind.waitTimer);
		Text("Rogue Wait Timer - "..script_rogue.waitTimer);
		--Text("Warlock Wait Timer - "..script_warlock.waitTimer);
		--Text("Current Bot Time - "..GetTimeEX());
		--Text("Mage Wait Timer - "..script_mage.waitTimer);
		--Text("Mage Rest Timer - "..script_mage.restWaitTimer);

		Text("Warlock Timers");
		local wt1 = script_warlock.waitTimer;
		local wt2 = script_warlocksiphonTime;
		local wt3 = script_warlockagonyTime;
		local wt4 = script_warlockcorruptTime;
		local wt5 = script_warlockimmoTime;
		local wt6 = script_warlockstoneTime;
		Text("wait timer "..wt1);
		Text("siphon timer "..wt2);
		Text("agony timer "..wt3);
		Text("corrupt timer "..wt4);
		Text("immo timer "..wt5);
		Text("stone timer "..wt6);

		Text("");
		Text("Mage Timers");
		local mwt1 = script_mage.waitTimer;
		local mwt2 = script_mage.gemTimer;
		Text("wait timer - "..mwt1);
		Text("gem timer - "..mwt2);

		Text("");
		Text("Paladin Timers");
		local pwt1 = script_paladin.waitTimer;
		local pwt2 = script_paladin.sealTimer;
		Text("wait timer - "..pwt1);
		Text("seal timer - "..pwt2);
	end
		
end