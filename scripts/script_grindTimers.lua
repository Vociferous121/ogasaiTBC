script_grindTimers = {}

function script_grindTimers:timers()

	-- timers....
	script_grind.currentTime = GetTimeEX();
	script_rogue.waitTimer = GetTimeEX();
	script_mage.waitTimer = GetTimeEX();
	script_mage.gemTimer = GetTimeEX();
	script_warlock.waitTimer = GetTimeEX();
	script_warlocksiphonTime = GetTimeEX();
	script_warlockagonyTime = GetTimeEX();
	script_warlockcorruptTime = GetTimeEX();
	script_warlockimmoTime = GetTimeEX();
	script_warlockstoneTime = GetTimeEX();
	script_warrior.waitTimer = GetTimeEX();
	script_paladin.waitTimer = GetTimeEX();
	script_paladin.sealTimer = GetTimeEX();
	script_priest.waitTimer = GetTimeEX();
	script_shaman.waitTimer = GetTimeEX();
	script_hunter.waitTimer = GetTimeEX();
	script_druid.waitTimer = GetTimeEX();
	script_pather.waitTimer = GetTimeEX();
end