script_rotation = {
	pause = true,
	tickRate = 500,
	waitTimer = GetTimeEX(),
	timer = GetTimeEX(),
	isSetup = false,
	useMana = true,
	restHp = 60,
	restMana = 60,
	eatHealth = 60,
	drinkMana = 60,
	useRestFeature = false,
	
}
function script_rotation:draw()

end

function script_rotation:setup()
	
	SetPVE(true);
	SetAutoLoot();
	self.waitTimer = GetTimeEX();
	script_rogue.useRotation = true;

	-- Classes that doesn't use mana
	local class, classFileName = UnitClass("player");
	if (strfind("Warrior", class) or strfind("Rogue", class)) then self.useMana = false; self.restMana = 0; end

	DEFAULT_CHAT_FRAME:AddMessage('script_rotation: loaded...');

	if (script_grind.restHp == 0) then self.eatHealth = script_grind.restHp; end
	if (script_grind.restMana == 0) then self.drinkMana = script_grind.restMana; end


	self.isSetup = true;
	

end

function script_rotation:run()

	script_grind.shouldRest = false;
	script_grind:restOff();

	if (not self.isSetup) then
		script_rotation:setup();
	end

	if (NewWindow("Rotation", 100, 100)) then
		script_rotation:menu();
	end

	if (self.pause) then
		return;
	end

	-- Check: wait for timer
	if(self.waitTimer > GetTimeEX()) then return; end
	self.waitTimer = GetTimeEX() + self.tickRate;

	if(GetTarget() ~= 0) then
		RunCombatScript(GetTarget());
	elseif (self.useRestFeature) then
		RunRestScript();
	end

	
end


function script_rotation:menu()

	wasClicked, self.useRestFeature = Checkbox("Stop And Rest After Combat", self.useRestFeature);

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

	if (CollapsingHeader("[Rest options")) then
		wasClicked, script_rotation.useMana = Checkbox("Class Uses Mana", script_rotation.useMana);
		script_rotation.restHp = SliderInt("Eat percent", 1, 99, script_rotation.restHp);
		if (script_rotation.useMana) then script_rotation.restMana = SliderInt("Drink percent", 1, 99, script_rotation.restMana); 
			Text("Use potions (when in combat):");
			script_rotation.potHp = SliderInt("HP percent", 1, 99, script_rotation.potHp);
			if (script_rotation.useMana) then script_rotation.potMana = SliderInt("Mana percent", 1, 99, script_rotation.potMana);
			end
		end
	end
end
