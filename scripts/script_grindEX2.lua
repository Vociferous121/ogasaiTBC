script_grindEX2 = {}

function script_grindEX2:playersTargetingUs() -- returns number of players attacking us
	local nrPlayersTargetingUs = 0; 
	local i, type = GetFirstObject(); 
	while i ~= 0 do 
		if type == 4 then
			if (script_grindEX2:isTargetingMe(i)) then 
                		nrPlayersTargetingUs = nrPlayersTargetingUs + 1;
			end 
		end
		i, type = GetNextObject(i); 
	end
	return nrPlayersTargetingUs;
end

function script_grindEX2:isTargetingMe(i) 
	local localPlayer = GetLocalPlayer();
	if (localPlayer ~= nil and localPlayer ~= 0 and not IsDead(localPlayer)) then
		if (GetUnitsTarget(i) ~= nil and GetUnitsTarget(i) ~= 0) then
			return GetUnitsTarget(GetGUID(i)) == GetGUID(localPlayer);
		end
	end
	return false;
end

function script_grindEX2:isAnyTargetTargetingMe()
	local player = GetLocalPlayer();
	local add = nil;

	-- Return an a target targeting us
	local i, targetType = GetFirstObject();
	while i ~= 0 do
		if (targetType == 3) then
			if (GetGUID(GetUnitsTarget(i)) == GetGUID(player)) then 
				return true
			end
		end
		i, targetType = GetNextObject(i);
	end

return false;
end

function script_grindEX2:enemiesAttackingUs()

	local unitsAttackingUs = 0; 
        local localPlayer = GetLocalPlayer();
	local i, t = GetFirstObject(); 
	while i ~= 0 do 
    		if t == 3 then
			if (CanAttack(i) and not IsDead(i)) then
				if (localPlayer ~= nil and localPlayer ~= 0 and not IsDead(localPlayer)) then
					if (GetUnitsTarget(i) ~= nil and GetUnitsTarget(i) ~= 0) then
	                			unitsAttackingUs = unitsAttackingUs + 1; 
	                		end 
				end
	            	end 
	       	end
	i, t = GetNextObject(i); 
    	end
    return unitsAttackingUs;
end

function script_grindEX2:enemiesAttackingPet() -- returns number of enemies attacking us
	local unitsAttackingPet = 0; 
	local pet = GetPet();
	local i, t = GetFirstObject(); 

	-- if we have a pet
	if (pet ~= nil and pet ~= 0 and not IsDead(pet)) then

		while i ~= 0 do 
    			if t == 3 then
				if (CanAttack(i) and not IsDead(i)) then
				
					-- if target is targeting pet then
					if (GetUnitsTarget(i) ~= nil and GetUnitsTarget(i) ~= 0) then
	
						if (GetUnitsTarget(GetGUID(i)) == GetGUID(pet)) then
	                				unitsAttackingPet = unitsAttackingPet + 1; 
						end
	                		end 
				end
	            	end 
		i, t = GetNextObject(i); 
	       	end
	end
    return unitsAttackingPet;
end


function script_grindEX2:isTargetingPet(i) 
	local pet = GetPet();

	-- if we have a pet
	if (pet ~= nil and pet ~= 0 and not IsDead(pet)) then

		-- if target is targeting pet then
		if (GetUnitsTarget(i) ~= nil and GetUnitsTarget(i) ~= 0) then

			-- return true
			return GetUnitsTarget(GetTargetGUID(i)) == GetTargetGUID(pet);
		end
	end
	return false;
end