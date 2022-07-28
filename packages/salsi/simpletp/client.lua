local DoorsTable = {}
local doorsload = false

AddRemoteEvent("SendDoors", function(table)
	DoorsTable = table
end)

AddEvent("OnKeyPress", function(key)
	if key == "E" then
		local x, y, z = GetPlayerLocation()
		
		for k, v in pairs(DoorsTable) do
			if GetDistance3D(x, y, z, v.x, v.y, v.z) <= 100 then
				CallRemoteEvent("OnPlayerUseDoors", k, false)
			elseif GetDistance3D(x, y, z, v.x2, v.y2, v.z2) <= 100 then
				CallRemoteEvent("OnPlayerUseDoors", k, true)
			end
		end
		
	end
end)