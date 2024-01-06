script_paranoid = {
	useParanoia = true,
	paranoidOn = true,
	waitTimer = GetTimeEX(),
	paranoidRange = 50,
	usedString = false,
	logoutOnParanoid = false,
	logoutOnParanoidTimer = GetTimeEX(),
	logoutTimerSet =  false,
	currentTime = 0,
	
}

function script_paranoid:doParanoia()

	localObj = GetLocalPlayer();

	-- if paranoid turned on then do....
	if (script_paranoid.paranoidOn) and (not IsLooting()) and (not script_grind.pause) then

		-- if players in range
		if (script_paranoid:playersWithinRange(self.paranoidRange)) then

			-- start paranoid timer
			script_paranoid.currentTime = GetTimeEX() / 1000;
			script_grind.message = "Player(s) within paranoid range, pausing...";
		
			return true;
		end
	end
end

--function script_paranoid.doEmotes()
	
--	if (self.paranoidOn) and (self.useParanoia) and (self.logoutTimerSet) then
		-- check for players in range... cannot use name... target by GUID?
			-- random seed
				-- check range and not player is targeting me and NOT DONE EMOTE YET
					-- do emote based on range
					-- EMOTE USED
					
					--else do emote based on this range
					-- EMOTE USED
					
					--else do emote based on this range
					-- EMOTE USED

				--end
				
				--elseif check range and player is targeting me then AND NOT DONE EMOTE YET
					-- do this emote
					-- EMOTE USED
					
					-- else do this emote
					-- EMOTE USED
		
					-- else do this emote
					-- EMOTE USED

				--end

--return false;
--end

function script_paranoid:playersWithinRange(range)

	local localObj = GetLocalPlayer();
	local i, t = GetFirstObject(); 

	while i ~= 0 do 
		if (t == 4 and not IsDead(i)) then
			if (GetDistance(i) < range) then 
				if (GetGUID(localObj) ~= GetGUID(i)) then
					if (GetDistance(i) < range) then
						
						local playerDistance = math.floor(GetDistance(i));
						local playerTimeHours, playerTimeMinutes = GetGameTime();
						local playerGUID = GetGUID(i);
						if (CanAttack(i)) then
							local playerFaction = this;
						end
						if (not self.usedString) then
							local string ="Paranoid - Player in range! | Time : " ..playerTimeHours..":"..playerTimeMinutes.. " | Distance (yds) "..playerDistance.. " | GUID - " ..playerGUID .." | added to log file."
							DEFAULT_CHAT_FRAME:AddMessage(string);
							ToFile(string);
							self.usedString = true;
						end
					return true;
					end
			
				end
			end
		end 
	i, t = GetNextObject(i);
	end
self.usedString = false;
return false;	
end