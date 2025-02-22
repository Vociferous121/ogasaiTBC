script_pathMenu = {
	selectedHotspotID = 0,
	useAutoHotspots = true,
}
	
function script_pathMenu:menu()

	if (CollapsingHeader("Pathing Menu")) then
		local wasClicked = false;
		if (not script_path.reachedHotspot) then
			if (script_path.reachedHotspotDistance > script_path.grindingDist) then
				script_path.reachedHotspotDistance = script_path.grindingDist;
			end
		Text("Distance To Hotspot Reached");
		script_path.reachedHotspotDistance = SliderInt("RHSD", 10, 100, script_path.reachedHotspotDistance);
		end
		Text("Distance To Grind From Hotspot");
		script_path.grindingDist = SliderInt("Dist (yds)", 50, 2000, script_path.grindingDist);
		Separator();

 		wasClicked, script_grind.allowSwim = Checkbox("Allow Swimming", script_grind.allowSwim);
		if (script_grind.allowSwim) then
			SameLine();
			wasClicked, script_grindEX.jumpInWater = Checkbox("Jump While Swimming", script_grindEX.jumpInWater);
		end
		wasClicked, script_grind.useUnstuckScript = Checkbox("Use Raycasting Unstuck Script (has bugs)", script_grind.useUnstuckScript);
		wasClicked, script_grind.raycastPathing = Checkbox("Use raycast pathing (TBC Area)", script_grind.raycastPathing);
		if (script_grind.raycastPathing) then
			SameLine();
			if (not script_grind.showRayMenu) then
				if Button("Show options") then 
					script_grind.showRayMenu = not script_grind.showRayMenu;
				end
			else
				if Button("Hide options") then 
					script_grind.showRayMenu = not script_grind.showRayMenu;
				end
			end
		end

		wasClicked, self.useAutoHotspots = Checkbox("Use Auto Hotspots", self.useAutoHotspots);
		wasClicked, script_path.autoLoadHotspot = Checkbox("Auto Load Hotspot from hotspotDB.lua", script_path.autoLoadHotspot);

		if (Button("Set current position as the new hotspot")) then
			script_path:resetHotspot(); 
			script_path.currentHotspotID = -1; 
			script_path.autoLoadHotspot = false;
			script_path:printHotspot();
		end

	
			Separator();
	
		if (script_grind.showRayMenu) then
			script_pather:menu();
			Separator();
		end

		if (IsUsingNavmesh() or script_grind.raycastPathing) then
			if (not script_grind.raycastPathing) then
				if Button("Disable Nav Mesh and Auto Pathing")
					then UseNavmesh(false);
				end
			end

			Separator();
	
			if (not self.useAutoHotspots) then
				if (Button("Auto Load a hotspot from database.")) then
					script_path:updateHotspot(); 
					script_path.autoLoadHotspot = true;
				end
	
				Text("Select a hotspot from database:");
				wasClicked, self.selectedHotspotID = 
					ComboBox("", self.selectedHotspotID, unpack(hotspotDB.selectionList));
	
				SameLine();
					
				if Button("Load") then
					script_path.autoLoadHotspot = false;
					script_pathMenu:setHotspotByID(self.selectedHotspotID+1);
				end
		
				Separator();
			end
		
			if (CollapsingHeader("|+| Move Node Distance")) then
				Text("Move path node distance");
				script_path.navNodeDist = SliderFloat("ND", 1, 20, script_path.navNodeDist);
				Text("Move path node distance while mounted");
				script_path.navNodeDistMounted = SliderFloat("NDM", 1, 20, script_path.navNodeDistMounted);
			end
		else
			if Button("Enable Nav Mesh and Auto Pathing") then UseNavmesh(true); script_grind.useNavMesh = true; end
			Text("See pathing in the oGasai tab!");
		end
	end
end

function script_pathMenu:setHotspotByID(id)
	script_path.hotspotID = hId;
	script_path.savedPathNodes = {};
	script_path.numSavedPathNodes = 0;
	script_path.reachedHotspot = false;
	local hotspot = hotspotDB:getHotSpotByID(id);
	script_path.hx, script_path.hy, script_path.hz = hotspot['pos']['x'], hotspot['pos']['y'], hotspot['pos']['z'];
	script_path.hName = hotspot['name'];
end

function script_pathMenu:closestPathNode()
	local dist = 100;
	local nr = 0;
	local localObj = GetLocalPlayer();
	local _lx, _ly, _lz = GetPosition(localObj);
	for i = 0,script_path.numSavedPathNodes-1 do
		local nodeDist = math.sqrt((script_path.savedPathNodes[i]['x']-_lx)^2+(script_path.savedPathNodes[i]['y']-_ly)^2);
		if (nodeDist < dist) then dist = nodeDist; nr = i; end
	end
	return nr;
end