script_counterMenu = {

}

function script_counterMenu:menu()

	-- show text since last reload
	Text("Counters Since Last Reload - ");

		-- count is grind script counter
		local monsterKillCount = script_grind.monsterKillCount;

		-- show text monster kill count
		Text("Monster Kills : " ..monsterKillCount);


	-- get money amount
	
		-- get copper amount
		local moneyObtainedCount = script_grind.moneyObtainedCount;

		-- get silver amount from copper
		local moneyObtainedCountSilver = math.floor(moneyObtainedCount / 100);

		-- get gold amount from copper
		local moneyObtainedCountGold = math.floor(moneyObtainedCount / 1000);

		-- silver from copper when we have gold
		local test = (moneyObtainedCount - moneyObtainedCountSilver * 100);

		-- copper from gold when we have gold??
		
	
		-- less than 100 copper
		if (moneyObtainedCount < 100) then

			-- show copper only
			Text("Money Obtained : " ..moneyObtainedCount.. " Copper");

		-- more than 100 copper but less than 1000 copper
		elseif (moneyObtainedCount > 100) and (moneyObtainedCount < 1000) then

			-- show silver and copper
			Text("Money Obtained : " ..moneyObtainedCountSilver .. " Silver " ..test.. " Copper");

		-- more than 1000 copper then we have 1 gold!
		elseif (moneyObtainedCount >= 1000) then

			-- show gold and silver
			Text("Money Obtained : " ..moneyObtainedCountGold.. " Gold " ..test.. " Silver");
		end

		if (HasSpell("Stealth")) and (script_rogue.useStealth) and (script_rogue.usePickPocket) then
			local ppmoney = script_rogue.pickpockMoney;
			if ppmoney < 100 then
				local ppmoneyObtained = script_rogue.pickPocketMoney;
				Text("Money Obtained Pick Pocketing : "..ppmoneyObtained);
			end
			if ppmoney > 100 and pp money < 1000 then
				local ppmoneyObtained = math.floor(ppmoney / 100);
				Text("Money Obtained Pick Pocketing : "..ppmoneyObtained);
			end
			if pp money > 1000 then
				local ppmoneyGold =  math.floor(ppmoney / 1000);
				local ppmoneySilver = ppmoneyGold - math.floor(ppmoney / 100);
				Text("Money Obtained Pick Pocketing : "..ppmoneyGold..":"..ppmoneySilver);
			end

		end
end