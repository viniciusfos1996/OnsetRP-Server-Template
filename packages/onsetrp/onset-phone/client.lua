local _ = _ or function(k,...) return ImportPackage("i18n").t(GetPackageName(),k,...) end

local previousInputMode

local web = CreateWebUI(0, 0, 0, 0, 2, 60)
SetWebVisibility(web, WEB_HIDDEN)
SetWebAlignment(web, 0, 0)
SetWebAnchors(web, 0, 0, 1, 1)
SetWebURL(web, "http://asset/" .. GetPackageName() .. "/onset-phone/ui/dist/index.html")

local phoneOpened = false
local phoneHome
local phoneContacts

AddEvent("OnKeyPress", function(key)
    if key == "K" and not phoneOpened and not GetPlayerBusy() then
        OpenPhone()
    elseif key == "Escape" and phoneOpened then
        ClosePhone()
    end
end)

-- LOADING

AddRemoteEvent("OnPhoneLoaded", function(player, phoneNumber, money, messages, contacts)
    phoneOpened = true
    CallRemoteEvent("account:setplayerbusy")
    ExecuteWebJS(web, "initPhone({ currentUserPhone: '"..phoneNumber.."', money: "..money..", contacts: "..json_encode(contacts)..", messages: "..json_encode(messages).."});")
    SetIgnoreLookInput(true)
    SetIgnoreMoveInput(true)
    ShowMouseCursor(true)
    SetInputMode(INPUT_UI)
    SetWebVisibility(web, WEB_VISIBLE)
end)

-- CONTACT CREATED

AddEvent("ContactCreated", function(name, phone)
    CallRemoteEvent("ContactCreated", name, phone)
end)

-- CONTACT UPDATED

AddEvent("ContactUpdated", function(name, phone)
    CallRemoteEvent("ContactUpdated", name, phone)
end)

-- CONTACT DELETED

AddEvent("ContactDeleted", function(name, phone)
    CallRemoteEvent("ContactDeleted", name, phone)
end)

-- MESSAGE CREATED

AddEvent("MessageCreated", function(phone, content)
    CallRemoteEvent("MessageCreated", phone, content)
end)

-- GPS CLICK

AddEvent("MessageGPSClicked", function(latitude, longitude)
    CallRemoteEvent("MessageGPSClicked", latitude, longitude)
end)

-- MESSAGE RECEIVED

AddRemoteEvent("NewMessage", function(from, to, content, created_at)
    MakeSuccessNotification(_("new_message"))
    ExecuteWebJS(web, 'newMessage('..json_encode({ from = from, to = to, content = content, created_at = tostring(created_at) })..');')
end)

-- UI FUNCTIONS

AddEvent("ClosePhone", function()
    ClosePhone()
end)

function ClosePhone()
    CallRemoteEvent("account:setplayernotbusy")
    phoneOpened = false
    SetIgnoreLookInput(false)
    SetIgnoreMoveInput(false)
    ShowMouseCursor(false)
    SetInputMode(INPUT_GAME)
    SetWebVisibility(web, WEB_HIDDEN)
    CallRemoteEvent("UnloadPhone")
end

function OpenPhone()
    CallRemoteEvent("LoadPhone")
end

AddRemoteEvent("StockPhone", function(OPhone)
    if OPhone ~= nil then
        phone = OPhone
    else
        CallRemoteEvent("DestroyPhone", phone)
    end
end)
