AddEvent("OnPlayerWeaponShot", function(player, weapon, hittype, hitid, hitX, hitY, hitZ, startX, startY, normalX, normalY, normalZ)
    if hittype == 5 then
        local modelId = GetObjectModel(hitid)
       if modelId ~= false and modelId <= 62 and modelId >= 58 then
            local x, y, z = GetObjectLocation(hitid)
            local rx, ry, rz = GetObjectRotation(hitid)
            local sx, sy, sz = GetObjectScale(hitid)
            DestroyObject(hitid)
            local objectid = CreateObject(51, x, y, z)
            SetObjectRotation(objectid, rx, ry, rz)
            SetObjectScale(objectid, sx, sy, sz)
        end
    end
end)