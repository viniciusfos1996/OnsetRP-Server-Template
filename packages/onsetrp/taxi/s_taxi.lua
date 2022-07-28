local _ = function(k, ...) return ImportPackage("i18n").t(GetPackageName(), k, ...) end

local MAX_TAXI = 10 -- Number of taximens at the same time
local ALLOW_RESPAWN_VEHICLE = false -- Allow the respawn of the vehicle by destroying the previously spawned one. (Can break RP if the car is stolen or need repairs or fuel)
local CAUTION = 1500 -- Amount of the caution

local occupants = {}

local VEHICLE_SPAWN_LOCATION = {
    {x = 177218, y = 159869, z = 4817, h = -70},
}

local TAXI_SERVICE_NPC = {
    {x = 176896, y = 158016, z = 4823, h = -70},
}

local TAXI_VEHICLE_NPC = {
    {x = 176211, y = 159760, z = 4818, h = 10},
}

local TAXI_GARAGE = {
    {x = 175676, y = 159208, z = 4819},
}

local taxiNpcIds = {}
local taxiVehicleNpcIds = {}
local taxiGarageIds = {}

AddEvent("OnPackageStart", function()
    for k, v in pairs(TAXI_SERVICE_NPC) do
        v.npcObject = CreateNPC(v.x, v.y, v.z, v.h)
        CreateText3D(_("taxi_job") .. "\n" .. _("press_e"), 18, v.x, v.y, v.z + 120, 0, 0, 0)
        SetNPCAnimation(v.npcObject, "CROSSARMS", true)     
        table.insert(taxiNpcIds, v.npcObject)
    end
    
    if ALLOW_RESPAWN_VEHICLE == false then
        for k, v in pairs(TAXI_GARAGE) do
            v.garageObject = CreatePickup(2, v.x, v.y, v.z)
            table.insert(taxiGarageIds, v.garageObject)
        end
    end
    
    for k, v in pairs(TAXI_VEHICLE_NPC) do
        v.npcObject = CreateNPC(v.x, v.y, v.z, v.h)
        CreateText3D(_("taxi_garage_menu") .. "\n" .. _("press_e"), 18, v.x, v.y, v.z + 120, 0, 0, 0)
        SetNPCAnimation(v.npcObject, "WALLLEAN04", true)
        table.insert(taxiVehicleNpcIds, v.npcObject)
    end
end)

AddEvent("OnPlayerJoin", function(player)
    CallRemoteEvent(player, "taxi:setup", taxiNpcIds, taxiGarageIds, taxiVehicleNpcIds, CAUTION)
end)

AddEvent("job:onspawn", function(player)
    --PlayerData[player].job_vehicle = trucksOnLocation[PlayerData[player].accountid] -- Pour récupérer la propriété du véhicule de prêt
    if PlayerData[player].job == "taxi" then -- Anti glitch
        CallRemoteEvent(player, "taxi:client:isonduty", true)
    end
end)


--------- SERVICE
function TaxiStartStopService(player)
    if PlayerData[player].job == "" then
        TaxiStartService(player)
    elseif PlayerData[player].job == "taxi" then
        TaxiEndService(player)
    else
        CallRemoteEvent(player, "MakeErrorNotification", _("please_leave_previous_job"))
    end
end
AddRemoteEvent("taxi:startstopservice", TaxiStartStopService)

function TaxiStartService(player)-- To start the taxi service
    -- #1 Check if the player has a job vehicle spawned then destroy it
    if PlayerData[player].job_vehicle ~= nil then
        DestroyVehicle(PlayerData[player].job_vehicle)
        DestroyVehicleData(PlayerData[player].job_vehicle)
        PlayerData[player].job_vehicle = nil
    end
    
    -- #2 Check for the number of taximen in service
    local taximens = 0
    for k, v in pairs(PlayerData) do
        if v.job == "taxi" then taximens = taximens + 1 end
    end
    if taximens >= MAX_TAXI then
        CallRemoteEvent(player, "MakeErrorNotification", _("job_full"))
        return
    end
    
    -- #3 Check for the taxi licence
    if PlayerData[player].taxi_license == 0 then
        CallRemoteEvent(player, "MakeErrorNotification", _("no_taxi_licence"))
        return
    end

    -- #3 Set the player job to taxi
    PlayerData[player].job = "taxi"
    CallRemoteEvent(player, "taxi:client:isonduty", true)
    CallRemoteEvent(player, "MakeNotification", _("join_taxi"), "linear-gradient(to right, #96c93d, #96c93d)")
    
    return true
end

function TaxiEndService(player)-- To end the taxi service
    --Set player job
    PlayerData[player].job = ""
    CallRemoteEvent(player, "taxi:client:isonduty", false)  
    CallRemoteEvent(player, "MakeNotification", _("quit_taxi"), "linear-gradient(to right, #96c93d, #96c93d)")
    
    return true
end

--------- SERVICE END
--------- TAXI VEHICLE
function CheckCash(player)
        -- #1 Check if the player has the taxi job
        if PlayerData[player].job ~= "taxi" then
            CallRemoteEvent(player, "MakeErrorNotification", _("not_taxi"))
            return
        end
        
        -- #2 Check if the player has money for caution
        if CAUTION > GetPlayerCash(player) then
            CallRemoteEvent(player, "MakeErrorNotification",_("no_money_car"))
        else
            SetPlayerPropertyValue(player, "caution", "cash", true)
            SpawnTaxiCar(player)
        end
end
AddRemoteEvent("taxi:checkcash", CheckCash)       
    
function CheckBank(player)
    -- #1 Check if the player has the taxi job
    if PlayerData[player].job ~= "taxi" then
        CallRemoteEvent(player, "MakeErrorNotification", _("not_taxi"))
        return
    end
    
    -- #2 Check if the player has money for caution
    if CAUTION > PlayerData[player].bank_balance then
        CallRemoteEvent(player, "MakeErrorNotification", _("no_money_car"))
    else
        SetPlayerPropertyValue(player, "caution", "bank", true)
        SpawnTaxiCar(player)
    end  
end
AddRemoteEvent("taxi:checkbank", CheckBank)

function SpawnTaxiCar(player)
        --[[ #1 Check if the player has the taxi job
        if PlayerData[player].job ~= "taxi" then
            CallRemoteEvent(player, "MakeErrorNotification", _("not_taxi"))     -- Already checked before
            return
        end]]

    -- #2 Check if the player has a job vehicle spawned then destroy it
    if PlayerData[player].job_vehicle ~= nil and ALLOW_RESPAWN_VEHICLE then
        DestroyVehicle(PlayerData[player].job_vehicle)
        DestroyVehicleData(PlayerData[player].job_vehicle)
        PlayerData[player].job_vehicle = nil
    end
    
    -- #3 Try to spawn the vehicle
    if PlayerData[player].job_vehicle == nil then
        local spawnPoint = VEHICLE_SPAWN_LOCATION[TaxiGetClosestSpawnPoint(player)]
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
        local vehicle = CreateVehicle(2, spawnPoint.x, spawnPoint.y, spawnPoint.z, spawnPoint.h)
        PlayerData[player].job_vehicle = vehicle
        CreateVehicleData(player, vehicle, 2)
        SetVehicleRespawnParams(vehicle, false)
        SetVehiclePropertyValue(vehicle, "locked", true, true)
        if GetPlayerPropertyValue(player, "caution") == "cash" then
            RemovePlayerCash(player, CAUTION)
        elseif GetPlayerPropertyValue(player, "caution") == "bank" then
            PlayerData[player].bank_balance = PlayerData[player].bank_balance - CAUTION
        end
        CallRemoteEvent(player, "MakeNotification", _("spawn_vehicle_success", " taxi car"), "linear-gradient(to right, #00b09b, #96c93d)")
    else
        CallRemoteEvent(player, "MakeErrorNotification", _("cannot_spawn_vehicle"))
    end
end
AddEvent("taxi:spawnvehicle", SpawnTaxiCar)

function DespawnTaxiCar(player)
    -- Check if the player has a job vehicle spawned then destroy it
    if PlayerData[player].job_vehicle ~= nil then
        DestroyVehicle(PlayerData[player].job_vehicle)
        DestroyVehicleData(PlayerData[player].job_vehicle)
        PlayerData[player].job_vehicle = nil
        if GetPlayerPropertyValue(player, "caution") == "cash" then
            AddPlayerCash(player, CAUTION)
        else
            PlayerData[player].bank_balance = PlayerData[player].bank_balance + CAUTION
        end
        SetPlayerPropertyValue(player, "caution", nil, true)
        CallRemoteEvent(player, "MakeNotification", _("vehicle_stored"), "linear-gradient(to right, #96c93d, #96c93d)")
        return
    end
end

AddEvent("OnPlayerPickupHit", function(player, pickup)-- Store the vehicle in garage
    if PlayerData[player].job ~= "taxi" then return end
    for k, v in pairs(TAXI_GARAGE) do
        if v.garageObject == pickup then
            local vehicle = GetPlayerVehicle(player)
            if vehicle == nil then return end
            local seat = GetPlayerVehicleSeat(player)
            if vehicle == PlayerData[player].job_vehicle and
                VehicleData[vehicle].owner == PlayerData[player].accountid and
                seat == 1
            then
                DespawnTaxiCar(player)
            end
        end
    end
end)
--------- TAXI VEHICLE END
--------- INTERACTIONS

function StartCourse(player)
    taximan = player
    local taxiID = GetPlayerVehicle(taximan)
    if taxiID ~= 0 then     -- Check if taximan in vehicle
        local vehID = GetVehicleModel(taxiID)
        if vehID == 2 then      -- Check if taximan in taxi
            local playerDriver = GetVehicleDriver(taxiID)
            if taximan == playerDriver then  -- Check if taximan is driver
                if GetPlayerPropertyValue(taximan, "TaxiOcupped") == nil or not GetPlayerPropertyValue(taximan, "TaxiOcupped") then -- Check if course not in progress
                    local occupants = GetClientInTaxi(taximan, taxiID)     
                    if occupants ~= nil then          -- Check if there is client in taxi
                        SetPlayerPropertyValue(taximan, "TaxiOcupped", true, true)
                        SetPlayerPropertyValue(taximan, "Occup", occupants, true)
                        state = true
                        for k, v in ipairs(occupants) do
                            CallRemoteEvent(v, "course", state)
                        end
                        CallRemoteEvent(taximan, "course", state)
                    else
                        CallRemoteEvent(taximan, "MakeErrorNotification", _("no_player_in_vehicle"))
                    end
                end
            else
                CallRemoteEvent(taximan, "MakeErrorNotification", _("not_driver"))
            end
        end
    else
        CallRemoteEvent(taximan, "MakeErrorNotification", _("not_in_vehicle"))
    end
end
AddRemoteEvent("course:start", StartCourse)

--[[function PauseCourse(player)
    local state = 2
    for k, v in ipairs(Occupants) do
        if v ~= 0 then
            CallRemoteEvent(v, "course", state)
        end
    end
    CallRemoteEvent(player, "course", state)
end
AddRemoteEvent("course:pause_unpause", PauseCourse)]]

function CancelCourse(player)
    if GetPlayerPropertyValue(player, "TaxiOccuped") then
        occup = GetPlayerPropertyValue(player, "Occup")
        for k, v in pairs(occup) do
            CallRemoteEvent(v, "cancelcourse")
        end
        CallRemoteEvent(player, "cancelcourse")
    end
end
AddRemoteEvent("course:cancel", CancelCourse)

function StopCourse(player)
    if GetPlayerPropertyValue(player, "TaxiOcupped") ~= nil and GetPlayerPropertyValue(player, "TaxiOcupped") then
        state = false
        CallRemoteEvent(player, "course", state)
        CallRemoteEvent(player, "MakeNotification", _("process_pay"), "linear-gradient(to right, #96c93d, #96c93d)")
        occup = GetPlayerPropertyValue(player, "Occup")
        for k, v in ipairs(occup) do
            CallRemoteEvent(v, "course", state)
            CallRemoteEvent(v, "MakeNotification", _("process_pay"), "linear-gradient(to right, #96c93d, #96c93d)")
        end
    else
        CallRemoteEvent(player, "MakeErrorNotification", _("no_current_course"))
    end
end
AddRemoteEvent("course:stop", StopCourse)

AddRemoteEvent("notifCash", function(player)
    if GetPlayerPropertyValue(player, "TaxiOcupped") ~= nil and GetPlayerPropertyValue(player, "TaxiOcupped") then
        SetPlayerPropertyValue(player, "TaxiOcupped", false, true)
        CallRemoteEvent(player, "MakeNotification", _("cash_taxi"), "linear-gradient(to right, #96c93d, #96c93d)")          -- Les joueurs doivent procéder au paiement depuis leur inventaires
        CallRemoteEvent(player, "HideTaxiHud")
        occup = GetPlayerPropertyValue(player, "Occup")
        SetPlayerPropertyValue(player, "Occup", nil, true)
        for k, v in ipairs(occup) do
            CallRemoteEvent(v, "MakeNotification", _("cash_taxi"), "linear-gradient(to right, #96c93d, #96c93d)")
            CallRemoteEvent(v, "HideTaxiHud")
        end
    end
end)

AddRemoteEvent("bankPay", function(player, CourseTime)
    if GetPlayerPropertyValue(player, "TaxiOcupped") ~= nil and GetPlayerPropertyValue(player, "TaxiOcupped") then
        SetPlayerPropertyValue(player, "TaxiOcupped", false, true)
        occup = GetPlayerPropertyValue(player, "Occup")
        SetPlayerPropertyValue(player, "Occup", nil, true)
        for k, v in ipairs(occup) do
            PlayerData[v].bank_balance = PlayerData[v].bank_balance - CourseTime                -- On débite les clients
            PlayerData[player].bank_balance = PlayerData[player].bank_balance + CourseTime      -- On alimente le compte du chauffeur
            CallRemoteEvent(v, "MakeNotification", _("pay_success"), "linear-gradient(to right, #96c93d, #96c93d)")
            CallRemoteEvent(v, "HideTaxiHud")
        end
        CallRemoteEvent(player, "HideTaxiHud")
        CallRemoteEvent(player, "MakeNotification", _("pay_success"), "linear-gradient(to right, #96c93d, #96c93d)")
    end
end)

--------- INTERACTIONS END
-- Tools
function TaxiGetClosestSpawnPoint(player)
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

function GetClientInTaxi(player, taxiID)
    occupants = {}
    for i = 2, 4 do
        local passenger = GetVehiclePassenger(taxiID, i)
        if (passenger ~= 0) then
            table.insert( occupants, passenger )
            --occupants [#occupants + 1] = passenger
		end
    end
    if #occupants == 0 then
        return nil
    else
        return occupants
    end
end
