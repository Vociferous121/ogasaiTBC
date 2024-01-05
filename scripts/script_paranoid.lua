script_paranoid = {
	paranoidOn = true,
	waitTimer = GetTimeEX(),
	paranoidRange = 50,
	usedString = false,
}

function script_paranoid:doParanoia()

	localObj = GetLocalPlayer();

	-- if paranoid turned on then do....
	if (script_paranoid.paranoidOn) and (not IsLooting()) then

		-- if players in range
		if (script_paranoid:playersWithinRange(self.paranoidRange)) then
		
			return true;
		end
	end
end

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

			
