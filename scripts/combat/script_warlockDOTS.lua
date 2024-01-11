script_warlockDOTS = {


}

function script_warlockDOTS:corruption(targetObj) 
	local currentObj, typeObj = GetFirstObject(); 
	local localObj = GetLocalPlayer();
	local mana = GetManaPercentage(localObj);
	if (IsInCombat()) and (mana >= 15) and (HasSpell("Corruption")) then
		while currentObj ~= 0 do 
			if typeObj == 3 then
				if (CanAttack(currentObj)) and (not IsDead(currentObj)) and (not IsCritter(currentObj)) then
					if (GetDistance(currentObj) <= 40) then
						if (not HasDebuff(currentObj, "Corruption")) and (IsInLineOfSight(currentObj)) then
							if (CastSpellByName('Corruption', currentObj)) then 
								script_grind:setWaitTimer(2500);
								script_warlock.waitTimer = GetTimeEX() + 2500;
								return true; 
							end
						end 
					end 
				end 
			end
        	currentObj, typeObj = GetNextObject(currentObj); 
		end
	end
return false;
end