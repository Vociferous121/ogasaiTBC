script_checkDebuffs = {

}


-- use script_checkDebuffs:functionName(); as a boolean true or false.
-- returns true if player has debuff
-- returns false if player does not has debuff

-- make check for not specific debuffs like rend

function script_checkDebuffs:hasCurse()

	local player = GetLocalPlayer();

	if (HasDebuff(player, "Curse of Mending"))
		or (HasDebuff(player, "Curse of the Shadowhorn"))
		or (HasDebuff(player, "Curse of Recklessness"))


	then

		return true;

	else

		return false;
	end

end

function script_checkDebuffs:hasPoison()

	local player = GetLocalPlayer();

	if (HasDebuff(player, "Weak Poison"))
		or (HasDebuff(player, "Corrosive Poison"))
		or (HasDebuff(player, "Poison"))
		or (HasDebuff(player, "Slowing Poison"))
		or (HasDebuff(player, "Poisoned Shot"))
		or (HasDebuff(player, "Venom Spit"))
		or (HasDebuff(player, "Bottle of Poison"))
		or (HasDebuff(player, "Venom Sting"))


		then

		return true;
	else

		return false;
	end
end

function script_checkDebuffs:hasDisease()

	local player = GetLocalPlayer();

	if (HasDebuff(player, "Rabies"))
		or (HasDebuff(player, "Fevered Fatigue"))
		or (HasDebuff(player, "Dark Sludge"))
		or (HasDebuff(player, "Infected Bite"))
		or (HasDebuff(player, "Wandering Plague"))
		or (HasDebuff(player, "Plague Mind"))
		or (HasDebuff(player, "Fevered Fatigue"))
		or (HasDebuff(player, "Tetanus")) 
		or (HasDebuff(player, "Creeping Mold"))
		or (HasDebuff(player, "Diseased Slime"))
	
		then

		return true;
	else

		return false;
	end
end

function script_checkDebuffs:hasMagic()


	local player = GetLocalPlayer();

	if (HasDebuff(player, "Faerie Fire")) 
		or (HasDebuff(player, "Sleep"))
		or (HasDebuff(player, "Sap Might"))
		or (HasDebuff(player, "Frost Nova"))
		or (HasDebuff(player, "Fear"))
		or (HasDebuff(player, "Entangling Roots"))
		or (HasDebuff(player, "Sonic Burst"))

	
	then

		return true;

	else

		return false;
	end

end

function script_checkDebuffs:hasDisabledMovement()

	local player = GetLocalPlayer();

	if (HasDebuff(player, "Web"))
		or (HasDebuff(player, "Net"))
		or (HasDebuff(player, "Frost Nova"))
		or (HasDebuff(player, "Entangling Roots"))
		or (HasDebuff(player, "Slowing Poison"))


	then
	
		return true;

	else 
	
		return false;
	end
end

-- pet debuff checks
function script_checkDebuffs:petDebuff()

		local class = UnitClass('player');

	if (class == 'Hunter' or class == 'Warlock') and (GetLocalPlayer():GetLevel() >= 10) and (GetPet() ~= 0) then
		local pet = GetPet();
	
		if (pet:HasDebuff("Web"))
	
	
		then
	
			return true;
		
		else
	
			return false;
		end
	end
end

-- undead will of the forsaken
function script_checkDebuffs:undeadForsaken()
		
		local player = GetLocalPlayer();
	
	if (HasDebuff(player, "Sleep"))
		or (HasDebuff(player, "Fear"))
		or (HasDebuff(player, "Mind Control"))

	then

		return true;

	else

		return false;

	end

end

function script_checkDebuffs:hasSilence()

		local player = GetLocalPlayer();

	if (HasDebuff(player, "Silence"))
	or (HasDebuff(player, "Sonic Burst"))
	or (HasDebuff(player, "Overwhelming Stench"))

	then
	
		return true;
	
	else

		return false;
	end
end

function script_checkDebuffs:enemyBuff()
	
	local localObj = GetLocalPlayer();
	local hasTarget = localObj:GetUnitsTarget();
	
	if (script_grind.enemyObj ~= 0 and script_grind.enemyObj ~= nil) then
		if (hasTarget ~= 0) then

			local enemy = script_grind.enemyObj;
	
			if (enemy:HasBuff("Power Word:Shield")) 
			or (enemy:HasBuff("Quick Flame Ward"))
			or (enemy:HasBuff("Rejuvenation"))
			or (enemy:HasBuff("Regrowth"))
			or (enemy:HasBuff("Renew"))
			or (enemy:HasBuff("Mana Shield"))
			


			then
			
			return true;
	
			else
		return false;
			end
		end
	end
end