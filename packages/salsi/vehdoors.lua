local modelstocheck = {
    {door = 6, vehid = 3},
    {door = 19, vehid = 3}
}
local doorstocheck = {}

function check_doors()
    local doorstoopen = {}
    local doorstoclose = {}
    for i, ply in pairs(GetAllPlayers()) do
        for i, door in pairs(doorstocheck) do
            for i, v in ipairs(modelstocheck) do
                if v.door == GetDoorModel(door) then
                    if GetVehicleModel(GetPlayerVehicle(ply)) == v.vehid then
                        local veh = GetPlayerVehicle(ply)
                        local x,y,z = GetDoorLocation(door)
                        local x2,y2,z2 = GetVehicleLocation(veh)
                        local dist = GetDistance3D(x, y, z, x2, y2, z2)

                        if dist < 700 then
                            if GetPlayerCount() > 1 then
                                doorstoopen[door] = true
                            else
                                SetDoorOpen(door, true)
                            end
                        else
                            if GetPlayerCount() > 1 then
                                doorstoclose[door] = true
                            else
                                SetDoorOpen(door, false)
                            end
                        end
                    else
                        doorstoclose[door] = true
                    end
                end
            end
        end
    end

    for kc,vc in pairs(doorstoclose) do
        if doorstoopen[kc] then
            SetDoorOpen(kc, true)
        else
            SetDoorOpen(kc, false)
        end
    end

    for ko,vo in pairs(doorstoopen) do 
        SetDoorOpen(ko, true)
    end
end

AddEvent("OnPackageStart",function()
    for i,door in pairs(GetAllDoors()) do
        for i, v in ipairs(modelstocheck) do
            if v.door == GetDoorModel(door) then
                table.insert(doorstocheck, door)
            end
        end
    end
    CreateTimer(check_doors, 200)
end)
