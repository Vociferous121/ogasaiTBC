script_helper = {
	water = {},
	numWater = 0,
	food = {},
	numFood = 0,
	myMounts = {},
	numMounts = 0,
	healthPotion = {},
	manaPotion = {},
	numHealthPotion = 0,
	numManaPotion = 0,
	ressMoveTimer = GetTimeEX(),
	jumpTimer = GetTimeEX(),
	waitTimer = GetTimeEX(),
	bandage = {},
	numBandage = 0,
}

function script_helper:inLineOfSight(target) 
	local x, y, z = GetPosition(GetLocalPlayer());
	local xt, yt, zt = GetPosition(target);

	if (GetDistance3D(x, y, z, xt, yt, zt) < 2) then
		return true;
	end 

	if (Raycast(x, y, z+1.5, xt, yt, zt+1.5)) then
		--DEFAULT_CHAT_FRAME:AddMessage('in line of sight');
		return true;
	end		
	
	return false;
end

function script_helper:distance3D(x, y, z, xx, yy, zz)
	return ((xx-x)^2 + (yy-y)^2 + (zz-z)^2)^(1/2);
end

function script_helper:jump()
	local jumpRandom = random(1,100);
	local isSwimming = IsSwimming();
	local jump = true;
	--if (isSwimming) or (script_grindEX.jumpInWater) then 
	--	jump = false;
	--	self.jumpTimer = GetTimeEX() + 20000; 
	--end

	--if (jumpRandom > 90 and jump and self.jumpTimer < GetTimeEX()) and (not IsSwimming()) then
	--	if (IsMoving()) then
	--		Jump();
	--	end
	--else
	--	StopJump();
	--end
end

function script_helper:ress(x, y, z)

	script_grind.tickRate = 50;

	if (self.waitTimer > GetTimeEX()) then
		return;
	end

	if (not IsDead(GetLocalPlayer())) then
		RepopMe();
	end

	local x, y, z = GetCorpsePosition();
	local xx, yy, zz = GetPosition(GetLocalPlayer());
	if (GetDistance3D(x, y, z, xx, yy, zz) <= 30) then
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
				aggro = GetLevel(i) - GetLevel(localObj) + 18;

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
			MoveToTarget(rX, rY, rZ);			

		return;
		end
			RetrieveCorpse();	
	end

	if (IsUsingNavmesh() or script_grind.raycastPathing) then
		if (not script_grind.raycastPathing) then
			if (MoveToTarget(x, y, z)) then
				if (IsMoving()) then
					self.waitTimer = GetTimeEX() + 450;
				end
			end

		else
			if (script_pather:moveToTarget(x, y, z)) then
				if (IsMoving()) then
					self.waitTimer = GetTimeEX() + 300;
				end
			end
		end
	else
		if (IsPathLoaded(1)) then
			self.waitTimer = GetTimeEX() + 450;
			Grave();
		else
			return "No grave path loaded...";
		end
	end

	return "Running to corpse...";

end

function script_helper:addBandage(name)
	self.bandage[self.numBandage] = name;
	self.numBandage = self.numBandage +1;
end

function script_helper:addHealthPotion(name)

	self.healthPotion[self.numHealthPotion] = name;
	self.numHealthPotion = self.numHealthPotion + 1;

end

function script_helper:addManaPotion(name)

	self.manaPotion[self.numManaPotion] = name;
	self.numManaPotion = self.numManaPotion + 1;

end

function script_helper:useBandage()

	---- Search for bandage
	local bandageIndex = -1;
	for i=0,self.numBandage do
		if (HasItem(self.bandage[i])) then
			bandageIndex = i;
			break;
		end
	end
	if (IsMoving()) then
		StopMoving();
		return;
	end
	if (HasItem(self.bandage[bandageIndex])) and (not HasDebuff(GetLocalPlayer(), "Recently Bandaged")) then
		if (IsMoving()) then
			StopMoving();
		return;
		end
		script_grind.waitTimer = GetTimeEX() + 1550;
		if (UseItem(self.bandage[bandageIndex])) then
			script_grind.waitTimer = GetTimeEX() + 10500;
			script_path.savedPos['time'] = GetTimeEX() + 5000;	
		return;
		end
	return true;
	end
end

function script_helper:useHealthPotion()

	-- Search for potion
	local potionIndex = -1;
	for i=0,self.numHealthPotion do
		if (HasItem(self.healthPotion[i])) then
			potionIndex = i;
			break;
		end
	end
		
	if(HasItem(self.healthPotion[potionIndex])) then
		if (UseItem(self.healthPotion[potionIndex])) then
			return true;
		end
	end
end

function script_helper:useManaPotion()

	-- Search for potion
	local potionIndex = -1;
	for i=0,self.numManaPotion do
		if (HasItem(self.manaPotion[i])) then
			potionIndex = i;
			break;
		end
	end
		
	if(HasItem(self.manaPotion[potionIndex])) then
		if (UseItem(self.manaPotion[potionIndex])) then
			return true;
		end
	end
end

function script_helper:addWater(name)
	self.water[self.numWater] = name;
	self.numWater = self.numWater + 1;
end

function script_helper:addFood(name)
	self.food[self.numFood] = name;
	self.numFood = self.numFood + 1;
end

function script_helper:addMount(name)
	self.myMounts[self.numMounts] = name;
	self.numMounts = self.numMounts + 1;
end

function script_helper:setup()

	-- Add Bandages
	script_helper:addBandage("Linen Bandage");
	script_helper:addBandage("Heavy Linen Bandage");
	script_helper:addBandage("Wool Bandage");
	script_helper:addBandage("Heavy Wool Bandage");
	script_helper:addBandage("Silk Bandage");
	script_helper:addBandage("Heavy Silk Bandage");
	script_helper:addBandage("Mageweave Bandage");
	script_helper:addBandage("Heavy Mageweave Bandage");
	script_helper:addBandage("Runecloth Bandage");
	script_helper:addBandage("Heavy Runecloth Bandage");


	-- Add Health Potions
	script_helper:addHealthPotion("Minor Healing Potion");
	script_helper:addHealthPotion("Lesser Healing Potion");
	script_helper:addHealthPotion("Healing Potion");
	script_helper:addHealthPotion("Superior Healing Potion");
	script_helper:addHealthPotion("Major Healing Potion");

	-- Add Mana Potions
	script_helper:addManaPotion("Minor Mana Potion");
	script_helper:addManaPotion("Lesser Mana Potion");
	script_helper:addManaPotion("Mana Potion");
	script_helper:addManaPotion("Superior Mana Potion");
	script_helper:addManaPotion("Major Mana Potion");

	-- Vendor water
	script_helper:addWater('Filtered Draenic Water');
	script_helper:addWater('Morning Glory Dew');
	script_helper:addWater('Moonberry Juice');
	script_helper:addWater('Sweet Nectar');
	script_helper:addWater('Melon Juice');
	script_helper:addWater('Ice Cold Milk');
	script_helper:addWater('Refreshing Spring Water');

	-- Mage water
	script_helper:addWater('Conjured Glacier Water');
	script_helper:addWater('Conjured Crystal Water');
	script_helper:addWater('Conjured Sparkling Water');
	script_helper:addWater('Conjured Mineral Water');
	script_helper:addWater('Conjured Spring Water');
	script_helper:addWater('Conjured Purified Water');
	script_helper:addWater('Conjured Fresh Water');
	script_helper:addWater('Conjured Water');

	-- Vendor mushroom food
	script_helper:addFood('Dried King Bolete');	
	script_helper:addFood('Raw Black Truffle');	
	script_helper:addFood('Delicious Cave Mold');	
	script_helper:addFood('Spongy Morel');
	script_helper:addFood("Red-speckled Mushroom");
	script_helper:addFood('Forest Mushroom Cap');

	-- Vendor fruit food
	script_helper:addFood('Deep Fried Plantains');
	script_helper:addFood('Moon Harvest Pumpkin');
	script_helper:addFood('Goldenbark Apple');
	script_helper:addFood('Snapvine Watermelon');
	script_helper:addFood("Tel'Abim Banana");
	script_helper:addFood('Shiny Red Apple');

	-- Vendor baked food
	script_helper:addFood("Mag'har Grainbread");
	script_helper:addFood('Tough Hunk of Bread');
	script_helper:addFood('Freshly Baked Bread');
	script_helper:addFood('Moist Cornbread');
	script_helper:addFood('Mulgore Spice Bread');
	script_helper:addFood('Soft Banana Bread');
	script_helper:addFood('Homemade Cherry Pie');
	
	-- Vendor meat food
	script_helper:addFood('Roasted Clefthoof');
	script_helper:addFood('Smoked Talbuk Venison');
	script_helper:addFood('Cured Ham Steak');
	script_helper:addFood('Haunch of Meat');
	script_helper:addFood('Mutton Chop');
	script_helper:addFood('Roasted Quail');
	script_helper:addFood('Tough Jerky');
	script_helper:addFood('Wild Hog Shank');
	
	-- Vendor cheese
	script_helper:addFood('Alterac Swiss');
	script_helper:addFood('Fine Aged Cheddar');
	script_helper:addFood('Stormwind Brie');
	script_helper:addFood('Dwarven Mild');
	script_helper:addFood('Dalaran Sharp');
	script_helper:addFood('Darnassian Bleu');
	
	-- Vendor fish food
	script_helper:addFood('Sunspring Carp');
	script_helper:addFood('Spinefin Halibut');
	script_helper:addFood('Striped Yellowtail');
	script_helper:addFood('Rockscale Cod');
	script_helper:addFood('Bristle Whisker Catfish');
	script_helper:addFood('Slitherskin Mackerel');
	script_helper:addFood('Longjaw Mud Snapper');

	-- Mage food
	script_helper:addFood('Conjured Croissant');
	script_helper:addFood('Conjured Cinnamon Roll');
	script_helper:addFood('Conjured Sweet Roll');
	script_helper:addFood('Conjured Sourdough')
	script_helper:addFood('Conjured Pumpernickel');
	script_helper:addFood('Conjured Rye');
	script_helper:addFood('Conjured Bread');
	script_helper:addFood('Conjured Muffin');

	-- Epic mounts
	script_helper:addMount("Black War Tiger");
	script_helper:addMount("Swift Frostsaber");
	script_helper:addMount("Swift Mistsaber");
	script_helper:addMount("Swift Stormsaber");
	script_helper:addMount("Deathcharger's Reins");
	script_helper:addMount('Black War Kodo');
	script_helper:addMount('Black War Ram');
	script_helper:addMount('Black War Steed Bridle');
	script_helper:addMount('Great Brown Kodo');
	script_helper:addMount('Great Gray Kodo');
	script_helper:addMount('Great White Kodo');
	script_helper:addMount('Green Kodo');
	script_helper:addMount('Horn of the Black War Wolf');
	script_helper:addMount('Horn of the Frostwolf Howler');
	script_helper:addMount('Horn of the Swift Brown Wolf');
	script_helper:addMount('Horn of the Swift Gray Wolf');
	script_helper:addMount('Horn of the Swift Timber Wolf');
	script_helper:addMount('Red Skeletal Warhorse');
	script_helper:addMount('Reins of the Black War Tiger');
	script_helper:addMount('Stormspike Battle Charger');
	script_helper:addMount('Swift Blue Raptor');
	script_helper:addMount('Swift Brown Ram');
	script_helper:addMount('Swift Brown Steed');
	script_helper:addMount('Swift Gray Ram');
	script_helper:addMount('Swift Green Mechanostrider');
	script_helper:addMount('Swift Olive Raptor');
	script_helper:addMount('Swift Orange Raptor');
	script_helper:addMount('Swift Palomino');
	script_helper:addMount('Swift Razzashi Raptor');
	script_helper:addMount('Swift White Mechanostrider');
	script_helper:addMount('Swift White Ram');
	script_helper:addMount('Swift White Steed');
	script_helper:addMount('Swift Yellow Mechanostrider');
	script_helper:addMount('Swift Zulian Tiger');
	script_helper:addMount('Teal Kodo');
	script_helper:addMount('Whistle of the Black War Raptor');
	script_helper:addMount('Whistle of the Ivory Raptor');
	script_helper:addMount('Whistle of the Mottled Red Raptor');

	-- Level 40 mounts
	script_helper:addMount('Black Stallion Bridle');
	script_helper:addMount('Blue Mechanostrider');
	script_helper:addMount('Blue Skeletal Horse');
	script_helper:addMount('Brown Horse Bridle');
	script_helper:addMount('Brown Kodo');
	script_helper:addMount('Brown Ram');
	script_helper:addMount('Brown Skeletal Horse');
	script_helper:addMount('Chestnut Mare Bridle');
	script_helper:addMount('Gray Kodo');
	script_helper:addMount('Gray Ram');
	script_helper:addMount('Green Mechanostrider');
	script_helper:addMount('Horn of the Brown Wolf');
	script_helper:addMount('Horn of the Dire Wolf');
	script_helper:addMount('Horn of the Timber Wolf');
	script_helper:addMount('Pinto Bridle');
	script_helper:addMount('Red Mechanostrider');
	script_helper:addMount('Red Skeletal Horse');
	script_helper:addMount('Unpainted Mechanostrider');
	script_helper:addMount('Whistle of the Emerald Raptor');
	script_helper:addMount('Whistle of the Turquoise Raptor');
	script_helper:addMount('Whistle of the Violet Raptor');
	script_helper:addMount('White Ram');
	script_helper:addMount('Reins of the Spotted Frostsaber');
	script_helper:addMount('Reins of the Striped Frostsaber');
	script_helper:addMount('Reins of the Striped Nightsaber');

end

function script_helper:eat()
	for i=0,self.numFood do
		if (not IsInCombat()) then
			if (HasItem(self.food[i])) then
				if (not UseItem(self.food[i])) then
					script_grind.waitTimer = GetTimeEX() + 1650;
					return true;
				end
			end
		end
	end
	return false;
end

function script_helper:drinkWater()
	for i=0,self.numWater do
		if (HasItem(self.water[i])) then
			if (not UseItem(self.water[i])) then
				script_grind.waitTimer = GetTimeEX() + 1650;
				return true;
			end
		end
	end
	return false;
end

function script_helper:useMount()
	if (HasSpell("Summon Dreadsteed")) then
		CastSpellByName("Summon Dreadsteed");
		return true;
	end
	
	if (HasSpell("Summon Felsteed")) then
		CastSpellByName("Summon Felsteed");
		return true;
	end

	if (HasSpell("Summon Charger")) then
		CastSpellByName("Summon Charger");
		return true;
	end

	if (HasSpell("Summon Warhorse")) then
		CastSpellByName("Summon Warhorse");
		return true;
	end
	
	for i=0,self.numMounts do
		if (HasItem(self.myMounts[i])) then
			if (UseItem(self.myMounts[i])) then
				return true;
			end
		end
	end
	return false;
end

function script_helper:hasAmmo()
	local id, textureName, checkRelic = GetInventorySlotInfo("AmmoSlot");
	local count = GetInventoryItemCount("player", id);
	return not (count == 1);
end

function script_helper:areBagsFull(skipBagID) 
	local inventoryFull = true;
	-- Check bags 1-5, except the bag skipBagID
	for i=1,5 do 
		if (i ~= skipBagID) then 
			for y=1,GetContainerNumSlots(i-1) do 
				local texture, itemCount, locked, quality, readable = GetContainerItemInfo(i-1,y);
				if (itemCount == 0 or itemCount == nil) then 
					inventoryFull = false; 
				end 
			end 
		end 
	end
	return inventoryFull;
end