local _ = function(k, ...) return ImportPackage("i18n").t(GetPackageName(), k, ...) end

local MAX_POLICE = 30 -- Number of policemens at the same time
local ALLOW_RESPAWN_VEHICLE = false -- Allow the respawn of the vehicle by destroying the previously spawned one. (Can break RP if the car is stolen or need repairs or fuel)
local NB_HANDCUFFS = 3

--- PLAN B EN CAS DE FPS EN DELIRE AVEC LE MOD DE SALSI
-- local VEHICLE_SPAWN_LOCATION = {
--     {x = 189301, y = 206802, z = 1320, h = 220},
-- }

-- local POLICE_SERVICE_NPC = {
--     {x = 188941, y = 207122, z = 1307, h = 0},
-- }

-- local POLICE_VEHICLE_NPC = {
--     {x = 189696, y = 206544, z = 1307, h = 180},
-- }

-- local POLICE_GARAGE = {
--     {x = 197007, y = 205898, z = 1321},
-- }

-- local POLICE_EQUIPMENT_NPC = {
--     {x = 188502, y = 207175, z = 1308, h = 180},
-- }
--- PLAN B EN CAS DE FPS EN DELIRE AVEC LE MOD DE SALSI

local VEHICLE_SPAWN_LOCATION = {
    {x = 187622, y = 205883, z = 1320, h = 180},

}

local POLICE_SERVICE_NPC = {
    {x = 190938, y = 208358, z = 1323, h = 180},

}

local POLICE_VEHICLE_NPC = {
    {x = 189593, y = 206346, z = 1323, h = 180},

}

local POLICE_GARAGE = {
    {x = 197007, y = 205898, z = 1321},

}

local POLICE_EQUIPMENT_NPC = {
    {x = 190645, y = 207655, z = 1321, h = 90},

}

local policeNpcIds = {}
local policeVehicleNpcIds = {}
local policeGarageIds = {}
local policeEquipmentNpcIds = {}

AddEvent("OnPackageStart", function()
    for k, v in pairs(POLICE_SERVICE_NPC) do
        v.npcObject = CreateNPC(v.x, v.y, v.z, v.h)
        SetNPCAnimation(v.npcObject, "WALLLEAN04", true)        
        table.insert(policeNpcIds, v.npcObject)
    end
    
    for k, v in pairs(POLICE_GARAGE) do
        v.garageObject = CreatePickup(2, v.x, v.y, v.z)
        table.insert(policeGarageIds, v.garageObject)
    end
    
    for k, v in pairs(POLICE_VEHICLE_NPC) do
        v.npcObject = CreateNPC(v.x, v.y, v.z, v.h)
        SetNPCAnimation(v.npcObject, "WALLLEAN04", true)
        table.insert(policeVehicleNpcIds, v.npcObject)
    end

    for k, v in pairs(POLICE_EQUIPMENT_NPC) do
        v.npcObject = CreateNPC(v.x, v.y, v.z, v.h)
        table.insert(policeEquipmentNpcIds, v.npcObject)
    end
end)

AddEvent("OnPlayerJoin", function(player)
    CallRemoteEvent(player, "police:setup", policeNpcIds, policeGarageIds, policeVehicleNpcIds, policeEquipmentNpcIds)
end)

--------- SERVICE AND EQUIPMENT
function PoliceStartStopService(player)
    if PlayerData[player].job == "" then
        PoliceStartService(player)
    elseif PlayerData[player].job == "police" then
        PoliceEndService(player)
    else
        CallRemoteEvent(player, "MakeErrorNotification", _("please_leave_previous_job"))
    end
end
AddRemoteEvent("police:startstopservice", PoliceStartStopService)

function PoliceStartService(player)-- To start the police service
    -- #1 Check for the police whitelist of the player
    if PlayerData[player].police ~= 1 then
        CallRemoteEvent(player, "MakeErrorNotification", _("not_whitelisted"))
        return
    end
    
    -- #2 Check if the player has a job vehicle spawned then destroy it
    if PlayerData[player].job_vehicle ~= nil then
        DestroyVehicle(PlayerData[player].job_vehicle)
        DestroyVehicleData(PlayerData[player].job_vehicle)
        PlayerData[player].job_vehicle = nil
    end
    
    -- #3 Check for the number of policemen in service
    local policemens = 0
    for k, v in pairs(PlayerData) do
        if v.job == "police" then policemens = policemens + 1 end
    end
    if policemens >= MAX_POLICE then
        CallRemoteEvent(player, "MakeErrorNotification", _("job_full"))
        return
    end
    
    -- #4 Set the player job to police, update the cloths, give equipment
    PlayerData[player].job = "police"
    CallRemoteEvent(player, "police:client:isonduty", true)    
    -- CLOTHINGS
    GivePoliceEquipmentToPlayer(player)
    SetPlayerArmor(player, 100)-- Set the armor of player
    UpdateClothes(player)
    
    CallRemoteEvent(player, "MakeNotification", _("join_police"), "linear-gradient(to right, #00b09b, #96c93d)")
    
    return true
end

function PoliceEndService(player)-- To end the police service
    -- #1 Remove police equipment
    RemovePoliceEquipmentFromPlayer(player)
    if PlayerData[player].job_vehicle ~= nil then
        DestroyVehicle(PlayerData[player].job_vehicle)
        DestroyVehicleData(PlayerData[player].job_vehicle)
        PlayerData[player].job_vehicle = nil
    end
    -- #2 Set player job
    PlayerData[player].job = ""
    CallRemoteEvent(player, "police:client:isonduty", false)  
    -- #3 Reset player armor
    SetPlayerArmor(player, 0)-- Reset the armor of player
    -- #4 Trigger update of cloths
    UpdateClothes(player)
    
    CallRemoteEvent(player, "MakeNotification", _("quit_police"), "linear-gradient(to right, #00b09b, #96c93d)")
    
    return true
end

function GivePoliceEquipmentToPlayer(player)-- To give police equipment to policemen
    if PlayerData[player].job == "police" and PlayerData[player].police == 1 then -- Fail check
        if GetNumberOfItem(player, "weapon_4") < 1 then -- If the player doesnt have the gun we give it to him
            SetInventory(player, "weapon_4", 1)
            SetPlayerWeapon(player, 4, 70, false, 2, true)
        end
        if GetNumberOfItem(player, "weapon_21") < 1 then -- If the player doesnt have the gun we give it to him
            SetInventory(player, "weapon_21", 1)
            SetPlayerWeapon(player, 21, 100, false, 3, true)
        end
        if GetNumberOfItem(player, "handcuffs") < NB_HANDCUFFS then -- If the player doesnt have handcuffs we give it to him
            SetInventory(player, "handcuffs", NB_HANDCUFFS)
        end
        SetPlayerArmor(player, 100)
    end
end
AddRemoteEvent("police:checkmyequipment", GivePoliceEquipmentToPlayer)

function RemovePoliceEquipmentFromPlayer(player)-- To remove police equipment from policemen
    if GetNumberOfItem(player, "weapon_4") > 0 then -- If the player have the gun we remove it
        RemoveInventory(player, "weapon_4", 1)
        SetPlayerWeapon(player, 1, 0, true, 2, false)
    end
    if GetNumberOfItem(player, "weapon_21") > 0 then -- If the player have the gun we remove it
        RemoveInventory(player, "weapon_21", 1)
        SetPlayerWeapon(player, 1, 0, true, 3, false)
    end
    if GetNumberOfItem(player, "handcuffs") > 0 then -- If the player doesnt have handcuffs we give it to him
        RemoveInventory(player, "handcuffs", 3)
    end
end

AddEvent("job:onspawn", function(player)
    if PlayerData[player].job == "police" and PlayerData[player].police == 1 then -- Anti glitch
        CallRemoteEvent(player, "police:client:isonduty", true)  
    end
    
    if PlayerData[player].is_cuffed == 1 then
        SetPlayerCuffed(player, true)
    end
end)

AddEvent("police:refreshcuff", function(player)
    if PlayerData[player].is_cuffed == 1 then
        SetPlayerCuffed(player, true)
    end
end)

AddEvent("OnPlayerSpawn", function(player)-- On player death
    if PlayerData and PlayerData[player] then
        if PlayerData[player].health_state == "no_medic" then
            if PlayerData[player].is_cuffed == 1 then
                SetPlayerCuffed(player, false)
            end
        else
            if PlayerData[player].is_cuffed == 1 then
                SetPlayerCuffed(player, true)
            end
        end
        GivePoliceEquipmentToPlayer(player)
    end
end)
--------- SERVICE AND EQUIPMENT END
--------- POLICE VEHICLE
function SpawnPoliceCar(player)
    -- #1 Check for the police whitelist of the player
    if PlayerData[player].police ~= 1 then
        CallRemoteEvent(player, "MakeErrorNotification", _("not_whitelisted"))
        return
    end
    if PlayerData[player].job ~= "police" then
        CallRemoteEvent(player, "MakeErrorNotification", _("not_police"))
        return
    end
    
    -- #2 Check if the player has a job vehicle spawned then destroy it
    if PlayerData[player].job_vehicle ~= nil and ALLOW_RESPAWN_VEHICLE then
        DestroyVehicle(PlayerData[player].job_vehicle)
        DestroyVehicleData(PlayerData[player].job_vehicle)
        PlayerData[player].job_vehicle = nil
    end
    
    -- #3 Try to spawn the vehicle
    if PlayerData[player].job_vehicle == nil then
        local spawnPoint = VEHICLE_SPAWN_LOCATION[PoliceGetClosestSpawnPoint(player)]
        if spawnPoint == nil then return end
        for k, v in pairs(GetStreamedVehiclesForPlayer(player)) do
            local x, y, z = GetVehicleLocation(v)
            if x == false then break end
            local dist2 = GetDistance3D(spawnPoint.x, spawnPoint.y, spawnPoint.z, x, y, z)
            if dist2 < 500.0 then
                CallRemoteEvent(player, "MakeErrorNotification", _("cannot_spawn_vehicle"))
                return
            end
        end
        local vehicle = CreateVehicle(3, spawnPoint.x, spawnPoint.y, spawnPoint.z, spawnPoint.h)
        SetVehicleLicensePlate(vehicle, "POL-"..PlayerData[player].accountid) 
        PlayerData[player].job_vehicle = vehicle
        CreateVehicleData(player, vehicle, 3)
        SetVehicleRespawnParams(vehicle, false)
        SetVehiclePropertyValue(vehicle, "locked", true, true)
        VehicleData[vehicle].inventory = { repair_kit = 2, jerican = 2 }
        CallRemoteEvent(player, "MakeNotification", _("spawn_vehicle_success", " patrol car"), "linear-gradient(to right, #00b09b, #96c93d)")
    else
        CallRemoteEvent(player, "MakeErrorNotification", _("cannot_spawn_vehicle"))
    end
end
AddRemoteEvent("police:spawnvehicle", SpawnPoliceCar)

function DespawnPoliceCar(player)
    -- #2 Check if the player has a job vehicle spawned then destroy it
    if PlayerData[player].job_vehicle ~= nil then
        DestroyVehicle(PlayerData[player].job_vehicle)
        DestroyVehicleData(PlayerData[player].job_vehicle)
        PlayerData[player].job_vehicle = nil
        CallRemoteEvent(player, "MakeNotification", _("vehicle_stored"), "linear-gradient(to right, #00b09b, #96c93d)")
        return
    end
end

AddEvent("OnPlayerPickupHit", function(player, pickup)-- Store the vehicle in garage
    if PlayerData[player].job ~= "police" then return end
    
    for k, v in pairs(POLICE_GARAGE) do
        if v.garageObject == pickup then
            local vehicle = GetPlayerVehicle(player)
            
            if vehicle == nil then return end
            
            local seat = GetPlayerVehicleSeat(player)

            if vehicle == PlayerData[player].job_vehicle and VehicleData[vehicle].owner == PlayerData[player].accountid and seat == 1 then
                DespawnPoliceCar(player)
            end
        end
    end
end)
--------- POLICE VEHICLE END
--------- INTERACTIONS
function CuffPlayer(player)
    if PlayerData[player].police ~= 1 then return end
    if PlayerData[player].job ~= "police" then return end
    
    local target = GetNearestPlayer(player, 200)
    if target ~= nil and PlayerData[target].is_cuffed == 0 then
        if GetNumberOfItem(player, "handcuffs") > 0 then
            RemoveInventory(player, "handcuffs", 1)
            SetPlayerCuffed(target, true)            
            CallRemoteEvent(player, "MakeNotification", _("player_is_handcuffed"), "linear-gradient(to right, #00b09b, #96c93d)")
            CallRemoteEvent(target, "MakeNotification", _("you_are_handcuffed"), "linear-gradient(to right, #00b09b, #96c93d)")
        else
            CallRemoteEvent(player, "MakeErrorNotification", _("no_handcuffs"))
        end
    elseif target ~= nil and PlayerData[target].is_cuffed == 1 then
        SetPlayerCuffed(target, false)
        AddInventory(player, "handcuffs", 1)
        CallRemoteEvent(player, "MakeNotification", _("player_is_uncuffed"), "linear-gradient(to right, #00b09b, #96c93d)")
        CallRemoteEvent(target, "MakeNotification", _("you_are_uncuffed"), "linear-gradient(to right, #00b09b, #96c93d)")
    end
end
AddRemoteEvent("police:cuff", CuffPlayer)

function SetPlayerCuffed(player, state)
    if state == true then
        -- # Empty the weapons shortcuts
        SetPlayerWeapon(player, 1, 0, true, 1)
        SetPlayerWeapon(player, 1, 0, false, 2)
        SetPlayerWeapon(player, 1, 0, false, 3)
        -- # Launch the cuffed animation
        SetPlayerAnimation(player, "CUFF")
        -- # Disable most of interactions
        SetPlayerBusy(player)
        -- # Set player as cuffed
        PlayerData[player].is_cuffed = 1
        -- # Set property value
        SetPlayerPropertyValue(player, "cuffed", true, true)
    else
        SetPlayerAnimation(player, "STOP")
        SetPlayerNotBusy(player)
        PlayerData[player].is_cuffed = 0
        SetPlayerPropertyValue(player, "cuffed", false, true)
    end
end

function FinePlayer(player, amount, reason)
    if (tonumber(amount) <= 0) then
        return false
    end
      
    if PlayerData[player].police ~= 1 then return end
    if PlayerData[player].job ~= "police" then return end
    
    local target = GetNearestPlayer(player, 200)
    if target ~= nil then
        AddFineInDb(player, target, amount, reason)
    else
        CallRemoteEvent(player, "MakeErrorNotification", _("police_no_player_in_range"))
    end
end
AddRemoteEvent("police:fine", FinePlayer)

function AddFineInDb(player, target, amount, reason)
    if PlayerData[player].police ~= 1 then return end
    if PlayerData[player].job ~= "police" then return end
    PlayerData[target].bank_balance = PlayerData[target].bank_balance - amount -- Set the bank account
    local query = mariadb_prepare(sql, "INSERT INTO fines (`fine_date`,`agent_id`, `player_id`, `amount`, `reason`, `paid`) VALUES ('?', ?, ?, ?, '?', 1);",
        tostring(os.date('%Y-%m-%d %H:%M:%S')),
        tonumber(player),
        tonumber(target),
        tonumber(amount),
        tostring(reason))
    -- Insert the fine in DB
    mariadb_async_query(sql, query)
    -- Notify
    CallRemoteEvent(player, "MakeNotification", _("fine_given", amount), "linear-gradient(to right, #00b09b, #96c93d)")
    CallRemoteEvent(target, "MakeNotification", _("fine_received", amount), "linear-gradient(to right, #00b09b, #96c93d)")
end

function PolicePutPlayerInCar(player)
    if PlayerData[player].police ~= 1 then return end
    if PlayerData[player].job ~= "police" then return end
    
    local target = GetNearestPlayer(player, 200)
    if target ~= nil then
        PoliceSetPlayerInCar(player, target)
    end
end
AddRemoteEvent("police:playerincar", PolicePutPlayerInCar)

function PoliceSetPlayerInCar(player, target)
    if PlayerData[player].job_vehicle == nil then return end
    local x, y, z = GetVehicleLocation(PlayerData[player].job_vehicle)
    local x2, y2, z2 = GetPlayerLocation(target)
    
    if GetDistance3D(x, y, z, x2, y2, z2) <= 400 then
        if GetVehiclePassenger(PlayerData[player].job_vehicle, 3) == 0 then -- First back seat
            SetPlayerInVehicle(target, PlayerData[player].job_vehicle, 3)
            CallRemoteEvent(player, "MakeNotification", _("policecar_place_player_in_back"), "linear-gradient(to right, #00b09b, #96c93d)")
        elseif GetVehiclePassenger(PlayerData[player].job_vehicle, 4) == 0 then -- Second back seat
            SetPlayerInVehicle(target, PlayerData[player].job_vehicle, 4)
            CallRemoteEvent(player, "MakeNotification", _("policecar_place_player_in_back"), "linear-gradient(to right, #00b09b, #96c93d)")
        else -- All seats are busy
            CallRemoteEvent(player, "MakeErrorNotification", _("policecar_no_more_seat"))
        end
    else -- Too far away
        CallRemoteEvent(player, "MakeErrorNotification", _("policecar_too_far_away"))
    end
end

function PoliceRemovePlayerInCar(player)
    if PlayerData[player].police ~= 1 then return end
    if PlayerData[player].job ~= "police" then return end
    if PlayerData[player].job_vehicle == nil then return end
    
    local x, y, z = GetVehicleLocation(PlayerData[player].job_vehicle)
    local x2, y2, z2 = GetPlayerLocation(player)
    
    if GetDistance3D(x, y, z, x2, y2, z2) <= 200 then
        if GetVehiclePassenger(PlayerData[player].job_vehicle, 3) ~= 0 then -- First back seat
            RemovePlayerFromVehicle(GetVehiclePassenger(PlayerData[player].job_vehicle, 3))
        end
        if GetVehiclePassenger(PlayerData[player].job_vehicle, 4) ~= 0 then -- Second back seat
            RemovePlayerFromVehicle(GetVehiclePassenger(PlayerData[player].job_vehicle, 4))
        end
        CallRemoteEvent(player, "MakeNotification", _("policecar_player_remove_from_car"), "linear-gradient(to right, #00b09b, #96c93d)")
    end
end
AddRemoteEvent("police:removeplayerincar", PoliceRemovePlayerInCar)

function FriskPlayer(player)
    if PlayerData[player].police ~= 1 then return end
    if PlayerData[player].job ~= "police" then return end
    
    local target = GetNearestPlayer(player, 200)
    if target ~= nil then
        LaunchFriskPlayer(player, target)
    end
end
AddRemoteEvent("police:friskplayer", FriskPlayer)

function PoliceRemoveVehicle(player)
    if PlayerData[player].police ~= 1 then return end
    if PlayerData[player].job ~= "police" then return end
    
    local vehicle = GetNearestVehicle(player)
    MoveVehicleToGarage(vehicle, player)
end
AddRemoteEvent("police:removevehicle", PoliceRemoveVehicle)

function LaunchFriskPlayer(player, target)
    if PlayerData[player].police ~= 1 then return end
    if PlayerData[player].job ~= "police" then return end
    if GetPlayerPropertyValue(target, "cuffed") ~= true then return end
    
    local x, y, z = GetPlayerLocation(player)
    local nearestPlayers = GetPlayersInRange3D(x, y, z, 200)
    local playerList = {}
    for k, v in pairs(nearestPlayers) do
        if k ~= player then
            local playerName
            if PlayerData[k].accountid ~= nil and PlayerData[k].accountid ~= 0 then playerName = PlayerData[k].accountid else playerName = GetPlayerName(k) end            
            table.insert(playerList, {id = k, name = playerName}) -- On prend le nom affiché (l'accountid)
        end
    end
    
    friskedPlayer = { id = tostring(target), name = PlayerData[tonumber(target)].accountid, inventory = PlayerData[tonumber(target)].inventory }
    CallRemoteEvent(player, "OpenPersonalMenu", Items, PlayerData[player].inventory, PlayerData[player].name, player, playerList, GetPlayerMaxSlots(player), friskedPlayer)
end

--------- INTERACTIONS END
--------- MISC
AddEvent("police:triggerbankalert", function(player, type)
    for k, v in pairs(GetAllPlayers()) do
        if PlayerData[v].job == "police" then
            CallRemoteEvent(v, "police:code3alarm")
            CallRemoteEvent(v, "MakeErrorNotification", _("police_alert_bank"), 10000)
            CallRemoteEvent(v, "police:waypoint", 213940, 192764, 1309)
        end
    end
end)

AddEvent("police:endalarm", function(player)
    for k, v in pairs(GetAllPlayers()) do
        if PlayerData[v].job == "police" then
            CallRemoteEvent(player, "police:delwaypoint")
        end
    end
end)

--------- MISC END
-- Tools
function GetNearestPlayer(player, maxDist)
    local maxDist = maxDist or 300
    local x, y, z = GetPlayerLocation(player)
    local closestPlayer
    local dist
    for k, v in pairs(GetStreamedPlayersForPlayer(player)) do
        if v ~= player then
            if IsValidPlayer(v) then
                local x2, y2, z2 = GetPlayerLocation(v)
                local currentDist = GetDistance3D(x, y, z, x2, y2, z2)
                if (dist == nil or currentDist < dist) and currentDist <= tonumber(maxDist) then
                    closestPlayer = v
                    dist = currentDist
                end
            end
        end
    end
    return closestPlayer
end

function GetNearestVehicle(player, maxDist)
    local maxDist = maxDist or 300
    local x, y, z = GetPlayerLocation(player)
    local closestVehicle
    local dist
    for k, v in pairs(GetStreamedVehiclesForPlayer(player)) do
        local x2, y2, z2 = GetVehicleLocation(v)
        local currentDist = GetDistance3D(x, y, z, x2, y2, z2)
        if (dist == nil or currentDist < dist) and currentDist <= tonumber(maxDist) then
            closestVehicle = v
            dist = currentDist
        end
    end
    return closestVehicle
end

function GetNearestPlayers(player, maxDist)
    local maxDist = maxDist or 300
    local x, y, z = GetPlayerLocation(player)
    local closestPlayers = {}
    for k, v in pairs(GetStreamedPlayersForPlayer(player)) do
        if v ~= player then
            if IsValidPlayer(v) then            
                local x2, y2, z2 = GetPlayerLocation(v)
                local currentDist = GetDistance3D(x, y, z, x2, y2, z2)
                if currentDist < maxDist then
                    table.insert(closestPlayers, v)
                end
            end
        end
    end
    return closestPlayers
end

function PoliceGetClosestSpawnPoint(player)
    local x, y, z = GetPlayerLocation(player)
    local closestSpawnPoint
    local dist
    for k, v in pairs(VEHICLE_SPAWN_LOCATION) do
        local currentDist = GetDistance3D(x, y, z, v.x, v.y, v.z)
        if (dist == nil or currentDist < dist) and currentDist <= 2000 then
            closestSpawnPoint = k
            dist = currentDist
        end
    end
    return closestSpawnPoint
end
