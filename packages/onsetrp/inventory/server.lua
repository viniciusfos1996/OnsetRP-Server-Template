local _ = function(k, ...) return ImportPackage("i18n").t(GetPackageName(), k, ...) end

local inventory_base_max_slots = 50
local backpack_slot_to_add = 35

local REPAIR_KIT_HEALTH = 2500
local REPAIR_KIT_TIME = 20

local JERICAN_FUEL_AMOUNT = 50
local JERICAN_TIME = 15

local droppedObjectsPickups = {}

AddRemoteEvent("ServerPersonalMenu", function(player, inVehicle, vehiclSpeed)
    if inVehicle and GetPlayerState(player) == PS_DRIVER and vehiclSpeed > 0 then
        return CallRemoteEvent(player, "MakeErrorNotification", _("cant_while_driving"))
    end
    
    local nearInventories = {}
    local nearInventoryItems = {}

    -- Player inventories
    for k, neatPlayerId in pairs(GetNearestPlayers(player, 300)) do
        if neatPlayerId ~= player then
            local playerName
            if PlayerData[neatPlayerId] ~= nil then
                if PlayerData[neatPlayerId].accountid ~= nil and PlayerData[neatPlayerId].accountid ~= 0 then
                    playerName = PlayerData[neatPlayerId].accountid 
                else 
                    playerName = GetPlayerName(neatPlayerId) 
                end            
                
                if PlayerData[neatPlayerId].is_cuffed == 1 then
                    table.insert(nearInventories, { id = neatPlayerId, name = playerName, access = true, maxSlots = GetPlayerMaxSlots(neatPlayerId) })
                    nearInventoryItems[neatPlayerId] = PlayerData[tonumber(neatPlayerId)].inventory
                else
                    table.insert(nearInventories, { id = neatPlayerId, name = playerName })
                end
            end
        end
    end
    
    -- Vehicle inventories
    for k, nearVehicleId in pairs(GetNearestCars(player, 600)) do
        if VehicleData[nearVehicleId] ~= nil and not GetVehiclePropertyValue(nearVehicleId, "locked") then
            local vehicleId = "vehicle_"..nearVehicleId
            local vehicleName = _("vehicle_"..VehicleData[nearVehicleId].modelid)

            table.insert(nearInventories, { id = vehicleId, name = vehicleName, access = true, maxSlots = VehicleTrunkSlots["vehicle_"..VehicleData[nearVehicleId].modelid] })
            nearInventoryItems[vehicleId] = VehicleData[tonumber(nearVehicleId)].inventory
        end
    end

    CallRemoteEvent(player, "OpenPersonalMenu", Items, PlayerData[player].inventory, PlayerData[player].accountid, player, nearInventories, GetPlayerMaxSlots(player), nil, nearInventoryItems)
end)

function getWeaponID(modelid)
    if modelid:find("weapon_") then
        return modelid:gsub("weapon_", "")
    end
    return 0
end

AddRemoteEvent("EquipInventory", function(player, originInventory, itemName, amount, inVehicle, vehiclSpeed)
    if (amount <= 0) then
        return false
    end
      
    if string.find(originInventory, 'vehicle_') then
        CallRemoteEvent(player, "MakeErrorNotification", _("pick_first"))
        return false
    end

    originInventory = tonumber(originInventory)

    if inVehicle and GetPlayerState(player) == PS_DRIVER and vehiclSpeed > 0 then
        CallRemoteEvent(player, "MakeErrorNotification", _("cant_while_driving"))
        return false
    end
    
    local item
    
    for k, itemPair in pairs(Items) do
        if itemPair.name == itemName then
            item = itemPair
        end
    end
    
    weapon = getWeaponID(itemName)
    if tonumber(PlayerData[originInventory].inventory[itemName]) < tonumber(amount) then
        CallRemoteEvent(player, "MakeErrorNotification", _("not_enough_item"))
    else
        if weapon ~= 0 then
            for slot, v in pairs({1, 2, 3}) do
                local slotWeapon, ammo = GetPlayerWeapon(player, slot)
                if slotWeapon == tonumber(weapon) then
                    UnequipWeapon(player, originInventory, itemName, slot)
                    return true
                end
            end
            
            for slot, v in pairs({1, 2, 3}) do
                local slotWeapon, ammo = GetPlayerWeapon(player, slot)
                if slotWeapon == 1 then
                    SetPlayerWeapon(player, tonumber(weapon), 1000, true, slot)
                    CallRemoteEvent(player, "MakeSuccessNotification", _("item_equiped", slot))
                    UpdateUIInventory(player, originInventory, itemName, PlayerData[originInventory].inventory[itemName], true)
                    return true
                end
            end
            CallRemoteEvent(player, "MakeErrorNotification", _("not_enough_slots"))
        else
            if string.find(itemName, 'mask_') then
                local objectId
 
                local objX = 8.0
                local objY = 0.0
                local objZ = 0.0
                
                if itemName == 'mask_1' then
                    objectId = 463
                elseif itemName == 'mask_2' then
                    objectId = 455
                elseif itemName == 'mask_3' then
                    objX = -3.0
                    objY = 12.0
                    objZ = 0.0
                    objectId = 1451
                elseif itemName == 'mask_4' then
                    objX = -5.0
                    objY = -5.0
                    objZ = 6.0
                    objectId = 1452
                end

                BackpackPutOnAnim(player, 3000, 'FACEPALM')
                
                if PlayerData[player][itemName] then
                    UpdateUIInventory(player, originInventory, itemName, PlayerData[originInventory].inventory[itemName], false)
                    SetPlayerPropertyValue(player, "WearingItem", nil, true)
                    Delay(2000, function()
                        DestroyObject(PlayerData[player][itemName])
                        PlayerData[player][itemName] = nil
                    end)
                else
                    UpdateUIInventory(player, originInventory, itemName, PlayerData[originInventory].inventory[itemName], true)
                    SetPlayerPropertyValue(player, "WearingItem", itemName, true)
                    Delay(2000, function() 
                        local x, y, z = GetPlayerLocation(player)
                        PlayerData[player][itemName] = CreateObject(objectId, x, y, z)
                        SetObjectAttached(PlayerData[player][itemName], ATTACH_PLAYER, player, objX, objY, objZ, 0.0, 90.0, -90.0, "head")
                    end)
                end
            end
            -- No weapons items
        end
    end
end)

function UnequipWeapon(player, originInventory, itemName, slot)
    SetPlayerWeapon(player, 1, 0, true, slot)
    CallRemoteEvent(player, "MakeSuccessNotification", _("item_unequiped", slot))
    UpdateUIInventory(player, originInventory, itemName, PlayerData[originInventory].inventory[itemName], false)
end

AddRemoteEvent("UseInventory", function(player, originInventory, itemName, amount, inVehicle, vehiclSpeed)
    if (amount <= 0) then
        return false
    end

    if string.find(originInventory, 'vehicle_') then
        CallRemoteEvent(player, "MakeErrorNotification", _("pick_first"))
        return false
    end

    originInventory = tonumber(originInventory)

    if inVehicle and GetPlayerState(player) == PS_DRIVER and vehiclSpeed > 0 then
        return CallRemoteEvent(player, "MakeErrorNotification", _("cant_while_driving"))
    end
    
    local item
    
    for k, itemPair in pairs(Items) do
        if itemPair.name == itemName then
            item = itemPair
        end
    end
    
    weapon = getWeaponID(itemName)
    if tonumber(PlayerData[originInventory].inventory[itemName]) < tonumber(amount) then
        CallRemoteEvent(player, "MakeErrorNotification", _("not_enough_item"))
    else
        if weapon ~= 0 then
            local weaponAdded = false
            for slot, v in pairs({1, 2, 3}) do
                if GetPlayerWeapon(player, slot) == nil then
                    SetPlayerWeapon(player, tonumber(weapon), 1000, true, slot)
                    CallRemoteEvent(player, "MakeSuccessNotification", _("item_equiped", slot))
                    weaponAdded = true
                end
            end
            if not weaponAdded then
                CallRemoteEvent(player, "MakeErrorNotification", _("not_enough_slots"))
            end
        else
            if itemName == "donut" or itemName == "apple" or itemName == "peach" or itemName == "water_bottle" or itemName == "fish" then
                UseItem(player, originInventory, item, amount)
            end
            --minha
            if itemName == "weed" or itemName == "coca_leaf" or itemName == "cocaine" then
                    UseItem(player, originInventory, item, amount, animation)
                    local animation = animation or "SMOKING"
                    RemoveInventory(originInventory, item.name, amount)
                    addPlayerHunger(player, item.hunger * amount)
                    addPlayerThirst(player, item.thirst * amount)
                    SetPlayerAnimation(player, animation)
                end
            --minha
            if itemName == "repair_kit" then
                if GetPlayerVehicle(player) ~= 0 then
                    CallRemoteEvent(player, "MakeErrorNotification", _("cant_while_driving"))
                    return
                end                
                local nearestCar = GetNearestCar(player)
                if not IsValidVehicle(nearestCar) then return end                
                if nearestCar ~= 0 then
                    if GetVehicleHealth(nearestCar) >= 5000 then
                        CallRemoteEvent(player, "MakeErrorNotification", _("dont_need_repair"))
                    else
                        RemoveInventory(originInventory, itemName, amount)
                        CallRemoteEvent(player, "LockControlMove", true)
                        SetPlayerAnimation(player, "COMBINE")
                        SetPlayerBusy(player)
                        CallRemoteEvent(player, "loadingbar:show", _("repairing"), REPAIR_KIT_TIME)-- LOADING BAR
                        Delay(REPAIR_KIT_TIME * 1000, function()
                            SetVehicleHealth(nearestCar, GetVehicleHealth(nearestCar) + REPAIR_KIT_HEALTH)   
                            local percentOfDamage = (1 - (GetVehicleHealth(nearestCar) / 5000)) or 0.5
                            if percentOfDamage < 0 then percentOfDamage = 0 end
                            if percentOfDamage > 1 then percentOfDamage = 1 end
                            for j = 1, 8 do
                                SetVehicleDamage(nearestCar, j, percentOfDamage)                 
                            end 
                            if GetVehicleHealth(nearestCar) > 5000 then SetVehicleHealth(nearestCar, 5000) end   
                            CallRemoteEvent(player, "LockControlMove", false)
                            SetPlayerAnimation(player, "STOP")
                            SetPlayerNotBusy(player)
                            CallRemoteEvent(player, "MakeNotification", _("repair_kit_vehicle_repaired"), "linear-gradient(to right, #00b09b, #96c93d)")
                        end)
                    end
                end
            end
            if itemName == "jerican" then
                if GetPlayerVehicle(player) ~= 0 then
                    CallRemoteEvent(player, "MakeErrorNotification", _("cant_while_driving"))
                    return
                end 
                local nearestCar = GetNearestCar(player)
                if not IsValidVehicle(nearestCar) then return end                
                if nearestCar ~= 0 then
                    if VehicleData[nearestCar].fuel >= 100 then
                        CallRemoteEvent(player, "MakeErrorNotification", _("car_full"))
                    else
                        RemoveInventory(originInventory, itemName, amount)
                        CallRemoteEvent(player, "LockControlMove", true)
                        SetPlayerAnimation(player, "COMBINE")
                        SetPlayerBusy(player)
                        CallRemoteEvent(player, "loadingbar:show", _("refuel"), JERICAN_TIME)-- LOADING BAR
                        Delay(JERICAN_TIME * 1000, function()                            
                            VehicleData[nearestCar].fuel = VehicleData[nearestCar].fuel + JERICAN_FUEL_AMOUNT   
                            if VehicleData[nearestCar].fuel > 100 then VehicleData[nearestCar].fuel = 100 end
                            SetVehiclePropertyValue(nearestCar, "fuel", VehicleData[nearestCar].fuel, true)
                            CallRemoteEvent(player, "LockControlMove", false)
                            SetPlayerAnimation(player, "STOP")
                            SetPlayerNotBusy(player)
                            CallRemoteEvent(player, "MakeNotification", _("car_refuelled_for", JERICAN_FUEL_AMOUNT, 'L'), "linear-gradient(to right, #00b09b, #96c93d)")
                        end)
                    end
                end
            end
            -- if itemName == "lockpick" then -- TEMP
            --     local nearestCar = GetNearestCar(player)
            --     local nearestHouseDoor = GetNearestHouseDoor(player)
            --     if nearestCar ~= 0 then
            --         if VehicleData[nearestCar] ~= nil then
            --             if GetVehiclePropertyValue(nearestCar, "locked") then
            --                 CallRemoteEvent(player, "LockControlMove", true)
            --                 SetPlayerAnimation(player, "LOCKDOOR")
            --                 Delay(3000, function()
            --                     SetPlayerAnimation(player, "LOCKDOOR")
            --                 end)
            --                 Delay(6000, function()
            --                     SetPlayerAnimation(player, "LOCKDOOR")
            --                 end)
            --                 Delay(10000, function()
            --                     SetVehiclePropertyValue(nearestCar, "locked", false, true)
            --                     CallRemoteEvent(player, "MakeSuccessNotification", _("car_unlocked"))
            --                     RemoveInventory(originInventory, itemName, amount)
            --                     CallRemoteEvent(player, "LockControlMove", false)
            --                     SetPlayerAnimation(player, "STOP")
            --                 end)
            --             else
            --                 CallRemoteEvent(player, "MakeErrorNotification", _("vehicle_already_unlocked"))
            --             end
            --         end
            --     end
            --     if nearestHouseDoor ~= 0 then
            --         nearestHouse = getHouseDoor(nearestHouseDoor)
            --         if nearestHouse ~= 0 then
            --             if houses[nearestHouse].lock then
            --                 CallRemoteEvent(player, "LockControlMove", true)
            --                 SetPlayerAnimation(player, "LOCKDOOR")
            --                 Delay(3000, function()
            --                     SetPlayerAnimation(player, "LOCKDOOR")
            --                 end)
            --                 Delay(6000, function()
            --                     SetPlayerAnimation(player, "LOCKDOOR")
            --                 end)
            --                 Delay(10000, function()
            --                     houses[nearestHouse].lock = false
            --                     CallRemoteEvent(player, "MakeSuccessNotification", _("unlock_house"))
            --                     RemoveInventory(originInventory, itemName, amount)
            --                     CallRemoteEvent(player, "LockControlMove", false)
            --                     SetPlayerAnimation(player, "STOP")
            --                 end)
            --             else
            --                 CallRemoteEvent(player, "MakeErrorNotification", _("house_already_unlock"))
            --             end
            --         end
            --     end
            -- end
            CallEvent("job:usespecialitem", player, itemName)-- REDIRECT TO JOBS SCRIPT TO USE ITEM
        end
    end
end)
function UseItem(player, originInventory, item, amount, animation)
    local animation = animation or "DRINKING"
    RemoveInventory(originInventory, item.name, amount)
    addPlayerHunger(player, item.hunger * amount)
    addPlayerThirst(player, item.thirst * amount)
    SetPlayerAnimation(player, animation)
end

--meu



AddRemoteEvent("TransferInventory", function(player, originInventory, item, amount, destinationInventory)
    amount = tonumber(amount)

    if (amount <= 0) then
        return false
    end

    if originInventory == nil or destinationInventory == nil then
        return false
    end

    local originType, originX, originY, originZ, destX, destY, destZ

    -- ORIGIN INVENTORY

    if string.find(originInventory, 'vehicle_') then
        originType = 'vehicle'
        originInventory = string.gsub(originInventory, 'vehicle_', '')
        originX, originY, originZ = GetVehicleLocation(originInventory)
    else
        originType = 'player'
        originX, originY, originZ = GetPlayerLocation(originInventory)
    end

    originInventory = tonumber(originInventory)

    -- DESTINATION INVENTORY
    
    local destinationType

    if string.find(destinationInventory, 'vehicle_') then
        destinationType = 'vehicle'
        destinationInventory = string.gsub(destinationInventory, 'vehicle_', '')
        destX, destY, destZ = GetVehicleLocation(destinationInventory)
    else
        destinationType = 'player'
        destX, destY, destZ = GetPlayerLocation(destinationInventory)
    end

    destinationInventory = tonumber(destinationInventory)

    if originType == 'player' and destinationType == 'player' and player ~= originInventory and PlayerData[originInventory].is_cuffed == 0 then
        return false
    end

    local dist = GetDistance3D(originX, originY, originZ, destX, destY, destZ)
    
    if dist <= 500 then
        local enoughItems = false

        if originType == 'player' then
            enoughItems = PlayerData[originInventory].inventory[item] == nil or PlayerData[originInventory].inventory[item] >= amount
        else
            enoughItems = VehicleData[originInventory].inventory[item] == nil or VehicleData[originInventory].inventory[item] >= amount
        end

        if not enoughItems then
            CallRemoteEvent(player, "MakeErrorNotification", _("not_enough_item"))
        else
            local itemAdded = false
            local itemRemoved = false

            if destinationType == 'player' then
                itemAdded = AddInventory(destinationInventory, item, amount, player)
            else
                itemAdded = AddVehicleInventory(destinationInventory, item, amount, player)
            end
            
            if originType == 'player' then
                itemRemoved = RemoveInventory(originInventory, item, amount, false, player)
            else
                itemRemoved = RemoveVehicleInventory(originInventory, item, amount, player)
            end
            
            if itemAdded and itemRemoved then
                if originType == 'player' then
                    if destinationType == 'player' then
                        if PlayerData[originInventory].is_cuffed == 0 then
                            SetPlayerAnimation(originInventory, "PICKUP_MIDDLE")
                        end
                        CallRemoteEvent(originInventory, "MakeSuccessNotification", _("successful_transfer", amount, item, PlayerData[destinationInventory].name))
                    else
                        CallRemoteEvent(originInventory, "MakeSuccessNotification", _("successful_drop", amount, item))
                    end
                end
                if destinationType == 'player' then
                    if originType == 'player' then
                        if PlayerData[destinationInventory].is_cuffed == 0 then
                            SetPlayerAnimation(destinationInventory, "PICKUP_MIDDLE")
                        end
                        CallRemoteEvent(destinationInventory, "MakeSuccessNotification", _("received_transfer", amount, item, PlayerData[originInventory].name))
                    else
                        CallRemoteEvent(destinationInventory, "MakeSuccessNotification", _("successful_pick", amount, item))
                    end
                end
            else
                -- If added and not removed, remove added item

                if itemAdded then
                    if destinationType == 'player' then
                        RemoveInventory(destinationInventory, item, amount, false, player)
                    else
                        RemoveVehicleInventory(destinationInventory, item, amount, player)
                    end
                end

                -- If removed and not added, re-add removed item

                if itemRemoved then
                    if originType == 'player' then
                        itemAdded = AddInventory(originInventory, item, amount, player)
                    else
                        itemAdded = AddVehicleInventory(originInventory, item, amount, player)
                    end
                end

                CallRemoteEvent(player, "MakeErrorNotification", _("item_transfer_error"))
            end
        end
    end
end)

AddEvent("OnPlayerSpawn", function(player)
    if PlayerData[player] ~= nil then
        if PlayerData[player].backpack == nil then return end
        DestroyObject(PlayerData[player].backpack)
        PlayerData[player].backpack = nil
        DisplayPlayerBackpack(player)
    end
end)

AddRemoteEvent("RemoveFromInventory", function(player, originInventory, item, amount)
    if (amount <= 0) then
        return false
    end

    originInventory = tonumber(originInventory)

    if GetPlayerVehicle(player) ~= 0 then return end    
    if PlayerData[originInventory] == nil or PlayerData[originInventory].inventory[item] == nil or PlayerData[originInventory].inventory[item] < tonumber(amount) then
        CallRemoteEvent(player, "MakeErrorNotification", _("not_enough_item"))
    else
        RemoveInventory(tonumber(originInventory), item, tonumber(amount), 1)
    end
end)

function AddInventory(inventoryId, item, amount, player)
    if (amount <= 0) then
        return false
    end

    local player = player or inventoryId
    
    local slotsAvailables = tonumber(GetPlayerMaxSlots(inventoryId)) - tonumber(GetPlayerUsedSlots(inventoryId))
    if item == "cash" or slotsAvailables >= (amount * ItemsWeight[item]) then
        if item == "item_backpack" and GetPlayerBag(inventoryId) == 1 then -- On ne peux pas acheter plusieurs sacs
            return false
        end
        if PlayerData[inventoryId].inventory[item] == nil then
            PlayerData[inventoryId].inventory[item] = amount
        else
            PlayerData[inventoryId].inventory[item] = PlayerData[inventoryId].inventory[item] + amount
        end
        if item == "item_backpack" then -- Affichage du sac sur le perso
            DisplayPlayerBackpack(player, 1)
        end
        UpdateUIInventory(player, inventoryId, item, PlayerData[inventoryId].inventory[item])
        UpdateUIInventory(inventoryId, inventoryId, item, PlayerData[inventoryId].inventory[item])
        SavePlayerAccount(player)
        return true
    else
        return false
    end
end

function RemoveInventory(inventoryId, item, amount, drop, player)
    if (amount <= 0) then
        return false
    end

    local player = player or inventoryId
    
    if PlayerData[inventoryId].inventory[item] == nil then
        return false
    else
        if PlayerData[inventoryId].inventory[item] - amount < 1 then
            UpdateUIInventory(player, inventoryId, item, 0)
            UpdateUIInventory(inventoryId, inventoryId, item, 0)

            weapon = getWeaponID(item)
            
            if weapon ~= 0 then
                if drop ~= 1 then
                    for slot, v in pairs({1, 2, 3}) do
                        local slotWeapon, ammo = GetPlayerWeapon(player, slot)
                        if slotWeapon == tonumber(weapon) then
                            UnequipWeapon(player, inventoryId, item, slot)
                        end
                    end
                end
            end
            
            PlayerData[inventoryId].inventory[item] = nil
        else
            PlayerData[inventoryId].inventory[item] = PlayerData[inventoryId].inventory[item] - amount
            UpdateUIInventory(player, inventoryId, item, PlayerData[inventoryId].inventory[item])
            UpdateUIInventory(inventoryId, inventoryId, item, PlayerData[inventoryId].inventory[item])
        end
        if item == "item_backpack" then
            DisplayPlayerBackpack(player, 1)
        end
        if drop == 1 then
            local bool = nil
            CallRemoteEvent(player, "CheckCrouch", bool, item, amount)
        end
        SavePlayerAccount(player)
        return true
    end
end

AddRemoteEvent("ObjectDrop", function(player, bool, item, amount)
    local x, y, z = GetPlayerLocation(player)
    if bool then
        z = z + 40
    end
    weapon = getWeaponID(item)
    weapon = tonumber(weapon)
    local slot = GetPlayerEquippedWeaponSlot(player)
    if weapon ~= 0 then
        if GetPlayerWeapon(player, slot) ~= weapon then
            for i = 1,3 do
                if GetPlayerWeapon(player, i) == weapon then
                    EquipPlayerWeaponSlot(player, i)
                    Delay(940, function()
                        SetPlayerWeapon(player, 1, 0, true, i)
                        SetPlayerAnimation(player, "CARRY_SHOULDER_SETDOWN")
                    end)
                    break
                end
            end
        else
            SetPlayerWeapon(player, 1, 0, true, slot)
            SetPlayerAnimation(player, "CARRY_SHOULDER_SETDOWN")
        end
        if weapon == 21 then
            weapon = weapon + 1385
        end
        objetdrop = CreateObject(weapon + 2, x, y, z - 95, 90)
        SetObjectPropertyValue(objetdrop, "isitem", true, true)
        SetObjectPropertyValue(objetdrop, "collision", false, true)
        SetObjectPropertyValue(objetdrop, "item", item, true)
        SetObjectPropertyValue(objetdrop, "amount", amount, true)
    else
        ObjectID = 620
        rx = 0
        ry = 0
        rz = 0
        sx = 1.0
        sy = 1.0
        sz = 1.0
        if item == "cash" then
            if amount < 1000 then
                ObjectID = 1497
            elseif amount < 4000 then
                ObjectID = 1499
            else
                ObjectID = 1501
            end
        elseif item == "water_bottle" then
            ObjectID = 1631
        elseif item == "apple" then
            ObjectID = 1616
        elseif item == "donut" then
            ObjectID = 1648
        elseif item == "phone" then
            ObjectID = 181
            rz = -90
        elseif item == "pickaxe" then
            ObjectID = 1063
            rz = 90
        elseif item == "lumberjack_saw" then
            ObjectID = 1075
        elseif item == "lumberjack_axe" then
            ObjectID = 1047
        elseif item == "fishing_rod" then
            ObjectID = 1111
            rx = 90
        elseif item == "health_kit" then
            ObjectID = 794
        elseif item == "repair_kit" then
            ObjectID = 551
        elseif item == "handcuffs" then
            ObjectID = 1439
        elseif item == "jerican" then
            ObjectID = 1011
        elseif item == "lockpick" then
            ObjectID = 1010
        elseif item == "tree_log" or item == "wood_plank" or item == "treated_wood_plank" then
            ObjectID = 1575
            sx, sy, sz = 0.2, 0.2, 0.2
        elseif item == "defibrillator" then
            ObjectID = 1715
        elseif item == "adrenaline_syringe" then
            ObjectID = 805
            sx, sy, sz = 2.0 ,2.0 , 2.0
        elseif item == "bandage" then
            ObjectID = 803
            sx, sy, sz = 2.0 ,2.0 , 2.0
        elseif item == "cocaine" then
            ObjectID = 799
            sx, sy, sz = 1.5, 1.5, 1.5
            rx = 180
            z = z + 10
        elseif string.find(item, 'mask_') then
            if item == 'mask_1' then
                ObjectID = 463
                rx = 90
                z = z + 3
            elseif item == 'mask_2' then
                ObjectID = 455
                rx = 90
                z = z + 12
            elseif item == 'mask_3' then
                ObjectID = 1451
                rx = 80
                z = z + 12
            elseif item == 'mask_4' then
                ObjectID = 1452
                rx = 90
                z = z - 10
            end
            if PlayerData[player][item] then
                SetPlayerPropertyValue(player, "WearingItem", nil, true)
                DestroyObject(PlayerData[player][item])
                PlayerData[player][item] = nil
            end
        end
        SetPlayerAnimation(player, "CHECK_EQUIPMENT")
        objetdrop = CreateObject(ObjectID, x, y, z - 100, rx, ry, rz)
        SetObjectScale(objetdrop, sx, sy, sz)
        text = CreateText3D(_(item).." x"..amount, 15, x, y, z, 0,0,0)
        SetObjectPropertyValue(objetdrop, "isitem", true, true)
        SetObjectPropertyValue(objetdrop, "collision", false, true)
        SetObjectPropertyValue(objetdrop, "item", item, true)
        SetObjectPropertyValue(objetdrop, "amount", amount, true)
        SetObjectPropertyValue(objetdrop, "textid", text)
    end

    Delay(300000, function(objetdrop, text)
        if objetdrop ~= nil then
            DestroyObject(objetdrop)
            if text ~= nil then
                DestroyText3D(text)
            end
        end                           
    end, objetdrop, text)
end)

function SetInventory(player, item, amount)
    if (amount <= 0) then
        return false
    end

    PlayerData[player].inventory[item] = amount
    return true
end

function GetPlayerCash(player)
    if PlayerData[player].inventory['cash'] then
        return math.tointeger(PlayerData[player].inventory['cash'])
    else
        return 0
    end
end

function GetNumberOfItem(player, item)
    return tonumber(PlayerData[player].inventory[item]) or 0
end

function SetPlayerCash(player, amount)
    PlayerData[player].inventory['cash'] = math.max(math.tointeger(amount), 0)
end

function AddPlayerCash(player, amount)
    AddInventory(player, 'cash', math.tointeger(amount))
end

function RemovePlayerCash(player, amount)
    --UpdateUIInventory(player, 'cash', math.tointeger(amount)) -- on le fait déjà dans RemoveInventory
    return RemoveInventory(player, 'cash', math.tointeger(amount))
end

function GetPlayerBag(player)
    if PlayerData[player].inventory['item_backpack'] and math.tointeger(PlayerData[player].inventory['item_backpack']) > 0 then
        return 1
    else
        return 0
    end
end

function GetPlayerMaxSlots(player)
    if PlayerData[player].inventory['item_backpack'] and math.tointeger(PlayerData[player].inventory['item_backpack']) > 0 then
        return math.floor(inventory_base_max_slots + backpack_slot_to_add)
    else
        return inventory_base_max_slots
    end
end

function GetPlayerUsedSlots(player)
    local usedSlots = 0
    for k, v in pairs(PlayerData[player].inventory) do
        if k ~= 'cash' then
            usedSlots = usedSlots + (v * ItemsWeight[k])
        end
    end
    return usedSlots
end

function DisplayPlayerBackpack(player, anim)
    -- items ids : 818,820,821,823
    if GetPlayerBag(player) == 1 then
        if PlayerData[player].backpack == nil then -- Pour vérifier s'il n'a pas déjà un sac
            local x, y, z = GetPlayerLocation(player)
            PlayerData[player].backpack = CreateObject(820, x, y, z)
            SetObjectAttached(PlayerData[player].backpack, ATTACH_PLAYER, player, -30.0, -9.0, 0.0, -90.0, 0.0, 0.0, "spine_03")
            if anim == 1 then BackpackPutOnAnim(player) end -- Petite animation RP
        end
    else
        if PlayerData[player].backpack ~= nil then
            if anim == 1 then BackpackPutOnAnim(player, 2500) end -- Petite animation RP
            Delay(2500, function()
                DestroyObject(PlayerData[player].backpack)
            end)
        end
    end
end

function BackpackPutOnAnim(player, timer, animation)
    if timer == nil then timer = 5000 end
    if animation == nil then animation = 'CHECK_EQUIPMENT3' end
    SetPlayerAnimation(player, animation)
    Delay(timer, function()
        SetPlayerAnimation(player, "STOP")
    end)
end

AddFunctionExport("AddInventory", AddInventory)
AddFunctionExport("RemoveInventory", RemoveInventory)
AddFunctionExport("GetPlayerCash", GetPlayerCash)
AddFunctionExport("SetPlayerCash", SetPlayerCash)
AddFunctionExport("AddPlayerCash", AddPlayerCash)
AddFunctionExport("RemovePlayerCash", RemovePlayerCash)
AddFunctionExport("GetPlayerBag", GetPlayerBag)
AddFunctionExport("GetPlayerMaxSlots", GetPlayerMaxSlots)
AddFunctionExport("GetPlayerUsedSlots", GetPlayerUsedSlots)
AddFunctionExport("DisplayPlayerBackpack", DisplayPlayerBackpack)
