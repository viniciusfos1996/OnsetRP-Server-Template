local _ = function(k,...) return ImportPackage("i18n").t(GetPackageName(),k,...) end

local teleportPlace = {
    gas_station = { 125773, 80246, 1645 },
    town = { -182821, -41675, 1160 },
    prison = { -167958, 78089, 1569 },
    diner = { 212405, 94489, 1340 },
    city = { 211526, 176056, 1250 },
    desert_town = { -16223, -8033, 2062 },
    old_town = { 39350, 138061, 1570 },
    gun_dealer = { 206071, 193057, 1357 },
    license_shop = { 169336, 193430, 1307 },
    police_station = { 193285, 206608, 1400 },
    police_station_2 = { -174742, -64655, 1248 },
    circuit = { -81369, 31643, 4704 },
    airport = { 151187, -145085, 1250 },
    harbour = { 66726, 185960, 536 },
    western = { -80339, -157846, 3223 },
    mountain = { -190210, -1831, 7462 },
    training = { -13789, 136500, 1544 },
    lumberjack_gather = {-215796,-74619,  291},
    lumberjack_process_1 = {-70149, -59260, 1466},
    lumberjack_supplier = {203566, 171875, 1306},
    peach_gather = {-174432, 10837, 1831},
    cocaine_gather = {74387, -137535, 2178},
    cocaine_process = {-215517, -92653, 2293},
    fishing_gather_1 = {232464, 193521, 112},
    fishing_gather_2 = {-220130, 23036, 107},
    fishing_supplier = {-21295, -22954, 2080},
    mining_gather = {-101174, 98223, 180},
    mining_process_1 = {-82629, 90991, 481},
    mining_process_2 = {-191437, -31107, 1148},
    mining_supplier = {67862, 184741, 535},
    ironsmith = {-189805, -34122, 1148},
    hospital = {213530, 158344, 1416},
    taxi_center = {175330,160737,4959}
}

local weaponList = {
    weapon_2 = 2,
    weapon_3 = 3,
    weapon_4 = 4,
    weapon_5 = 5,
    weapon_6 = 6,
    weapon_7 = 7,
    weapon_8 = 8,
    weapon_9 = 9,
    weapon_10 = 10,
    weapon_11 = 11,
    weapon_12 = 12,
    weapon_13 = 13,
    weapon_14 = 14,
    weapon_15 = 15,
    weapon_16 = 16,
    weapon_17 = 17,
    weapon_18 = 18,
    weapon_19 = 19,
    weapon_20 = 20,
    weapon_21 = 21
}

local vehicleList = {
    vehicle_1 = 1,
    vehicle_2 = 2,
    vehicle_3 = 3,
    vehicle_4 = 4,
    vehicle_5 = 5,
    vehicle_6 = 6,
    vehicle_7 = 7,
    vehicle_8 = 8,
    vehicle_9 = 9,
    vehicle_10 = 10,
    vehicle_11 = 11,
    vehicle_12 = 12,
    vehicle_13 = 13,
    vehicle_14 = 14,
    vehicle_15 = 15,
    vehicle_16 = 16,
    vehicle_17 = 17,
    vehicle_18 = 18,
    vehicle_19 = 19,
    vehicle_20 = 20,
    vehicle_21 = 21,
    vehicle_22 = 22,
    vehicle_23 = 23,
    vehicle_24 = 24,
    vehicle_25 = 25
}

AddRemoteEvent("ServerAdminMenu", function(player)
    local playersIds = GetAllPlayers()

    if tonumber(PlayerData[player].admin) == 1 then
        playersNames = {}
        for k,v in pairs(playersIds) do
            if PlayerData[k] == nil then
                goto continue
            end
            if PlayerData[k].name == nil then
                goto continue
            end
            if PlayerData[k].steamname == nil then
                goto continue
            end
            playersNames[tostring(k)] = PlayerData[k].name.." ["..PlayerData[k].steamname.."]"
            ::continue::
        end
        local query = mariadb_prepare(sql, "SELECT * FROM logs ORDER BY id DESC LIMIT 50;")
    
        mariadb_async_query(sql, query, OnLogListLoadd, player, playersNames)
    end
end)

function OnLogListLoadd(player, playersName)
    local logList = {}
    for i=1,mariadb_get_row_count() do
        local result = mariadb_get_assoc(i)

        local id = tostring(result["id"])
        local action = result["action"]
        logList[tostring(id)] = action
    end
    
    CallRemoteEvent(player, "OpenAdminMenu", teleportPlace, playersNames, weaponList, vehicleList, logList)
end

AddRemoteEvent("admin:menu:getitemlist", function(player)
    local itemList = {}
    for k,v in pairs(Items) do
        itemList[k] = _(v.name)
    end
    CallRemoteEvent(player, "admin:menu:showitemmenu", itemList)    
end)

AddRemoteEvent("AdminCuffPlayer", function(player, toPlayer)
    if tonumber(PlayerData[player].admin) ~= 1 then return end
    if PlayerData[toPlayer].is_cuffed == 1 then
        SetPlayerCuffed(toPlayer, false)
    else
        SetPlayerCuffed(toPlayer, true)
    end
end)  

AddRemoteEvent("AdminRezPlayer", function(player, toPlayer)
    if tonumber(PlayerData[player].admin) ~= 1 then return end
    if GetPlayerHealth(toPlayer) == nil or GetPlayerHealth(toPlayer) == false or GetPlayerHealth(toPlayer) > 0 then return end
    local x, y, z = GetPlayerLocation(toPlayer)
    local h = GetPlayerHeading(toPlayer)
    SetPlayerSpawnLocation(toPlayer, x, y, z, h)
    PlayerData[toPlayer].has_been_revived = true
    SetPlayerRespawnTime(toPlayer, 0)
    Delay(100, function()
        SetPlayerHealth(toPlayer, 100)
        PlayerData[toPlayer].health = 100
    end)
end)  

AddRemoteEvent("AdminHealPlayer", function(player, toPlayer)
    if tonumber(PlayerData[player].admin) ~= 1 then return end
    StopBleedingForPlayer(toPlayer)
    CallRemoteEvent(toPlayer, "damage:bleed:toggleeffect", 0)
    SetPlayerHealth(toPlayer, 100)    
end)    

AddRemoteEvent("AdminFreezePlayer", function(player, toPlayer)
    if tonumber(PlayerData[player].admin) ~= 1 then return end
    local IsFroze = GetPlayerPropertyValue(toPlayer, "Admin:IsFroze") or 0
    if IsFroze == 1 then
        CallRemoteEvent(toPlayer, "LockControlMove", false)
        SetPlayerNotBusy(toPlayer)
        SetPlayerPropertyValue(toPlayer, "Admin:IsFroze", 0, true)
    else
        CallRemoteEvent(toPlayer, "LockControlMove", true)
        SetPlayerBusy(toPlayer)
        SetPlayerPropertyValue(toPlayer, "Admin:IsFroze", 1, true)
    end        
end)

AddRemoteEvent("AdminRagdollPlayer", function(player, toPlayer)
    if tonumber(PlayerData[player].admin) ~= 1 then return end
    local IsRagdolled = GetPlayerPropertyValue(toPlayer, "Admin:IsRagdolled") or 0
    if IsRagdolled == 1 then
        CallRemoteEvent(toPlayer, "LockControlMove", false)
        SetPlayerRagdoll(toPlayer, false)        
        SetPlayerNotBusy(toPlayer)
        SetPlayerPropertyValue(toPlayer, "Admin:IsRagdolled", 0, true)
    else
        CallRemoteEvent(toPlayer, "LockControlMove", true)
        SetPlayerRagdoll(toPlayer, true)     
        SetPlayerBusy(toPlayer)
        SetPlayerPropertyValue(toPlayer, "Admin:IsRagdolled", 1, true)
    end        
end)

AddRemoteEvent("AdminTeleportToPlace", function(player, place)
    if tonumber(PlayerData[player].admin) ~= 1 then return end

    for k,v in pairs(teleportPlace) do
        if k == place then
            SetPlayerLocation(player, v[1], v[2], v[3] + 200)
        end
    end
end)

AddRemoteEvent("AdminTeleportToPlayer", function(player, toPlayer)
    if tonumber(PlayerData[player].admin) ~= 1 then return end
    local x, y, z  = GetPlayerLocation(tonumber(toPlayer))
    SetPlayerLocation(player, x, y, z + 200)
end)

AddRemoteEvent("AdminTeleportPlayer", function(player, toPlayer, tpPlayer)
    if tonumber(PlayerData[player].admin) ~= 1 then return end
    local x, y, z  = GetPlayerLocation(tonumber(toPlayer))
    SetPlayerLocation(tpPlayer, x, y, z + 200)
end)

AddRemoteEvent("AdminGiveWeapon", function(player, weaponName)
    if tonumber(PlayerData[player].admin) ~= 1 then return end
    weapon = weaponName:gsub("weapon_", "")
    SetPlayerWeapon(player, tonumber(weapon), 1000, true, 1, true)
end)

AddRemoteEvent("AdminSpawnVehicle", function(player, vehicleName)
    if tonumber(PlayerData[player].admin) ~= 1 then return end
    vehicle = vehicleName:gsub("vehicle_", "")

    local x, y, z = GetPlayerLocation(player)
    local h = GetPlayerHeading(player)

    spawnedVehicle = CreateVehicle(tonumber(vehicle), x, y, z, h)

    SetVehicleRespawnParams(spawnedVehicle, false)
    SetPlayerInVehicle(player, spawnedVehicle)
end)

AddRemoteEvent("AdminGiveMoney", function(player, toPlayer, account, amount)
    if tonumber(PlayerData[player].admin) ~= 1 then return end
    if account == "Cash" then
        AddPlayerCash(tonumber(toPlayer), amount)
    end
    if account == "Bank" then
        PlayerData[tonumber(toPlayer)].bank_balance = PlayerData[tonumber(toPlayer)].bank_balance + tonumber(amount)
    end
end)

AddRemoteEvent("AdminGiveItem", function(player, toPlayer, qty, item)
    if tonumber(PlayerData[player].admin) ~= 1 then return end
    if AddInventory(tonumber(toPlayer), Items[tonumber(item)].name, tonumber(qty)) then
        CallRemoteEvent(player, "MakeNotification", _("admin_give_item_success"), "linear-gradient(to right, #00b09b, #96c93d)")
    else
        CallRemoteEvent(player, "MakeErrorNotification", _("admin_give_item_fail"))
    end
end)

AddRemoteEvent("AdminKickBan", function(player, toPlayer, type, reason)
    if player == toPlayer then return end -- Protection anti fatigue Kappa
    if tonumber(PlayerData[player].admin) ~= 1 then return end
    if type == "Ban" then
        mariadb_query(sql, "INSERT INTO `bans` (`steamid`, `ban_time`, `reason`) VALUES ('"..PlayerData[tonumber(toPlayer)].steamid.."', '"..os.time(os.date('*t')).."', '"..reason.."');")

        KickPlayer(tonumber(toPlayer), _("banned_for", reason, os.date('%Y-%m-%d %H:%M:%S', os.time())))
    end
    if type == "Kick" then
        KickPlayer(tonumber(toPlayer), _("kicked_for", reason))
    end
end)

AddCommand("delveh", function(player)
    if tonumber(PlayerData[player].admin) ~= 1 then return end
    local vehicle = GetPlayerVehicle(player)

    if vehicle ~= nil then
        DestroyVehicle( vehicle )
    end
end)

AddEvent("OnPlayerDeath", function(player, instigator)
    message = PlayerData[player].name .. " was killed by " .. PlayerData[instigator].name
    local query = mariadb_prepare(sql, "INSERT INTO logs VALUES (NULL, NULL, '?');",
		message)

	mariadb_async_query(sql, query)
end)

AddEvent("OnPlayerDamage", function(player, damagetype, amount)
    local DamageName = {
		"Weapon",
		"Explosion",
		"Fire",
		"Fall",
		"Vehicle Collision"
	}

    message = PlayerData[player].name.."("..player..") took "..amount.." damage of type "..DamageName[damagetype]
    local query = mariadb_prepare(sql, "INSERT INTO logs VALUES (NULL, NULL, '?');",
    message)

    mariadb_async_query(sql, query)
end)

AddEvent("OnPlayerWeaponShot", function(player, weapon, hittype, hitid, hitX, hitY, hitZ, startX, startY, startY, normalX, normalY, normalZ)
	local action = {
		"in the air",
		"at player",
		"at vehicle",
		"an NPC",
		"at object",
		"on ground",
		"in water"
	}
	
	message = PlayerData[player].name.."("..player..") shot "..action[hittype].." (ID "..hitid..") using weapon ("..weapon..")"
	
	local query = mariadb_prepare(sql, "INSERT INTO logs VALUES (NULL, NULL, '?');",
    message)

    mariadb_async_query(sql, query) 
end)

-- TO TP THE PLAYER TO THE GROUND WHEN HE IS IN WATER
AddCommand("unstuck", function(player)
    local x,y,z = GetPlayerLocation(player)

    -- UNDER WATER
    if z <= 0 then -- If the player is under the level of the sea (0)
        CallRemoteEvent(player, "admin:unstuck:terrainheight")        
    end

    -- ON THE ISLAND
    local islandspawn = {227603,-65590}
    if GetDistance2D(x, y, islandspawn[1], islandspawn[2]) <= 5000 then
        UnstuckIslandPlayer(player)
    end  

    -- OUTSIDE OF THE MAP
    if GetDistance2D(x, y, 0, 0) > 320000 then
        UnstuckOutsideMapPlayer(player)
    end
    
end)
--minha
function OnPlayerSpawn(playerid)
    local x,y,z = GetPlayerLocation(playerid)
    Delay(5000, function(playerid)        
            CallRemoteEvent(playerid, "admin:unstuck:terrainheight")        
    end, playerid)
end
AddEvent("OnPlayerSpawn", OnPlayerSpawn)
--minha

function UnstuckOutsideMapPlayer(player)
    print('UNSTUCK OUTSIDEMAP → ', player, GetPlayerSteamId(player))
    -- CleanInventoryAndTpPlayer(player)
    SetPlayerLocation(player, PLAYER_SPAWN_POINT.x, PLAYER_SPAWN_POINT.y, PLAYER_SPAWN_POINT.z) 
end

function UnstuckIslandPlayer(player)
    print('UNSTUCK ISLAND → ', player, GetPlayerSteamId(player))
    --CleanInventoryAndTpPlayer(player)
    SetPlayerLocation(player, PLAYER_SPAWN_POINT.x, PLAYER_SPAWN_POINT.y, PLAYER_SPAWN_POINT.z) 
end

function CleanInventoryAndTpPlayer(player)
    if PlayerData[player] ~= nil and PlayerData[player].inventory ~= nil then
        for k,v in pairs(PlayerData[player].inventory) do
            if k ~= 'cash' and k ~= 'phone' and k ~= 'item_backpack' then
                PlayerData[player].inventory[k] = nil
            end
        end
    end

    SetPlayerLocation(player, PLAYER_SPAWN_POINT.x, PLAYER_SPAWN_POINT.y, PLAYER_SPAWN_POINT.z) 
end

function UnstuckUnderWaterPlayer(player, height)
    print('UNSTUCK UNDERWATER → ', player, GetPlayerSteamId(player))
    local x,y,z = GetPlayerLocation(player)

    if height ~= nil and height ~= false then                
        SetPlayerLocation(player, x, y, height)        
    end
end
AddRemoteEvent("admin:unstuck:teleport", UnstuckUnderWaterPlayer)

function BroadcastMessage(player, message, tempsaffichage)
    if PlayerData[player].admin ~= 1 then return end
    for k,v in pairs(GetAllPlayers()) do
        CallRemoteEvent(v, "admin:broadcast:display", PlayerData[player].name, message, tonumber(tempsaffichage)) 
    end       
end
AddRemoteEvent("admin:broadcast", BroadcastMessage)
