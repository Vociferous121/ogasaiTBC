script_paranoid = {
	paranoidOn = true,
	ignoreTarget = "Player",
	currentTime = 0,
	doEmote = true,
	didEmote = false,
	paranoiaUsed = false,
	waitTimer = GetTimeEX(),
	paranoidRange = 50,
}

function script_paranoid:doParanoia()

function script_paranoid:


function script_paranoid:checkParanoia()

	localObj = GetLocalPlayer();

	-- if paranoid turned on then do....
	if (script_paranoid.paranoidOn) and (not IsLooting()) then

		-- if players in range
		if (script_paranoiaCheck:playersWithinRange(self.paranoidRange)) and (not IsLooting()) then

			-- set paranoia used variable to stop double casting stuff on a return loop
			if (script_paranoiaCheck:playersWithinRange(self.paranoidRange)) then
				self.paranoiaUsed = true;
			end

			-- do emote. had to double check the variables or it was casting twice
			if (script_grind.playerParanoidDistance <= 40) and (self.doEmote) and (not self.didEmote) and (script_grind:playersTargetingUs() >= 1) then

				local randomEmote = math.random(0, 100);

				-- if within range >= 12 but less than 40
					-- do wave
				if (script_grind.playerParanoidDistance >= 12) and (randomEmote < 25) then

					self.waitTimer = GetTimeEX() + 1932;
					DoEmote("Wave", script_grind.paranoidTargetName);
					script_paranoia.doEmote = false;
					script_paranoia.didEmote = true;

					-- do dance
				elseif (script_grind.playerParanoidDistance >= 20) and (randomEmote < 50) then

					self.waitTimer = GetTimeEX() + 1932;
					DoEmote("Dance", script_grind.paranoidTargetName);
					script_paranoia.doEmote = false;
					script_paranoia.didEmote = true;

					-- do salute
				elseif (script_grind.playerParanoidDistance >= 20) and (randomEmote < 75) then

					self.waitTimer = GetTimeEX() + 1932;
					DoEmote("Salute", script_grind.paranoidTargetName);
					script_paranoia.doEmote = false;
					script_paranoia.didEmote = true;

					-- do moo
				elseif (script_grind.playerParanoidDistance >= 20) and (randomEmote < 100) then

					self.waitTimer = GetTimeEX() + 1932;
					DoEmote("Moo", script_grind.paranoidTargetName);
					script_paranoia.doEmote = false;
					script_paranoia.didEmote = true;
				end

				-- distance <= 20 then do
				if (script_grind.playerParanoidDistance <= 20) then

					local otherEmote = math.random(0, 100);

						-- do ponder
					if (otherEmote < 20) then
						DoEmote("Ponder", script_grind.paranoidTargetName);
						script_paranoia.doEmote = false;
						script_paranoia.didEmote = true;

						-- send message in chat
					elseif (otherEmote < 35) then
						SendChatMessage("need something?");
						script_paranoia.doEmote = false;
						script_paranoia.didEmote = true;

						-- send message in chat
					elseif (otherEmote < 50) then
						SendChatMessage("hello");
						script_paranoia.doEmote = false;
						script_paranoia.didEmote = true;

						-- send message in chat
					elseif (otherEmote < 65) then
						SendChatMessage("moo");
						script_paranoia.doEmote = false;
						script_paranoia.didEmote = true;
						
						-- do emote moo
					elseif (otherEmote < 85) then
						DoEmote("moo", script_grind.paranoidTargetName);
						script_paranoia.doEmote = false;
						script_paranoia.didEmote = true;

						-- send whisper
					elseif (otherEmote < 100) then
						--SendChatMessage("yes?", "Whisper", nil, script_grind.paranoidTargetName);
						DoEmote("Flex", script_grind.paranoidTargetName);
						script_paranoia.doEmote = false;
						script_paranoia.didEmote = true;
					end
				end	
			end

			-- start paranoid timer
			script_paranoia.currentTime = GetTimeEX() / 1000;
			script_grind.message = "Player(s) within paranoid range, pausing...";

			-- check stealth for paranoia
			if (not IsMounted()) then
				script_paranoiaEX:checkStealth2();
			end