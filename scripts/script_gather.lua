script_gather = {
	isSetup = false,
	useVendor = false,
	useMount = true,
	nodeObj = nil,
	gatherDistance = 150,
	message = 'Gather...',
	collectMinerals = true,
	collectHerbs = true,
	herbs = {},
	numHerbs = 0,
	minerals = {},
	numMinerals = 0,
	lootDistance = 3,
	timer = 0,
	nodeID = 0,
	menu = include("scripts\\script_gatherMenu.lua"),
	gatherAllPossible = true,
	chests = {},
	numChests = 0,
}

function script_gather:addHerb(name, id, use, req)
	self.herbs[self.numHerbs] = {}
	self.herbs[self.numHerbs][0] = name;
	self.herbs[self.numHerbs][1] = id;
	self.herbs[self.numHerbs][2] = use;
	self.herbs[self.numHerbs][3] = req;
	self.numHerbs = self.numHerbs + 1;
end

function script_gather:addMineral(name, id, use, req)
	self.minerals[self.numMinerals] = {}
	self.minerals[self.numMinerals][0] = name;
	self.minerals[self.numMinerals][1] = id;
	self.minerals[self.numMinerals][2] = use;
	self.minerals[self.numMinerals][3] = req;
	self.numMinerals = self.numMinerals + 1;
end
function script_gather:addChest(name, id)
	self.chests[self.numChests] = {}
	self.chests[self.numChests][0] = name;
	self.chests[self.numChests][1] = id;
	self.numChests = self.numChests + 1;
end

function script_gather:setup()
	self.collectMinerals = HasSpell('Find Minerals');
	self.collectHerbs = HasSpell('Find Herbs');
	script_path.skin = HasSpell('Skinning');

	script_gather:addHerb('Peacebloom', 269, false, 1);
	script_gather:addHerb('Silverleaf', 270, false, 1);
	script_gather:addHerb('Earthroot', 414, false, 15);
	script_gather:addHerb('Mageroyal', 268, false, 50);
	script_gather:addHerb('Briarthorn', 271, false, 70);
	script_gather:addHerb('Stranglekelp', 700, false, 85);
	script_gather:addHerb('Bruiseweed', 358, false, 100);
	script_gather:addHerb('Wild Steelbloom', 371, false, 115);
	script_gather:addHerb('Grave Moss', 357, false, 120);
	script_gather:addHerb('Kingsblood', 320, false, 125);
	script_gather:addHerb('Liferoot', 677, false, 150);
	script_gather:addHerb('Fadeleaf', 697, false, 160);
	script_gather:addHerb('Goldthorn', 698, false, 170);
	script_gather:addHerb('Khadgars Whisker', 701, false, 185);
	script_gather:addHerb('Wintersbite', 699, false, 195);
	script_gather:addHerb('Firebloom', 2312, false, 205);
	script_gather:addHerb('Purple Lotus', 2314, false, 210);
	script_gather:addHerb('Arthas Tears', 2310, false, 220);
	script_gather:addHerb('Sungrass', 2315, false, 230);
	script_gather:addHerb('Blindweed', 2311, false, 235);
	script_gather:addHerb('Ghost Mushroom', 389, false, 245);
	script_gather:addHerb('Gromsblood', 2313, false, 250);
	script_gather:addHerb('Golden Sansam', 4652, false, 260);
	script_gather:addHerb('Dreamfoil', 4635, false, 270);
	script_gather:addHerb('Mountain Silversage', 4633, false, 280);
	script_gather:addHerb('Plaguebloom', 4632, false, 285);
	script_gather:addHerb('Icecap', 4634, false, 290);
	script_gather:addHerb('Black Lotus', 4636, false, 300);
	script_gather:addHerb('Mana Thistle', 6945, false, 300, 300);
	script_gather:addHerb('Nightmare Vine', 6946, false, 300);
	script_gather:addHerb('Netherbloom', 6947, false, 300);
	script_gather:addHerb('Dreaming Glory', 6948, false, 300);
	script_gather:addHerb('Ragveil', 6949, false, 300);
	script_gather:addHerb('Flame Cap', 6966, false, 300);
	script_gather:addHerb('Ancient Lichen', 6967, false, 300);
	script_gather:addHerb('Felweed', 6968, false, 300);
	script_gather:addHerb('Terocone', 6969, false, 300);
	script_gather:addHerb('Goldclover', 7844, false, 300);
	script_gather:addHerb('Talandras Rose', 7865, false, 300);
	script_gather:addHerb('Adders Tongue', 8084, false, 300);

	script_gather:addMineral('Copper Vein', 310, false, 1);
	script_gather:addMineral('Incendicite Mineral Vein', 384, false, 65);
	script_gather:addMineral('Tin Vein', 315, false, 65);
	script_gather:addMineral('Lesser Bloodstone Deposit', 48, false, 75);
	script_gather:addMineral('Silver Vein', 314, false, 75);
	script_gather:addMineral('Iron Deposit', 312, false, 125);
	script_gather:addMineral('Indurium Mineral Vein', 385, false, 150);
	script_gather:addMineral('Gold Vein', 311, false, 155);
	script_gather:addMineral('Mithril Deposit', 313, false, 175);
	script_gather:addMineral('Truesilver Deposit', 314, false, 205);
	script_gather:addMineral('Dark Iron Deposit', 2571, false, 230);
	script_gather:addMineral('Small Thorium Vein', 3951, false, 230);
	script_gather:addMineral('Rich Thorium Vein', 3952, false, 255);
	script_gather:addMineral('Fel Iron Deposit', 6799, false, 275);
	script_gather:addMineral('Adamantite Deposit', 6798, false, 325);
	script_gather:addMineral('Khorium Deposit', 6800, false, 375);
	script_gather:addMineral('Nethercite Deposit', 6650, false, 375);
		
	script_gather:addChest("Duskwood Chest", 123214);
	script_gather:addChest("Adamantite Bound Chest", 181802);
	script_gather:addChest("Battered Chest", 259);
	script_gather:addChest("Battered Chest", 2843);
	script_gather:addChest("Battered Chest", 2844);
	script_gather:addChest("Battered Chest", 2849);
	script_gather:addChest("Battered Chest", 106318);
	script_gather:addChest("Battered Chest", 106319);

	script_gather:addChest("Primitive Chest", 184793);
	script_gather:addChest("Large Iron Bound Chest", 74447);
	script_gather:addChest("Large Iron Bound Chest", 75297);
	script_gather:addChest("Large Iron Bound Chest", 75296);
	script_gather:addChest("Large Iron Bound Chest", 75295);
	script_gather:addChest("Bound Fel Iron Chest", 184934);
	script_gather:addChest("Bound Fel Iron Chest", 184932);
	script_gather:addChest("Bound Fel Iron Chest", 184931);
	script_gather:addChest("Large Mithril Bound Chest", 153468);
	script_gather:addChest("Large Mithril Bound Chest", 153469);
	script_gather:addChest("Large Mithril Bound Chest", 131978);
	script_gather:addChest("Bound Adamantite Chest", 184940);
	script_gather:addChest("Bound Adamantite Chest", 184938);
	script_gather:addChest("Bound Adamantite Chest", 184936);
	script_gather:addChest("Fel Iron Chest", 181798);
	script_gather:addChest("Heavy Fel Iron Chest", 181800);
	script_gather:addChest("Large Battered Chest", 75293);
	script_gather:addChest("Large Duskwood Chest", 131979);
	script_gather:addChest("Large Solid Chest", 74448);
	script_gather:addChest("Large Solid Chest", 75298);
	script_gather:addChest("Large Solid Chest", 75299);
	script_gather:addChest("Large Solid Chest", 75300);
	script_gather:addChest("Large Solid Chest", 153462);
	script_gather:addChest("Large Solid Chest", 153463);
	script_gather:addChest("Large Solid Chest", 153464);

	self.timer = GetTimeEX();

	self.isSetup = true;
end

function script_gather:ShouldGather(id)

	local herbSkill = script_gatherMenu:getHerbSkill();
	local miningSkill = script_gatherMenu:getMiningSkill();

	if(self.collectMinerals) then
		for i=0,self.numMinerals - 1 do
			if(self.minerals[i][1] == id and (self.minerals[i][2] or ((self.minerals[i][3] <= miningSkill) and self.gatherAllPossible))) then			
				return true;		
			end
		end
	end
	
	if(self.collectHerbs) then
		for i=0,self.numHerbs - 1 do
			if(self.herbs[i][1] == id and (self.herbs[i][2]or ((self.herbs[i][3] <= herbSkill) and self.gatherAllPossible) )) then			
				return true;		
			end
		end	
	end
end

function script_gather:GetNode()
	local targetObj, targetType = GetFirstObject();
	local bestDist = 9999;
	local bestTarget = nil;
	while targetObj ~= 0 do
		if (targetType == 5) then --GameObject
			if(script_gather:ShouldGather(GetObjectDisplayID(targetObj))) then
				local dist = GetDistance(targetObj);
				if(dist < self.gatherDistance and bestDist > dist) then
					local _x, _y, _z = GetPosition(targetObj);
					if(not IsNodeBlacklisted(_x, _y, _z, 5)) then
						bestDist = dist;
						bestTarget = targetObj;
					end
				end
			end
		end
		targetObj, targetType = GetNextObject(targetObj);
	end
	return bestTarget;
end

function script_gather:drawGatherNodes()
local targetObj, targetType = GetFirstObject();
	while targetObj ~= 0 do
		if (targetType == 5) then 
			local id = GetObjectDisplayID(targetObj);
			local name = '';
			local name2 = "";
			local name3 = "";
			local _x, _y, _z = GetPosition(targetObj);
			local _tX, _tY, onScreen = WorldToScreen(_x, _y, _z);
			local dist = math.floor(GetDistance(targetObj));
			if(onScreen) then
				for i=0,self.numHerbs - 1 do
					if (self.herbs[i][1] == id) then
						name = self.herbs[i][0];
						local this = ""..dist.." yd";
						DrawText(this, _tX-10, _tY+15, 255, 255, 0);
					end
				end

				for i=0,self.numMinerals - 1 do
					if (self.minerals[i][1] == id) then
						name = self.minerals[i][0];
						local this = ""..dist.." yd";
						DrawText(this, _tX-10, _tY+15, 255, 255, 0);
					end
				end
				for i=0,self.numChests - 1 do
					if (self.chests[i][1] == id) then
						name2 = self.chests[i][0];
						local this = ""..dist.." yd";
						DrawText(this, _tX-10, _tY+15, 255, 255, 0);
					end
				end

				DrawText(name, _tX-10, _tY, 255, 255, 0);
				DrawText(name2, _tX-10, _tY, 255, 255, 0);
				if (id ~= 192) and (id ~= 0) and (id ~= 386) then
					local idd = "ID - "..id.."";
					DrawText(idd, _tX-10, _tY-20, 255, 255, 0);
				end
		
			end
		end
		targetObj, targetType = GetNextObject(targetObj);
	end
end

function script_gather:currentGatherName()
	local name = ' ';
	if (self.nodeID ~= 0 and self.nodeID ~= nil) then
		for i=0,self.numHerbs - 1 do
			if (self.herbs[i][1] == self.nodeID) then
				name = self.herbs[i][0];
			end
		end

		for i=0,self.numMinerals - 1 do
			if (self.minerals[i][1] == self.nodeID) then
				name = self.minerals[i][0];
			end
		end
	end

	return name;
end

function script_gather:gather()
	
	if(not self.isSetup) then
		script_gather:setup();
	end

	if (self.timer > GetTimeEX()) then
		return true;
	end
	
	local tempNode = script_gather:GetNode();
	local newNode = (self.nodeObj == tempNode);
	self.nodeObj = script_gather:GetNode();
	self.nodeID = GetObjectDisplayID(self.nodeObj);
		
	if(self.nodeObj ~= nil and self.nodeObj ~= 0) then
		
		local _x, _y, _z = GetPosition(self.nodeObj);
		local dist = GetDistance(self.nodeObj);		
			
		if(dist < self.lootDistance) then
			script_path:savePos(true); -- SAVE FOR UNSTUCK
			if(IsMoving()) then
				StopMoving();
				self.timer = GetTimeEX() + 150;
			end

			if(not IsLooting() and not IsChanneling() and not IsMoving()) then
				GameObjectInteract(self.nodeObj);
				self.timer = GetTimeEX() + 4250;
			end
			if (not IsMoving()) and (IsLooting()) and (self.collectHerbs) then
				script_grind.waitTimer = GetTimeEX() + 2000;
			end

		else
			if (_x ~= 0) and (not script_grind.raycastPathing) then
				MoveToTarget(_x, _y, _z);
				self.timer = GetTimeEX() + 150;
			elseif (_x ~= 0) and (script_grind.raycastPathing) then
				script_pather:moveToTarget(_x, _y, _z);
				self.timer = GetTimeEX() + 150;
			end
		end

		return true;
	end

	return false;
end