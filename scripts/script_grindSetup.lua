script_grindSetup = {}

function script_grindSetup:setup()

	SetPVE(true);
	SetAutoLoot();
	DrawNavMeshPath(true);
	script_grind.skipMobTimer = GetTimeEX();
	script_grind.unStuckTime = GetTimeEX();
	script_grind.tryMountTime = GetTimeEX();
	script_grind.waitTimer = GetTimeEX();

	-- Classes that doesn't use mana
	local class, classFileName = UnitClass("player");

	if strfind("Warrior", class) or strfind("Rogue", class) then
		script_grind.useMana = false;
		script_grind.restMana = 0;
	end

	-- don't vendor if a mage
	if strfind("Mage", class) then
		script_grind.vendorRefill = false;
	end

	-- don't refill low level
	if GetLevel(GetLocalPlayer()) <= 5 then
		script_grind.vendorRefill = false;
	end

	-- don't use mount if we don't have one
	if GetLevel(GetLocalPlayer()) <= 39 then
		script_grind.useMount = false;
	end
	
	hotspotDB:setup();
	script_grindEX:setup();
	script_helper:setup();
	script_path:setup();
	script_target:setup();
	script_vendor:setup();
	script_talent:setup();
	script_pathFlyingEX:setup();

	-- sad (but working!) attempt to quickly adjust bot to use new rotation mode
	script_rogue.useRotation = false;
	script_mage.useRotation = false;
	script_druid.useRotation = false;
	script_paladin.useRotation = false;
	script_warrior.useRotation = false;
	script_shaman.useRotation = false;
	script_hunter.useRotation = false;
	script_priest.useRotation = false;
	script_warlock.useRotation = false;

	script_grind.currentMoney = GetMoney();
	local paranoiaRandom = math.random(30, 70);
	local paranoiaTimerRandom = math.random(20, 45);
	script_paranoid.paranoidRange = paranoiaRandom;
	script_grind.setLogoutTime = paranoiaTimerRandom;
end	