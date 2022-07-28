local OnsetRP = ImportPackage("onsetrp")

local MetalDetector = {
	{x= 214508.0, y= 190930.0, z= 1200.0, InUse = false},
    {x= 190528.0, y= 208340.0, z= 1259.0, InUse = false},
  	{x= 186177.0, y= 193183.0, z= 6757.0, InUse = false},
 	{x= 186171.0, y= 193049.0, z= 6757.0, InUse = false},
}
local Distance = 150.0
local SoundDistance = 3000.0
local BlacklistItems = { 
	"weapon_2",
	"weapon_3",
	"weapon_4",
	"weapon_5",
	"weapon_6",
	"weapon_7",
	"weapon_8",
	"weapon_9",
	"weapon_10",
	"weapon_11",
	"weapon_12",
	"weapon_13",
	"weapon_14",
	"weapon_15",
	"weapon_16",
	"weapon_17",
	"weapon_18",
	"weapon_19",
	"weapon_20",
	"weapon_21"
}

AddEvent("OnPackageStart", function()
	CreateTimer(function()
		for _, detect in pairs(MetalDetector) do
			local players = GetPlayersInRange3D(detect.x, detect.y, detect.z, Distance) 
			for _, player in pairs(players) do
				if detect.InUse == false then
					playerData = OnsetRP.GetPlayerData(player)
					if playerData.inventory then
						for k, _ in pairs(playerData.inventory) do
							for _, v in pairs(BlacklistItems) do
								if k == v then
									local players = GetPlayersInRange3D(detect.x, detect.y, detect.z, SoundDistance)
									for _, v in pairs(players) do
										CallRemoteEvent(v, "BeepSound", detect.x, detect.y, detect.z)
										detect.InUse = true
										Delay(800, function()
											detect.InUse = false
										end)
									end
									return
								end
							end
						end
					end
				end
			end
		end
	end, 100)
end)