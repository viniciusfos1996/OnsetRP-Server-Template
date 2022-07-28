local Dialog = ImportPackage("dialogui")
local _ = function(k, ...) return ImportPackage("i18n").t(GetPackageName(), k, ...) end

local IsOnDuty = false

local taxiMenu
local taxiNpcGarageMenu
local taxiPayMenu
local CourseTime
local taxicourse

local taxiNpcIds = {}
local taxiVehicleNpcIds = {}
local taxiGarageIds = {}

local TaxiHud

local cautionTaxi = 0

function OnPackageStart()
    TaxiHud = CreateWebUI(0, 0, 0, 0, 0, 60)
    SetWebAlignment(TaxiHud, 1.0, 0.0)
    SetWebAnchors(TaxiHud, 0.0, 0.0, 1.0, 1.0) 
    LoadWebFile(TaxiHud, "http://asset/onsetrp/taxi/taxihud.html")
    SetWebVisibility(TaxiHud, WEB_HIDDEN)
end
AddEvent("OnPackageStart", OnPackageStart)


AddRemoteEvent("taxi:setup", function(_taxiNpcIds, _taxiGarageIds, _taxiVehicleNpcIds, _caution)
    taxiNpcIds = _taxiNpcIds
    taxiGarageIds = _taxiGarageIds
    taxiVehicleNpcIds = _taxiVehicleNpcIds
    cautionTaxi = _caution

    -- SPAWN VEHICLE MENU
    taxiNpcGarageMenu = Dialog.create(_("taxi_garage_menu"), _("taxi_disclaimer_caution", cautionTaxi), _("spawn_taxi_cash"), _("spawn_taxi_bank"), _("cancel"))
end)

AddRemoteEvent("taxi:client:isonduty", function(isOnDuty)
    IsOnDuty = isOnDuty
end)

AddEvent("OnTranslationReady", function()
        -- TAXI MENU
        taxiMenu = Dialog.create(_("taxi_menu"), nil, _("start_course"), _("end_course"),  _("cancel_course"), _("payement"), _("cancel"))

        -- PAYEMENT MENU
        taxiPayMenu = Dialog.create(_("payement menu"), nil, _("payin_cash"), _("payin_bank"), _("cancel"))
end)

AddEvent("OnKeyPress", function(key)
    
    if key == JOB_MENU_KEY and not GetPlayerBusy() and IsOnDuty then
        Dialog.show(taxiMenu)
    end
 
    if key == INTERACT_KEY and not GetPlayerBusy() and IsOnDuty and IsNearbyNpc(GetPlayerId(), taxiVehicleNpcIds) ~= false then
        Dialog.show(taxiNpcGarageMenu)
    end
    
    if key == INTERACT_KEY and not GetPlayerBusy() and IsNearbyNpc(GetPlayerId(), taxiNpcIds) ~= false then
        AskForTaxiJob(IsNearbyNpc(GetPlayerId(), taxiNpcIds))
    end
end)

function AskForTaxiJob(npc)
    
    local message = (IsOnDuty and _("taxi_npc_message_stop") or _("taxi_npc_message_start"))
    startCinematic({
        title = _("taxi_npc_name"),
        message = message,
        actions = {
            {
                text = _("yes"),
                callback = "taxi:startstopcinematic"
            },
            {
                text = _("no"),
                close_on_click = true
            }
        }
    }, NearestTaxi, "ITSJUSTRIGHT")
end

AddEvent("taxi:startstopcinematic", function()
    
    local message = (IsOnDuty and _("taxi_service_npc_end") or _("taxi_service_npc_starting"))
    updateCinematic({
        message = message
    }, NearestTaxi, "WALLLEAN04")
    Delay(1500, function()
        stopCinematic()
    end)
    CallRemoteEvent("taxi:startstopservice")
end)

AddEvent("OnDialogSubmit", function(dialog, button, ...)
    local args = {...}
    if dialog == taxiMenu then
        if button == 1 then -- start course
            CallRemoteEvent("course:start")
        end
        if button == 2 then -- stop course
            CallRemoteEvent("course:stop")
        end
        if button == 3 then   -- cancel course
            CallRemoteEvent("course:cancel")
        end
        if button == 4 then
            Dialog.show(taxiPayMenu)
        end
    end
    
    if dialog == taxiNpcGarageMenu then
        if button == 1 then
            CallRemoteEvent("taxi:checkcash")
        end
        if button == 2 then
            CallRemoteEvent("taxi:checkbank")
        end
    end 

    if dialog == taxiPayMenu then
        if button == 1 then
            CallRemoteEvent("notifCash")
        end
        if button == 2 then
            CallRemoteEvent("bankPay", CourseTime)
        end
    end
end)

function IsNearbyNpc(player, npcs)
    local x, y, z = GetPlayerLocation(player)
    for k, v in pairs(npcs) do
        local x2, y2, z2 = GetNPCLocation(v)
        if x2 ~= false and GetDistance3D(x, y, z, x2, y2, z2) <= 200 then return v end
    end
    return false
end


--- Course

AddRemoteEvent("course", function(state)
    if state then
        SetWebVisibility(TaxiHud, WEB_HITINVISIBLE)
        CourseTime = 0
        ExecuteWebJS(TaxiHud, "StartCourse("..CourseTime..");")
        taxicourse = CreateTimer(function(player)
            CourseTime = CourseTime + 1
            ExecuteWebJS(TaxiHud, "StartCourse("..CourseTime..");")
        end, 2000, player)
    else
        DestroyTimer(taxicourse)
    end
end)

AddRemoteEvent("HideTaxiHud", function()
    SetWebVisibility(TaxiHud, WEB_HIDDEN)
end)

AddRemoteEvent("cancelcourse", function()
    if GetWebVisibility(TaxiHud) == 0 then
        SetWebVisibility(WEB_HITINVISIBLE)
    end
    DestroyTimer(taxicourse)
    local CourseTime = 0
    ExecuteWebJS(TaxiHud, "StartCourse("..CourseTime..");")
    Delay(1000, function()
        SetWebVisibility(TaxiHud, WEB_HIDDEN)
    end)
end)
