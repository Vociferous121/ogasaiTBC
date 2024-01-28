script_rogueLockPick = {}

function script_rogueLockPick:draw()

if (NewWindow("test", 100, 100)) then
	script_rogueLockPick:menu();
end
end


function script_rogueLockPick:run()

	local box = script_rogueLockPick:getBox();
	if not IsCasting and not IsChanneling and GetDistance(box) <= 5 then
		GameObjectInteract(box);
	end
end
function script_rogueLockPick:menu()
if (CollapsingHeader("test")) then
end
end

function script_rogueLockPick:getBox()

	local i, t = GetFirstObject();
	while i ~= 0 do
		if t == 5 then
			local id = GetObjectDisplayID(i);
			if id == 10 then
				return t;
			end
		end
	i, t = GetNextObject(i);
	end
end