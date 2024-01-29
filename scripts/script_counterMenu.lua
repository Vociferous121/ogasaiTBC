script_counterMenu = {}

function script_counterMenu:menu()

	-- show text since last reload
	Text("Counters Since Last Reload - ");

		-- current script local counter is grind script counter
		local monsterKillCount = script_grind.monsterKillCount;

		-- show text monster kill count
		Text("Monster Kills : " ..monsterKillCount);


	-- get money amount
	
		-- get copper amount
		local moneyObtainedCount = script_grind.moneyObtainedCount;

		-- get silver from copper amount
		local moneyObtainedCountSilver = math.floor(moneyObtainedCount / 100);

		-- get gold from copper amount
		local moneyObtainedCountGold = math.floor(moneyObtainedCount / 10000);

		-- get silver amount from copper amount when we have gold
		local test = (moneyObtainedCount - moneyObtainedCountSilver * 100);

		-- get silver amount from gold amount when we have gold
		local test2 = math.floor((moneyObtainedCount - (moneyObtainedCountGold*10000)) / 100);
		
		if (moneyObtainedCount < 100) then

			-- show copper only
			Text("Money Obtained : " ..moneyObtainedCount.. " Copper");

		-- more than 100 copper but less than 10000 copper
		elseif (moneyObtainedCount > 100) and (moneyObtainedCount < 10000) then

			-- show silver and copper
			Text("Money Obtained : " ..moneyObtainedCountSilver .. " Silver " ..test.. " Copper");

		-- more than 10000 copper then we have 1 gold!
		elseif (moneyObtainedCount >= 10000) then

			-- show gold and silver
			Text("Money Obtained : " ..moneyObtainedCountGold.. " Gold " ..test2.. " Silver ");
		end

	-- show pickpocket money obtained
		if (HasSpell("Stealth")) and (script_rogue.useStealth) and (script_rogue.usePickPocket) then

			-- we should start with 0 money count...
			local copper = script_rogue.pickpocketMoney;

			if copper < 100 then
				-- less than 100 so no need to convert to silver - display copper count
				Text("Money Obtained Pick Pocketing : "..copper.. " Copper");
			end

			if copper > 100 and copper < 1000 then
				-- we need to convert to silver from copper
				local silverFromCopper = math.floor(copper / 100);
				local copperFromSilver = math.floor(copper / 100);
				Text("Money Obtained Pick Pocketing : "..silverFromCopper.." Silver "..copperFromSilver.." Copper");
			end
			if copper > 1000 then
				-- we need to convert to gold from COPPER COUNT
				local goldFromCopper =  math.floor(copper / 1000);
				local silverFromGold = goldFromCopper - math.floor(copper / 100);
				Text("Money Obtained Pick Pocketing : "..goldFromCopper..":"..silverFromGold);
			end

		end
end