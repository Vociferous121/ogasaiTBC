script_rotation = {
	pause = true,
	tickRate = 750,
	waitTimer = GetTimeEX(),
	timer = GetTimeEX(),
	isSetup = false,
	useMana = true,
	restHp = 60,
	restMana = 60,
	useRestFeature = false,
	enemyObj = 0,


	helperLoaded = include("scripts\\script_helper.lua"),
	targetLoaded = include("scripts\\script_target.lua"),
	pathLoaded = include("scripts\\script_path.lua"), 
	vendorScript = include("scripts\\script_vendor.lua"),
	grindExtra = include("scripts\\script_grindEX.lua"),
	grindMenu = include("scripts\\script_grindMenu.lua"),
	autoTalents = include("scripts\\script_talent.lua"),
	info = include("scripts\\script_info.lua"),
	gather = include("scripts\\script_gather.lua"),
	rayPather = include("scripts\\script_pather.lua"),
	
}
function script_rotation:draw()

end

function script_rotation:setup()
	script_helper:setup()
	SetPVE(true);
	SetAutoLoot();
	self.waitTimer = GetTimeEX();
	script_rogue.useRotation = true;
	script_mage.useRotation = true;
	script_druid.useRotation = true;
	script_paladin.useRotation = true;
	script_warrior.useRotation = true;
	script_shaman.useRotation = true;
	script_hunter.useRotation = true;
	script_priest.useRotation = true;
	script_warlock.useRotation = true;


	local class, classFileName = UnitClass("player");
	if (strfind("Mage", class)) then
		self.useRestFeature = true;
	end

	-- Classes that doesn't use mana
	local class, classFileName = UnitClass("player");
	if (strfind("Warrior", class) or strfind("Rogue", class)) then self.useMana = false; self.restMana = 0; end

	DEFAULT_CHAT_FRAME:AddMessage('script_rotation: loaded...');

	self.isSetup = true;
	

end

function script_rotation:run()
	
	local localObj = GetLocalPlayer();
	local localMana = GetManaPercentage(localObj);
	local localHealth = GetHealthPercentage(localObj);

	-- make sure we are setup
	if (not self.isSetup) then
		script_rotation:setup();
	end

	-- draw the rotation window
	if (NewWindow("Rotation", 100, 100)) then
		script_rotation:menu();
	end

	-- if we click pause then return and stop
	if (self.pause) then
		return;
	end

	-- Check: wait for timer
	if(self.waitTimer > GetTimeEX()) then
		return;
	end

	-- set reaction time after casting spells and wait timers
	self.waitTimer = GetTimeEX() + self.tickRate;

	-- if have a target in UI then run combat script
	if(GetTarget() ~= 0) then

			self.enemyObj = GetTarget();

		-- run combat scripts...
		RunCombatScript(GetTarget());

	-- if we want to rest and are not in combat then run rest scripts
	elseif(self.useRestFeature) and (not IsInCombat()) then

		-- run rotation rest....
		script_rotation:runRest();

		-- run rest scripts for combat scripts...
		RunRestScript();

		--reset enemyobj
		self.enemyObj = 0;

	end

	return;
end


function script_rotation:menu()

	local wasClicked = false;

	-- pause/resume, reload and exit buttons
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

	-- use rest feature
	wasClicked, self.useRestFeature = Checkbox("Stop And Rest After Combat", self.useRestFeature);

	-- tick rate / reaction time
	Text("Reaction Time (ms)");
	self.tickRate = SliderInt("(ms)", 0, 2500, self.tickRate);
	
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

	-- rest options
	if (CollapsingHeader("[Rest options")) then
		
		-- does class use mana?
		wasClicked, script_rotation.useMana = Checkbox("Class Uses Mana", script_rotation.useMana);

		-- set rest health
		script_rotation.restHp = SliderInt("Eat percent", 1, 99, script_rotation.restHp);

		-- set rest mana
		if (script_rotation.useMana) then
			script_rotation.restMana = SliderInt("Drink percent", 1, 99, script_rotation.restMana);
		end 

		-- health potions
		Text("Use potions (when in combat):");
		script_rotation.potHp = SliderInt("HP percent", 1, 99, script_rotation.potHp);

		-- mana potions
		if (script_rotation.useMana) then
			script_rotation.potMana = SliderInt("Mana percent", 1, 99, script_rotation.potMana);
		end
	
	end

if (CollapsingHeader("Display Options")) then
		wasClicked, script_aggro.drawAggro = Checkbox("Draw Aggro Ranges", script_aggro.drawAggro);
		wasClicked, script_grind.drawPath = Checkbox("Draw Navmesh Move Path", script_grind.drawPath)
		if (script_grind.drawPath or script_grind.raycastPathing) then
			DrawNavMeshPath(true);
		elseif (not script_grind.drawPath) then
			DrawNavMeshPath(false);
		end
		wasClicked, script_grindEX.drawRaycastPath = Checkbox("Draw Raycast Path", script_grindEX.drawRaycastPath);
		wasClicked, script_grindEX.drawStatus = Checkbox("Draw Status Window", script_grindEX.drawStatus);
		wasClicked, script_grindEX.drawGather = Checkbox("Draw Gather Nodes", script_grindEX.drawGather);
		wasClicked, script_grindEX.drawTarget = Checkbox("Draw Unit Info", script_grindEX.drawTarget);
		wasClicked, script_grindEX.drawAutoPath = Checkbox("Draw Hotspot & Nodes", script_grindEX.drawAutoPath);
	end
end


function script_rotation:runRest()

	local localObj = GetLocalPlayer();
	local localMana = GetManaPercentage(localObj);
	local localHealth = GetHealthPercentage(localObj);


	if (localMana < self.restMana) or (localHealth < self.restHp) and (not IsInCombat()) then
	
		if (localMana < self.restMana and not IsDrinking()) or (localHealth < self.restHp and not IsEating()) then

			if (localMana <= self.restMana)
				and (not IsDrinking())
				and (not IsCasting())
				and (not IsChanneling())
				and (not IsMoving())
			then
				script_helper:drinkWater();
				self.waitTimer = GetTimeEX() + 2000;
				return true;
			end
			if (localHealth <= self.restHp)
				and (not IsEating())
				and (not IsCasting())
				and (not IsChanneling())
				and (not IsMoving())
			then
				script_helper:eat();
				self.waitTimer = GetTimeEX() + 2000;
				return true;
			end
		end
			
	end

return false;
end