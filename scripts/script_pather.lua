script_pather = {
	updatePathDist = 250,
	movedDist = 0,
	maxDist = 2000,
	straightPathSize = 2000,
	charWidth = 0.3,
	maxZSlopeUp = 0.60,
	maxZSlopeDown = -0.80,
	qualityZ = 1,
	zMin = 0.8,
	zMax = 1.6,
	qualityAngle = 16,
	timer = GetTimeEX(),
	message = "Raycast navigation by Logitech",
	meshSize = 25,
	nodeDist = 10,
	nodeDistUnmounted = 10,
	nodeDistMounted = 15,
	waypointPath = {},
	waypointPathSize = 0,
	path = {},
	pathSize = 0,
	drawMesh = false,
	sx = 0,
	sy = 0,
	sz = 0,
	dX = 0,
	dY = 0,
	dZ = 0,
	dx = 0,
	dy = 0,
	dz = 0,
	status = 0, -- 0 idle 1 generating 2 reset 
	goToIndex = 1,
	patherExtra = include("scripts\\script_patherEX.lua"),
	straightPath = include("scripts\\script_pathStraight.lua"),
	circlePath = include("scripts\\script_pathCircle.lua"),
	flyPath = include("scripts\\script_pathFlying.lua"),
	flyPathExtra = include("scripts\\script_pathFlyingEX.lua"),
	waitTimer = 0,
}

function script_pather:moveToTarget(xx, yy, zz)

	if (self.waitTimer > GetTimeEX() or IsCasting() or IsChanneling()) then
		return;
	end
	local localHealth = GetHealthPercentage(GetLocalPlayer());
	local localMana = GetManaPercentage(GetLocalPlayer());
	if (not IsInCombat()) and (script_info:nrTargetingMe() == 0) and (script_rogue.useBandage) and (localHealth <= script_rogue.eatHealth) and (localHealth > 35) and (not HasDebuff(localObj, "Recently Bandaged")) and (not IsDead(GetLocalPlayer())) then
		script_grind.message = "Trying to bandage...";
		if (IsMoving()) then
			StopMoving();
			return;
		end
	StopMoving();
	return;
	end

	if ( (script_info:nrTargetingMe() == 0 and not IsInCombat() and not IsFleeing(self.target)) or (not IsInCombat()) )
	and ( (localMana <= script_grind.restMana and script_grind.useMana) or (localHealth <= script_grind.restHp) ) and (not IsDead(GetLocalPlayer())) then
		script_grind.message = "Waiting to eat/drink...";
		if (IsMoving()) then
			StopMoving();
			return;
		end
	return true;
	end

	if (IsMounted()) then
		self.nodeDist = self.nodeDistMounted;
	else
		self.nodeDist = self.nodeDistUnmounted;
	end

	local localObj = GetLocalPlayer();
	local isCat = HasBuff(localObj, "Cat Form");
	local hasSprint = HasBuff(localObj, "Sprint");
	local isWolf = HasBuff(localObj, "Ghost Wolf");
	if (isCat or hasSprint or isWolf) then
		self.nodeDistance = 15;
		self.nodeDistUnmounted = 15;
	end

	local x, y, z = GetPosition(GetLocalPlayer());
	local dist = GetDistance3D(x, y, z, xx, yy, zz);
	local a = GetAngle(GetLocalPlayer());
	local zDiff = math.abs(zz - z);

	if (IsFlying() and dist < script_pathFlying.nodeDist and self.pathSize == self.goToIndex) then
		if (zDiff > 2) then
			SitStandOrDescendStart();
			return true;
		end
		DescendStop()
		Dismount();
		self.status = 2;
		return true;
	end

	if (dist < self.nodeDist and self.pathSize == self.goToIndex) then
		Move(xx, yy, zz);
		return true;
	end

	if (self.status == 2) then
		self.dX, self.dY, self.dZ = 0, 0, 0;
	end

	if (script_pathFlyingEX:canFly()) then
		if ((dist > 150) and not IsMounted()) then
			if (script_pathFlyingEX:useMount()) then
				return true;
			end
		end
	end

	local genNewPath = false;

	if (GetDistance3D(self.dX, self.dY, self.dZ, xx, yy, zz) > 2) then
		self.dX, self.dY, self.dZ = xx, yy, zz;
		genNewPath = true;
		self.path, self.pathSize = {}, 0;
	end	
	
	if (genNewPath) then
		self.status = 1;
		self.goToIndex = 2;
		self.sx, self.sy, self.sz = x, y, z;

		--if (IsMoving()) and (GetUnitsTarget(GetLocalPlayer()) == 0) then
		--	StopMoving();
		--	MoveForwardStop();
		--	DescendStop();
		--	AscendStop();
		--	self.dX, self.dY, self.dZ = 0, 0, 0;
		--	return true;
		--end

		-- Generate a path
		if (IsFlying() or script_pathFlyingEX:onMount()) then
			_, self.path, self.pathSize = script_pathFlying:generatePath(x, y, z, xx, yy, zz);
			self.status = 0;
			if (not IsFlying()) then
				Jump();
				StopJump();
				return true;
			end
		else
			local isWayPointPath, tempPath, size = script_pathCircle:generateMeshPath(x, y, z, xx, yy, zz);
			if (isWayPointPath) then
				self.waypointPath, self.waypointPathSize = tempPath, size;
				
				-- Trim the path
				local trim = true;
				while trim do
					self.waypointPath, self.waypointPathSize, trim = script_patherEX:trimPath(self.waypointPath, self.waypointPathSize, self.goToIndex, self.nodeDist);
				end	

				self.path, self.pathSize = self.waypointPath, self.waypointPathSize;
	
				self.status = 0;

				return true;
			else
				DEFAULT_CHAT_FRAME:AddMessage('Generation failed...');
				if (IsMoving()) then
					StopMoving();
				end
				self.path = {};
				self.pathSize = 0;
				return false;
			end
		end
	end

	if (self.pathSize == 0 or self.status == 1) then
		return true;
	end

	if (not IsDead(GetLocalPlayer())) then
		if (self.pathSize < 9) then
			self.updatePathDist = 50;
		end
		if (self.pathSize < 20) then
			self.updatePathDist = 100;
		end
		if (self.pathSize < 40) then
			self.updatePathDist = 150;
		end
	end

	-- update path after some moved distance for collission detection
	local cx, cy, cz = GetPosition(GetLocalPlayer());
	if (GetDistance3D(cx, cy, cz, self.sx, self.sy, self.sz) > self.updatePathDist) then
		self.status = 2;
		return;
	end



	local nodeDistance = script_pather.nodeDist;


	-- Moving through path logic
	if (self.goToIndex > 1 and self.goToIndex < self.pathSize) then
		nodeDistance = GetDistance3D(self.path[self.goToIndex-1]['x'], self.path[self.goToIndex-1]['y'], self.path[self.goToIndex-1]['z'], self.path[self.goToIndex]['x'], self.path[self.goToIndex]['y'], self.path[self.goToIndex]['z'])
	end

	if (self.path[self.goToIndex]['x'] ~= nil) then
		
		if (GetDistance3D(x, y, z, self.path[self.goToIndex]['x'], self.path[self.goToIndex]['y'], self.path[self.goToIndex]['z']) > nodeDistance*3 and nodeDistance > 5) then
			self.status = 2;
			self.pathSize = 0;
			return;
		end

		if (GetDistance3D(x, y, z, self.path[self.pathSize]['x'], self.path[self.pathSize]['y'], self.path[self.pathSize]['z']) < 2 and self.pathSize > 2) then
			if (IsMoving()) then
				StopMoving();
			end
			self.path = {};
			self.pathSize = 0;
			self.dX, self.dY, self.dZ = 0, 0, 0;
			return;
		end

		if (self.pathSize > self.goToIndex) then
			if (not IsDead(GetLocalPlayer())) then
				if (IsFlying() and GetDistance3D(x, y, z, self.path[self.goToIndex]['x'], self.path[self.goToIndex]['y'], self.path[self.goToIndex]['z']) < 7) then
					self.goToIndex = self.goToIndex + 1;
				else
					if (GetDistance3D(x, y, z, self.path[self.goToIndex]['x'], self.path[self.goToIndex]['y'], self.path[self.goToIndex]['z']) < math.min(nodeDistance/2, 4)) then
						self.goToIndex = self.goToIndex + 1;
					end
				end
			else
				local dist = math.sqrt((self.path[self.goToIndex]['x']-x)^2 + (self.path[self.goToIndex]['y']-y)^2);
				if (dist < math.min(nodeDistance/2, 4)) then
					self.goToIndex = self.goToIndex + 1;
				end
			end
		end
	end

	-- stop moving when we get close enough to target to cast spells...
	if (HasSpell("Fireball")) or (HasSpell("Smite")) or (HasSpell("Raptor Strike")) or (HasSpell("Shadow Bolt")) then
		local enemy = script_target.currentTarget;
		if (enemy ~= 0) and (enemy ~= nil) and (not IsDead(enemy)) and (GetDistance(enemy) <= 26) and (IsInLineOfSight(enemy)) then
			if (IsMoving()) then
				StopMoving();
				return true;
			end
		end
	end
	if (script_grind.moveToMeleeRange) and (enemy ~= 0) and (enemy ~= nil) and (not IsDead(enemy)) and (GetDistance(enemy) <= script_grind.meleeDistance) and (IsInLineOfSight(enemy)) then
		if (IsMoving()) then
			StopMoving();
			return true;
		end
	end

	Move(self.path[self.goToIndex]['x'], self.path[self.goToIndex]['y'], self.path[self.goToIndex]['z']);
		if (IsMoving()) then
			self.waitTimer = GetTimeEX() + 50;
		end
	return true;

end

function script_pather:jumpObstacles()
	if ( (script_patherEX:getObsMin(1) > 0.3 and script_patherEX:getObsMax(1) < 2.3) or 
		(script_patherEX:getObsMin(2) > 0.3 and script_patherEX:getObsMax(2) < 2.3) ) then
		Jump();
		StopJump();
	end
end

function script_pather:checkResetPath()
	
end

function script_pather:resetPath()
	self.goToIndex = script_patherEX:closestPathNode();
end

function script_pather:menu()
	--if (CollapsingHeader("[Raycast pathing options")) then
		Separator();
		Text("Pather v 0.3 - by Logitech");
		Text("Crashes when some values are changed...");
		Separator();
		local wasClicked = false;
		wasClicked, script_pather.drawMesh = Checkbox("Draw Mesh", script_pather.drawMesh);
		Text("Path accuracy");
		self.qualityAngle = SliderInt("PS", 3, 64, self.qualityAngle);
		Text("Maximum number of nodes in a straight path");
		self.straightPathSize = SliderInt("MN", 10, 250, self.straightPathSize);
		Text("Path node distance dismounted");
		if (self.pathSize == 0) then
			self.nodeDistUnmounted = SliderFloat("PND", 1, 20, self.nodeDistUnmounted);
		else
			self.nodeDistUnmounted = SliderFloat("PND", self.nodeDistUnmounted, 20, self.nodeDistUnmounted);
		end
		Text("Mounted path node distance");
		self.nodeDistMounted = SliderFloat("PNM", 1, 20, self.nodeDistMounted);
		Text("Maximum Z-slope uphill");
		self.maxZSlopeUp = SliderFloat("ZSU", 0.1, 1, self.maxZSlopeUp);
		Text("Maximum Z-slope downhill");
		self.maxZSlopeDown = SliderFloat("ZSD", -3, -0.1, self.maxZSlopeDown);
		Text("Obstacle Max Height (Z-axis)");
		self.zMax = SliderFloat("Omax", 1, 3, self.zMax);
		Text("Obstacle Min Height (Z-axis)");
		self.zMin = SliderFloat("Omin", 0.1, 1.5, self.zMin);
	--end
end