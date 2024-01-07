script_grindMenu = {

	debug = false,
}

function script_grindMenu:menu()

	local wasClicked = false;

	--if (not self.debug) then
	--garbage data..
	--Text("Garbage Data Lost (object manager) ");
	--SameLine();
	--local gc = gcinfo();
	--Text(gc);
	--end

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

	if (script_grind.pause) then
		if (Button("Resume Bot")) then script_grind.pause = false; end
	else
		if (Button("Pause Bot")) then
		script_grind.pause = true; end end
	SameLine(); if (Button("Reload Scripts")) then menu:reload(); end
	SameLine(); if (Button("Exit Bot")) then StopBot(); end
	SameLine();
	wasClicked, self.debug = Checkbox("Debug", self.debug);
	Separator();

	-- Load combat menu by class
	local class = UnitClass("player");
	
	if (class == 'Mage') then
		script_mage:menu();
	elseif (class == 'Hunter') then
		script_hunter:menu();
	elseif (class == 'Warlock') then
		script_warlock:menu();
	elseif (class == 'Paladin') then
		script_paladin:menu();
	elseif (class == 'Druid') then
		script_druid:menu();
	elseif (class == 'Priest') then
		script_priest:menu();
	elseif (class == 'Warrior') then
		script_warrior:menu();
	elseif (class == 'Rogue') then
		script_rogue:menu();
	elseif (class == 'Shaman') then
		script_shaman:menu();
	end
	
	if (CollapsingHeader("Mount | Talents | Paranoia | Menu")) then 

		wasClicked, script_paranoid.useParanoia = Checkbox("Use Paranoia", script_paranoid.useParanoia);
		SameLine();

		if (script_paranoid.useParanoia) then
			wasClicked, script_paranoid.logoutOnParanoid = Checkbox("Logout When Paranoid", script_paranoid.logoutOnParanoid);
			Separator();
		end
		if (script_paranoid.useParanoia) and (script_paranoid.logoutOnParanoid) then
				Text("Logout Time In Seconds");
				script_grind.setLogoutTime = SliderInt("(seconds)", 0 , 300, script_grind.setLogoutTime);
		end
		if (script_paranoid.useParanoia) then
		
				Text("Paranoia Range Of Other Players");
				script_paranoid.paranoidRange = SliderInt("PR", 0, 200, script_paranoid.paranoidRange);
				Separator();
			
		end
		Separator();
		wasClicked, script_grind.useMount = Checkbox("Use Mount", script_grind.useMount);
		SameLine(); wasClicked, script_grind.jump = Checkbox("Jump while moving (unmounted)", script_grind.jump);
		Separator();
		wasClicked, script_grind.autoTalent = Checkbox("Spend talent points", script_grind.autoTalent);
		Text("Change talents in script_talent.lua");
		if (script_grind.autoTalent) then Text("Spending next talent point in: " .. (script_talent:getNextTalentName() or " ")); end 
		Separator();
	end
	
	script_vendorMenu:menu();
	
	if (CollapsingHeader("Rest Menu")) then
		wasClicked, script_grind.useMana = Checkbox("Class Uses Mana", script_grind.useMana);
		script_grind.restHp = SliderInt("Eat percent", 1, 99, script_grind.restHp);
		if (script_grind.useMana) then script_grind.restMana = SliderInt("Drink percent", 1, 99, script_grind.restMana); end
		Text("Use potions (when in combat):");
		script_grind.potHp = SliderInt("HP percent", 1, 99, script_grind.potHp);
		if (script_grind.useMana) then script_grind.potMana = SliderInt("Mana percent", 1, 99, script_grind.potMana); end
	end

	script_pathMenu:menu();

	if (CollapsingHeader("Target Menu")) then
		Text("Scan for valid targets within X yds.");

		script_target.pullRange = SliderFloat("SD (yd)", 1, 200, script_target.pullRange);
		Text("Start attacking a new target within X yds.");
		script_grind.pullDistance = SliderFloat("PD (yd)", 1, 35, script_grind.pullDistance);
		Text("Target Level");
		script_target.minLevel = SliderInt("Min Lvl", 1, 73, script_target.minLevel);
		script_target.maxLevel = SliderInt("Max Lvl", 1, 73, script_target.maxLevel);
		Separator();
		if (CollapsingHeader("|+| Skip Creature By Type")) then
			Text("Creature type selection:");
			local wasClicked = false;
			wasClicked, script_target.skipElites = Checkbox("Skip Elites", script_target.skipElites);
			SameLine();
			wasClicked, script_target.skipHumanoid = Checkbox("Skip Humanoids", script_target.skipHumanoid);
			wasClicked, script_target.skipUndead = Checkbox("Skip Undeads", script_target.skipUndead);
			SameLine();
			wasClicked, script_target.skipDemon = Checkbox("Skip Demons", script_target.skipDemon);
			wasClicked, script_target.skipBeast = Checkbox("Skip Beasts", script_target.skipBeast);
			SameLine();
			wasClicked, script_target.skipAberration= Checkbox("Skip Aberrations", script_target.skipAberration);
			wasClicked, script_target.skipDragonkin = Checkbox("Skip Dragonkin", script_target.skipDragonkin);
			SameLine();
			wasClicked, script_target.skipGiant = Checkbox("Skip Giants", script_target.skipGiant);
			wasClicked, script_target.skipMechanical = Checkbox("Skip Mechanicals", script_target.skipMechanical);
			SameLine();
			wasClicked, script_target.skipElemental = Checkbox("Skip Elementals", script_target.skipElemental);
		end	
	end

	script_target:lootMenu();

	script_gatherMenu:menu();

	if (CollapsingHeader("Display Menu")) then
		wasClicked, script_aggro.drawAggro = Checkbox("Draw Aggro Ranges", script_aggro.drawAggro);
		wasClicked, script_grind.drawPath = Checkbox("Draw Navmesh Move Path", script_grind.drawPath)
		wasClicked, script_grindEX.drawRaycastPath = Checkbox("Draw Raycast Path (TBC Area)", script_grindEX.drawRaycastPath);
		wasClicked, script_grindEX.drawStatus = Checkbox("Draw Status Window", script_grindEX.drawStatus);
		wasClicked, script_grindEX.drawGather = Checkbox("Draw Gather Nodes", script_grindEX.drawGather);
		wasClicked, script_grindEX.drawTarget = Checkbox("Draw Unit Info", script_grindEX.drawTarget);
		wasClicked, script_grindEX.drawAutoPath = Checkbox("Draw Hotspot & Nodes", script_grindEX.drawAutoPath);
	end
	
	if (script_grindMenu.debug) then
		if(NewWindow("Debug", 100, 100)) then
			script_debug:menu();
		end
	end
end