script_safeRess = {

 	currentRessAngle = 0,	-- res angle
	rX = 0,			-- res position
	rY = 0,			-- res position
	rZ = 0,			-- res position
	rTime = 0,		-- res time
}

-- find a safe spot to ressurect
function script_safeRess:safeRess(corpseX, corpseY, corpseZ, ressRadius) 
	local countUnitsInRange = 0;
	local i, typeObj = GetFirstObject();
	local localObj = GetLocalPlayer();
	local closestEnemy = 0;
	local closestDist = 999;
	local aggro = 0;
	local aggroClosest = 0;

	-- run object manager
	while i ~= 0 do

		-- NPC type 3
 		if typeObj == 3 then

			-- acceptable targets
			if CanAttack(i) and not IsDead(i) and not IsCritter(i) then

				-- set safe res distances based on level
				aggro = GetLevel(i) - GetLevel(localObj) + 15;

				-- extra safe range add 5 yards
				local range = aggro + 5;

				-- acceptable range to run avoid during ressurection
				if GetDistance(i) <= range then
		
					-- set closest enemy
					if (closestEnemy == 0) then
						closestEnemy = i;
						aggroClosest = GetLevel(i) - GetLevel(i) + 15;
				else
						-- get nearest enemy from closest enemy position
						local dist = GetDistance(i);
						local closestDist = 999

						-- rerun object manager until you find closest target in range
						if (dist < closestDist) then
		
							-- make that enemy the closest target
							closestDist = dist;

							-- closest enemy to avoid
							closestEnemy = i;
						end
					end
				end
 			end
 		end

		-- get next target
 		i, typeObj = GetNextObject(i);
 	end

	-- avoid the closest mob
	if (closestEnemy ~= 0) then

			-- set res angle each return
			self.currentRessAngle = self.currentRessAngle + 0.05;

			-- set position to move each return
			rX, rY, rZ = corpseX+ressRadius*math.cos(self.currentRessAngle), corpseY+ressRadius*math.sin(self.currentRessAngle), corpseZ;

			-- set res time
			rTime = GetTimeEX();

			-- move to point
			Move (rX, rY, rZ);			

		return true;
	end
return false;
end