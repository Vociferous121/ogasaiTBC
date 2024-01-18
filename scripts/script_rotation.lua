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
	faceTarget = true,
	adjustTickRate = false,
	lastTarget = 0,
	stickyTargeting = true,

	
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
	menuStuffLoaded = include("scripts\\script_grind.lua"),
	gatherNodesLoaded = include("scripts\\script_gather.lua"),


	
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
	if (strfind("Warrior", class) or strfind("Rogue", class)) then
		self.useMana = false;
		self.restMana = 0;
	end

	if (HasSpell("Summon Imp")) and (not HasSpell("Summon Voidwalker")) then
		script_warlock.useImp = true;
	end
	if (HasSpell("Summon Voidwalker")) and (not HasSpell("Summon Felguard")) then
		script_warlock.useVoid = true;
	end
	if (HasSpell("Summon Felguard")) then
		script_warlock.useFelguard = true;
	end

	self.isSetup = true;
	

end

function script_rotation:run()
	
	local localObj = GetLocalPlayer();
	local localMana = GetManaPercentage(localObj);
	local localHealth = GetHealthPercentage(localObj);

	-- Draw current target
	if (script_grindEX.drawTarget) then
		script_info:drawUnitsDataOnScreen();
	end
	
	if (script_grindEX.drawGather) then
		script_gather:drawGatherNodes();
	end

	if (script_aggro.drawAggro) then
		script_aggro:drawAggroCircles(65);
	end

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
	if (self.waitTimer > GetTimeEX()) then
		return;
	end
	
	-- set tick rate
	 self.waitTimer = GetTimeEX() + self.tickRate;

	if (not self.adjustTickRate) then
		if (not IsInCombat()) or (self.enemyObj == 0 and GetUnitsTarget(GetLocalPlayer()) == 0) then
			self.tickRate = 350;
		else
			self.tickRate = random(400, 950);
		end
	end

	-- last target is current our current target until told not ~= self.enemyObj
	if (self.enemyObj ~= 0 and self.enemyObj ~= nil) then
		self.lastTarget = self.enemyObj;
	end

	-- sticky targeting on current target only currently
	if (self.stickyTargeting) and (not IsInCombat() and not IsDead(self.lastTarget) and GetUnitsTarget(GetLocalPlayer()) == 0 or GetUnitsTarget(GetLocalPlayer()) == nil) and (not IsAutoCasting("Attack")) then
		AutoAttack(self.lastTarget);
	end

	-- Check: Summon our Demon if we are not in combat (Voidwalker is Summoned in favor of the Imp)
	if (HasSpell("Summon Imp")) then
		if (script_warlock:summonPet()) then
			return;
		end
	end

	-- reset enemyObj
	if (GetUnitsTarget(GetLocalPlayer()) == 0) or (GetUnitsTarget(GetLocalPlayer()) == nil) or (self.enemyObj ~= 0 and IsDead(self.enemyObj)) then
		self.enemyObj = 0;
	end

	-- if have a target in UI then run combat script
	if (GetTarget() ~= 0) and (GetHealthPercentage(GetTarget()) > 0 and not IsDead(GetTarget())) then

			self.enemyObj = GetTarget();

		if (self.enemyObj ~= 0 and self.enemyObj ~= nil) and (self.faceTarget) then
			if (not IsDead(self.enemyObj)) and (not IsMoving()) and (GetDistance(self.enemyObj) <= 36) and (IsInLineOfSight(self.enemyObj)) then
				FaceTarget(self.enemyObj);
			end
		end
			local creatureType = GetCreatureType(self.enemyObj);

		if (GetDistance(self.enemyObj) <= 5) and ( (not HasBuff(localObj, "Stealth")) or
		( (HasBuff(localObj, "Stealth") and script_rogue.pickpocketUsed) or (not script_rogue.usePickPocket) or (not strfind("Humanoid", creatureType) or not strfind("Undead", creatureType) )) ) then
			AutoAttack(self.enemyObj);
			if (GetHealthPercentage(self.enemyObj) >= 95) then
				StopMoving();
			end
		end

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

	SameLine();

	-- auto face target
	wasClicked, self.faceTarget = Checkbox("Auto Face Target", self.faceTarget);

	-- adjust tick rate
	wasClicked, self.adjustTickRate = Checkbox("Adjust Tick Rate", self.adjustTickRate);

	SameLine();

	-- sticky targeting
	wasClicked, self.stickyTargeting = Checkbox("Sticky Targeting", self.stickyTargeting);

	-- tick rate / reaction time
	Text("Reaction Time (ms)");
	self.tickRate = SliderInt("(ms)", 0, 2500, self.tickRate);
	
	Separator();

	-- Load combat menu by class
	local class = UnitClass("player");
	
	if (class == 'Mage') then
		script_mageEX:menu();
	elseif (class == 'Hunter') then
		script_hunterEX:menu();
	elseif (class == 'Warlock') then
		script_warlockEX:menu();
	elseif (class == 'Paladin') then
		script_paladinEX:menu();
	elseif (class == 'Druid') then
		script_druidEX:menu();
	elseif (class == 'Priest') then
		script_priestEX:menu();
	elseif (class == 'Warrior') then
		script_warriorEX:menu();
	elseif (class == 'Rogue') then
		script_rogueEX:menu();
	elseif (class == 'Shaman') then
		script_shamanEX:menu();
	end

	-- rest options
	if (CollapsingHeader("Rest options")) then
		
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
		wasClicked, script_grindEX.drawStatus = Checkbox("Draw Status Window", script_grindEX.drawStatus);
		wasClicked, script_grindEX.drawGather = Checkbox("Draw Gather Nodes", script_grindEX.drawGather);
		wasClicked, script_grindEX.drawTarget = Checkbox("Draw Unit Info", script_grindEX.drawTarget);
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