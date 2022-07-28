local _ = function(k, ...) return ImportPackage("i18n").t(GetPackageName(), k, ...) end

shortcutsUI = nil

function OnPackageStart()
	shortcutsUI = CreateWebUI(0, 0, 0, 0, 60)
	LoadWebFile(shortcutsUI, "http://asset/" .. GetPackageName() .. "/shortcuts/index.html")
	SetWebSize(shortcutsUI, 600, 900)
	SetWebAlignment(shortcutsUI, 0.5, 0.5)
	SetWebAnchors(shortcutsUI, 0.5, 0.5, 0.5, 0.5)
    SetWebVisibility(shortcutsUI, WEB_HIDDEN)
end
AddEvent("OnPackageStart", OnPackageStart)

function OnKeyPress(key)
	if key == SHORTCUT_VIEWER_KEY and not GetPlayerBusy() then
		if(GetWebVisibility(shortcutsUI) == 0) then
            SetIgnoreLookInput(true)
            SetIgnoreMoveInput(true)
            ShowMouseCursor(true)
            SetInputMode(INPUT_GAMEANDUI)
            SetWebVisibility(shortcutsUI, WEB_VISIBLE)
		else
			SetIgnoreLookInput(false)
            SetIgnoreMoveInput(false)
            ShowMouseCursor(false)
            SetInputMode(INPUT_GAME)
            SetWebVisibility(shortcutsUI, WEB_HIDDEN)
		end
	end
end
AddEvent("OnKeyPress", OnKeyPress)

function OnShortcutsClosed()
    SetIgnoreLookInput(false)
    SetIgnoreMoveInput(false)
    ShowMouseCursor(false)
    SetInputMode(INPUT_GAME)
    SetWebVisibility(shortcutsUI, WEB_HIDDEN)
end
AddEvent("OnShortcutsClosed", OnShortcutsClosed)

AddEvent("OnHideMainMenu", function()
    if GetWebVisibility(shortcutsUI) ~= 0 then
        Delay(1, function()
            SetIgnoreLookInput(true)
            SetIgnoreMoveInput(true)
            ShowMouseCursor(true)
            SetInputMode(INPUT_GAMEANDUI)  
        end)
    end
end)
