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
	script_gather:setup();
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

	script_grind.meleeDistance = 5;

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
 
	-- last target is current our current target until told not ~= self.enemyObj ***this***
	if (self.enemyObj ~= 0 and self.enemyObj ~= nil) and (not IsDead(self.lastTarget)) then
		self.lastTarget = self.enemyObj;
	end

	-- sticky targeting on current target only currently ***goes to this***
	if (self.stickyTargeting and CanAttack(self.lastTarget)) and (not IsInCombat() and not IsDead(self.lastTarget) and GetUnitsTarget(GetLocalPlayer()) == 0 or GetUnitsTarget(GetLocalPlayer()) == nil) and (not IsAutoCasting("Attack")) then
		AutoAttack(self.lastTarget);
	end

	-- Check: Summon our Demon if we are not in combat (Voidwalker is Summoned in favor of the Imp)
	if (HasSpell("Summon Imp")) then
		if (script_warlock:summonPet()) then
			return;
		end
	end

	-- Apply poisons if we are rogue and use poison is selected
	if (HasSpell("Poisons")) and (not IsInCombat()) and (script_rogue.usePoisons) then
		if (script_rogue:checkPoisons()) then
			self.waitTimer = GetTimeEX() + 4550;
			script_debug.debugCombat = "applying poisons";
			return;
		end
	end

	-- reset enemyObj
	if (GetUnitsTarget(GetLocalPlayer()) == 0) or (GetUnitsTarget(GetLocalPlayer()) == nil) or (self.enemyObj ~= 0 and IsDead(self.enemyObj)) then
		self.enemyObj = 0;
	end

	-- if we are in combat and we have no target then return a target...
	if (GetUnitsTarget(GetLocalPlayer()) == 0) and (IsInCombat()) then
		self.enemyObj = GetNearestEnemy();
	end

	-- if have a target in UI then run combat script else run rest script
	if (GetTarget() ~= 0) and (GetHealthPercentage(GetTarget()) > 0 and not IsDead(GetTarget())) then

			self.enemyObj = GetTarget();

		if (self.enemyObj ~= 0 and self.enemyObj ~= nil) and (self.faceTarget) then
			if (not IsDead(self.enemyObj)) and (not IsMoving()) and (GetDistance(self.enemyObj) <= 36) and (IsInLineOfSight(self.enemyObj)) and (CanAttack(self.enemyObj)) then
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

		-- is valid target
		local tarFaction = GetFactionInfo(self.enemyObj);
		local myFaction = GetFactionInfo(GetLocalPlayer());
		if (not CanAttack(self.enemyObj)) or (tarFaction == myFaction) then
			self.enemyObj = 0;
		end
			-- run combat scripts...
			RunCombatScript(self.enemyObj);
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

	if (CollapsingHeader("Rotation Menu")) then

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
	
end

	-- Load combat menu by class
	local class = UnitClass("player");
	
	if (class == 'Mage') then
		script_mageEX:menu();
		script_rotation.message = script_mage.message;
	elseif (class == 'Hunter') then
		script_hunterEX:menu();
		script_rotation.message = script_hunter.message;
	elseif (class == 'Warlock') then
		script_warlockEX:menu();
		script_rotation.message = script_warlock.message;
	elseif (class == 'Paladin') then
		script_paladinEX:menu();
		script_rotation.message = script_paladin.message;
	elseif (class == 'Druid') then
		script_druidEX:menu();
		script_rotation.message = script_druid.message;
	elseif (class == 'Priest') then
		script_priestEX:menu();
		script_rotation.message = script_priest.message;
	elseif (class == 'Warrior') then
		script_warriorEX:menu();
		script_rotation.message = script_warrior.message;
	elseif (class == 'Rogue') then
		script_rogueEX:menu();
		script_rotation.message = script_rogue.message;
	elseif (class == 'Shaman') then
		script_shamanEX:menu();
		script_rotation.message = script_shaman.message;
	end

	-- rest options
	if (CollapsingHeader("Rest Menu")) then
		
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

	if (CollapsingHeader("Display Menu")) then
		wasClicked, script_aggro.drawAggro = Checkbox("Draw Aggro Ranges", script_aggro.drawAggro);
		wasClicked, script_grindEX.drawStatus = Checkbox("Draw Status Window", script_grindEX.drawStatus);
		wasClicked, script_grindEX.drawGather = Checkbox("Draw Gather Nodes", script_grindEX.drawGather);
		wasClicked, script_grindEX.drawTarget = Checkbox("Draw Unit Info", script_grindEX.drawTarget);

		Separator();
		Text("Temp Debug Item ID's (chests)");
		wasClicked, script_grindMenu.showIDD = Checkbox("Show ID's", script_grindMenu.showIDD);
	end

	-- Draw info and status
	if (script_grindEX.drawStatus) then
		local pX, pY, onScreen = WorldToScreen(GetUnitsPosition(GetLocalPlayer()));
		pX = pX - 70;
		pY = pY + 100;
		if (onScreen) then
			DrawRectFilled(pX - 5, pY - 5, pX + 385, pY + 65, 0, 0, 0, 160, 0, 0);
			--DrawRect(pX - 5, pY - 5, pX + 385, pY + 65, 0, 190, 45,  1, 1, 1);
			DrawText("Rotation", pX, pY, 0, 190, 45);
			DrawText('Status: ' .. (script_rotation.message or " "), pX, pY+20, 255, 255, 0);
			DrawText('Script Speed: ' .. math.max(((script_rotation.waitTimer + script_rotation.tickRate) - GetTimeEX()), 0) .. ' ms', pX, pY+30, 255, 255, 255);
			DrawText("Melee Distance: " ..math.floor(script_grind.meleeDistance).."", pX+1, pY+40, 255, 255, 0);
			if (AreBagsFull()) then
				DrawText('Warning bags are full...', pX, pY+50, 255, 0, 0);
			end	
		end
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