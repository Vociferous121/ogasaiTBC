script_aggro = {
	
	drawAggro = false,
}


-- function to draw aggro circles on screen around targets
function script_aggro:DrawCircles(pointX,pointY,pointZ,radius)
	-- thx benjamin
	local r = 255;
	local g = 255;
	local b = 0;
	-- position
	local x = 25;

	-- we will go by radians, not degrees
	local sqrt, sin, cos, PI, theta, points, point = math.sqrt, math.sin, math.cos,math.pi, 0, {}, 0;
	while theta <= 2*PI do
		point = point + 1 -- get next table slot, starts at 0 
		points[point] = { x = pointX + radius*cos(theta), y = pointY + radius*sin(theta) }
		theta = theta + 2*PI / 50 -- get next theta
	end

	-- draw points
	for i = 1, point do
		local firstPoint = i
		local secondPoint = i + 1

		-- do next point
		if firstPoint == point then
			secondPoint = 1
		end

		-- draw points
		if points[firstPoint] and points[secondPoint] then
			local x1, y1, onScreen1 = WorldToScreen(points[firstPoint].x, points[firstPoint].y, pointZ)
			
			local x2, y2, onScreen2 = WorldToScreen(points[secondPoint].x, points[secondPoint].y, pointZ)
			-- make boolean string so i can post it to console
			onScreen1String = tostring(onScreen1);
			
			--ToConsole('x1 inside draw cirlces: ' .. x1 .. 'onScreen1: ' .. onScreen1String .. y1 .. x2 .. y2 .. redVar .. greenVar .. blueVar .. lineThickness);
			if onScreen1 == true and onScreen2 == true then
				DrawLine(x1, y1, x2, y2, r, g, b, 1)
				
			end
		end
	end
end

-- draw the actual aggro circles on the screen based on target and range
function script_aggro:drawAggroCircles(maxRange)
	local countUnitsInRange = 0;
	local currentObj, typeObj = GetFirstObject();
	local localObj = GetLocalPlayer();
	local closestEnemy = 0;

	-- run object manager
	while currentObj ~= 0 do
		
		-- acceptable targets
 		if typeObj == 3 and GetDistance(currentObj) < maxRange and not IsDead(currentObj) and CanAttack(currentObj) and not IsCritter(currentObj) then

			-- set conditions
			local aggro = GetLevel(currentObj) - GetLevel(localObj) + 15.0;
			local cx, cy, cz = GetPosition(currentObj);
			local px, py, pz = GetPosition(localObj);
		
			-- run draw circles based on currenyObj
			script_aggro:DrawCircles(cx, cy, cz, aggro);
 		end

		-- get next target
 		currentObj, typeObj = GetNextObject(currentObj);
 	end
end