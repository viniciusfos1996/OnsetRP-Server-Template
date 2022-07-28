local Dialog = ImportPackage("dialogui")
local _ = function(k, ...) return ImportPackage("i18n").t(GetPackageName(), k, ...) end

local wpObject
local currentCallout
local wplocation = {}

local calloutsUI = nil

function OnPackageStart()
	calloutsUI = CreateWebUI(0, 0, 0, 1, 60)
	LoadWebFile(calloutsUI, "http://asset/" .. GetPackageName() .. "/callouts/ui/index.html")
    SetWebAlignment(calloutsUI, 0, 0)
    SetWebAnchors(calloutsUI, 0, 0, 1, 1)
    SetWebVisibility(calloutsUI, WEB_HIDDEN)
end
AddEvent("OnPackageStart", OnPackageStart)

function OpeningCalloutMenu() 
    CallRemoteEvent("callouts:getlist")    
end
AddEvent("callouts:openingmenu", OpeningCalloutMenu)
AddRemoteEvent("callouts:openingmenu", OpeningCalloutMenu)

AddRemoteEvent("callouts:displaymenu", function(callouts)
    SetIgnoreLookInput(true)
    SetIgnoreMoveInput(true)
    ShowMouseCursor(true)
    SetInputMode(INPUT_GAMEANDUI)
    SetWebVisibility(calloutsUI, WEB_VISIBLE)
    
    ExecuteWebJS(calloutsUI, 'LoadCallouts('..json_encode(callouts)..');')
end)

AddRemoteEvent("callouts:updatelist", function(callouts)
    ExecuteWebJS(calloutsUI, 'LoadCallouts('..json_encode(callouts)..');')
end)

AddEvent("OnDialogSubmit", function(dialog, button, ...)
    local args = {...}
    if dialog == calloutsMenu then
        if button == 1 then
            if args[1] == "" then
                MakeErrorNotification(_("callout_please_choose_callout"))
                return
            end
            CallRemoteEvent("callouts:start", args[1])            
        end
    end
end)

function StopCurrentCallout()
    CallRemoteEvent("callouts:end", currentCallout)
end
AddEvent("callouts:stoppingcallout", StopCurrentCallout)

function CreateCallout(service, reason)
    CallRemoteEvent("callouts:create", service, reason)
end
AddEvent("callouts:new", CreateCallout)

function TakeCallout(calloutId)
    CallRemoteEvent("callouts:start", calloutId)
end
AddEvent("callouts:ui:take", TakeCallout)

function StopCallout(calloutId)
    CallRemoteEvent("callouts:end", calloutId)
end
AddEvent("callouts:ui:stop", StopCallout)

function CloseCallout(player)
    SetIgnoreLookInput(false)
    SetIgnoreMoveInput(false)
    ShowMouseCursor(false)
    SetInputMode(INPUT_GAME)
    SetWebVisibility(calloutsUI, WEB_HIDDEN)
    CallRemoteEvent("account:setplayernotbusy")
end
AddEvent("callouts:ui:close", CloseCallout)

AddRemoteEvent("callouts:createtaxiwp", function(x, y, z, label)
    taxiwp = CreateWaypoint(x, y, z, tostring(label))
    GetPickupStaticMeshComponent(pickup):SetHiddenInGame(true)
    Delay(360000, function()
        if taxiwp ~= nil then
            DestroyWaypoint(taxiwp)
        end
    end)
end)

AddRemoteEvent("callouts:createwp", function(target, x, y, z, label)
    if wpObject ~= nil then DestroyWaypoint(wpObject) end
    currentCallout = target
    wpObject = CreateWaypoint(x, y, z, tostring(label))

    CallEvent("UpdateCalloutDestination", x, y)    
end)

AddRemoteEvent("callouts:cleanwp", function()
    currentCallout = nil
    if wpObject ~= nil then DestroyWaypoint(wpObject) end
    wpObject = nil
    CallEvent("ClearCalloutDestination")
end)

-- TAXI WAYPOINT

AddRemoteEvent("DestroyTaxiWP", function(pickup)
    local px, py, pz = GetPickupLocation(pickup)
    for k, v in pairs(GetAllWaypoints()) do
        local wx, wy, wz = GetWaypointLocation(v)
        local distance = GetDistance3D(px, py, pz, wx, wy, wz)
        if distance < 30 then
            DestroyWaypoint(v)
            CallRemoteEvent("DestroyPickup", pickup)
            break
        end
    end
end)

AddEvent("OnPickupStreamIn", function(pickup)
    if GetPickupPropertyValue(pickup, "TaxiCall") then
        GetPickupStaticMeshComponent(pickup):SetHiddenInGame(true)
    end
end)
