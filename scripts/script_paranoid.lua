script_paranoid = {
	useParanoia = true,
	paranoidOn = true,
	waitTimer = GetTimeEX(),
	paranoidRange = 50,
	usedString = false,
	logoutOnParanoid = false,
	logoutTimerSet =  false,
	paranoiaUsed = false,
	stopMovement = true,
}

function script_paranoid:doParanoia()

	localObj = GetLocalPlayer();

	-- if paranoid turned on then do....
	if (script_paranoid.paranoidOn) and (not IsLooting()) and (not script_grind.pause) then

		-- if players in range
		if (script_paranoid:playersWithinRange(self.paranoidRange)) then

			if (HasSpell("Stealth")) and (not IsSpellOnCD("Stealth")) and (not HasBuff(localObj, "Stealth")) and (not IsInCombat()) and (not IsCasting()) and (not IsChanneling()) and (IsStanding()) and (not IsMounted()) and (not HasBuff(localObj, "Shadowmeld")) then
				if (CastSpellByName("Stealth")) then
					script_grind.waitTimer = GetTimeEX() + 1050;
				end
			end

			if (HasSpell("Shadowmeld")) and (not IsSpellOnCD("Shadowmeld")) and (not HasBuff(localObj, "Shadowmeld")) and (not IsInCombat()) and (not IsCasting()) and (not IsChanneling()) and (IsStanding()) and (not IsMounted()) and (not HasBuff(localObj, "Stealth")) and (not HasBuff(localObj, "Bear Form") and not HasBuff(localObj, "Dire Bear Form") and not HasBuff(localObj, "Cat Form")) then
				if (CastSpellByName("Shadowmeld")) then
					script_grind.waitTimer = GetTimeEX() + 1050;
				end
			end





			-- set logout timer when paranoid
			if (not self.logoutTimerSet) then
				script_grind.currentTime2 = GetTimeEX();
				self.logoutTimerSet = true;
			end

		return true;
		end
	end
return false;
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
						--local playerName = UnitName("target");
						if (CanAttack(i)) then
							local playerFaction = this;
						end
						if (not self.usedString) then
							local string ="Player in range | Time : " ..playerTimeHours..":"..playerTimeMinutes.. " | Distance (yds) "..playerDistance.. " | GUID - " ..playerGUID;
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