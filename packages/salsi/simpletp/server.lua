local doors = {
	{x= 191009.0, y= 206329.0, z= 1320.0,  h= -90.0, x2= 191012.0, y2= 206707.0, z2= 1322.0, h2=90.0},    -- Comico back entrance
	{x= 189357.0, y= 208903.0, z= 1311.0,  h= 90.0, x2= 189370.0, y2= 208488.0, z2= 1322.0, h2=-90.0}, -- Comico main entrance
	{x= 191238.0, y= 207037.0, z= 1322.0,  h= 180.0, x2= 191238.0, y2= 207037.0, z2= 2423.0, h2=180.0}, -- Ascenceur comico
	{x= 171636.0, y= 195417.0, z= 584.0,  h= -90.0, x2= 170138.0, y2= 194165.0, z2= 1396.0, h2=180.0}, -- Prefecture 1
    {x= 212114.0, y= 158762.0, z= 1322.0,  h= -90.0, x2= 213608.0, y2= 156060.0, z2= 2431.0, h2=180.0}, -- Hospital 1 
}
local text3d = {}

AddEvent("OnPackageStart", function()
	for k,v in pairs(doors) do
		text3d[k] = {}
		text3d[k].text = CreateText3D("[E]", 17, v.x, v.y, v.z + 100, 0.0, 0.0, 0.0)
		text3d[k].text2 = CreateText3D("[E]", 17, v.x2, v.y2, v.z2 + 100, 0.0, 0.0, 0.0)
	end
end)

AddEvent("OnPackageStop", function()
	for k,v in pairs(text3d) do
		DestroyText3D(v.text)
		DestroyText3D(v.text2)
	end
end)

AddEvent("OnPlayerSpawn", function(player)
	CallRemoteEvent(player, "SendDoors", doors)
end)


AddRemoteEvent("OnPlayerUseDoors", function(player, id, exit)
	local tp = doors[id]
	if tp ~= nil then
		if not exit then
			SetPlayerLocation(player, tp.x2, tp.y2, tp.z2)
			SetPlayerHeading(player, tp.h2)
		else
			SetPlayerLocation(player, tp.x, tp.y, tp.z)
			SetPlayerHeading(player, tp.h)
		end
	end
end)