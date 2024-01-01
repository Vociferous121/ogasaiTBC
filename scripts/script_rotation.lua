script_rotation = {
	pause = true,
	tickRate = 500,
	waitTimer = GetTimeEX(),
	timer = GetTimeEX(),
	isSetup = false,
}

function script_rotation:setup()

end

function script_rotation:run()

	script_rotation:menu();

	-- Check: wait for timer
	if(self.waitTimer > GetTimeEX()) then return; end
	self.waitTimer = GetTimeEX() + self.tickRate;

	if(GetTarget() ~= 0) then
		RunCombatScript(GetTarget());
	else
		RunRestScript();
	end
end


function script_rotation:menu()
	
	if (NewWindow("Rotation", 300, 200)) then
	end
	

	local wasClicked = false;
	if (script_rotation.pause) then
		if (Button("Resume Bot")) then
			script_rotation.pause = false;
		end
	else
		if (Button("Pause Bot")) then
			script_rotation.pause = true;
		end
	end
	SameLine();
	if (Button("Reload Scripts")) then
		menu:reload();
	end
	SameLine();
	if (Button("Exit Bot")) then
		StopBot();
	end
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

end
