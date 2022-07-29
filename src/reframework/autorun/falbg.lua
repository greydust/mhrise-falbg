local DEFAULT_GAMEPAD_TRIGGER = 2048
local DEFAULT_MOUSE_TRIGGER = 1

local PadButtons = require("falbg.pad_buttons")
local MouseButtons = require("falbg.mouse_buttons")

local padDevice = sdk.find_type_definition("snow.Pad.Device");
local mouseDevice = sdk.find_type_definition("snow.StmMouse.HardwareDevice");

local lbg = "snow.player.LightBowgun"
local bow = "snow.player.Bow"
local delay = 3

local settings = {
    lbgEnabled = true,
    bowEnabled = false,
    enableGamepad = true,
    gamepadTrigger = DEFAULT_GAMEPAD_TRIGGER,
    enableMouse = false,
    mouseTrigger = DEFAULT_MOUSE_TRIGGER,
}
local playerManager = nil;
local appGamepad = nil
local hardwareMouse = nil;

local function saveSettings()
	json.dump_file("falbg.json", settings)
end

local function loadSettings()
	local loadedSettings = json.load_file("falbg.json")
	if loadedSettings then
        for k,v in pairs(loadedSettings) do settings[k] = v end
	end
end

loadSettings()

local function isUsing(weapon)
    if playerManager then
        local players = playerManager:get_field("PlayerList")
        local playerId = playerManager:call("getMasterPlayerID")
        if #players > playerId then
            local player = players[playerId]
            if player and player:get_type_definition():get_full_name() == weapon then
                return true
            end
        end
    end
    return false
end
local count = 0
sdk.hook(padDevice:get_method("update"), function(args) end,
function(retval)
    if  settings.enableGamepad and appGamepad and ((settings.lbgEnabled and isUsing(lbg)) or (settings.bowEnabled and isUsing(bow))) then
        local on = appGamepad:get_field("_on")
        if on & settings.gamepadTrigger ~= 0 then
            print("Count: ",count)
            if count / delay >= 1 then
                local trg = appGamepad:get_field("_trg")
                trg = trg | settings.gamepadTrigger
                appGamepad:set_field("_trg",trg)
                count = 0
            else
                appGamepad:set_field("_on",0)
                appGamepad:set_field("_trg",0)
                count = count + 1
            end
        end
    end
    return retval
end)

sdk.hook(mouseDevice:get_method("update"), function(args) end,
function(retval)
    if  settings.enableMouse and hardwareMouse and ((settings.lbgEnabled and isUsing(lbg)) or (settings.bowEnabled and isUsing(bow))) then
        local on = hardwareMouse:get_field("_on")
        if on & settings.mouseTrigger ~= 0 then
            local trg = hardwareMouse:get_field("_trg")
            trg = trg | settings.mouseTrigger
            hardwareMouse:set_field("_trg", trg)
        end
    end
    return retval
end)

re.on_pre_application_entry("UpdateBehavior", function()
    if not playerManager then
        playerManager = sdk.get_managed_singleton("snow.player.PlayerManager")
    end

    if not appGamepad then
        appGamepad = sdk.get_managed_singleton("snow.Pad"):get_field("app")
    end

    if not hardwareMouse then
        hardwareMouse = sdk.get_managed_singleton("snow.StmMouse"):get_field("hardmouse")
    end
end)

local settingGamepadTrigger = false
local settingMouseTrigger = false
re.on_draw_ui(function()
    if settingGamepadTrigger then
        settings.gamepadTrigger = 0
        local button = appGamepad:call("get_on")
        if button > 0 and PadButtons[button] ~= nil then
            settings.gamepadTrigger = button
            settingGamepadTrigger = false
        end
    end
    if settingMouseTrigger then
        settings.mouseTrigger = 0
        local button = hardwareMouse:call("get_on")
        if button > 0 and MouseButtons[button] ~= nil then
            settings.mouseTrigger = button
            settingMouseTrigger = false
        end
    end

    if imgui.tree_node("Fully Automatic LBG & Bow") then
		if imgui.button("Save Settings") then
			saveSettings();
		end

        changed, value = imgui.checkbox("LBG Enabled", settings.lbgEnabled)
        if changed then
            settings.lbgEnabled = value
            saveSettings()
        end

        changed, value = imgui.checkbox("Bow Enabled", settings.bowEnabled)
        if changed then
            settings.bowEnabled = value
            saveSettings()
        end

        imgui.new_line()

        changed, value = imgui.checkbox("Enable Gamepad", settings.enableGamepad)
        if changed then
            settings.enableGamepad = value
            saveSettings()
        end
        imgui.text("Gamepad Trigger")
        imgui.same_line()
        if imgui.button(PadButtons[settings.gamepadTrigger]) then
            if appGamepad then
                settingGamepadTrigger = true
            end
        end

        changed, value = imgui.checkbox("Enable Mouse", settings.enableMouse)
        if changed then
            settings.enableMouse = value
            saveSettings()
        end
        imgui.text("Mouse Trigger")
        imgui.same_line()
        if imgui.button(MouseButtons[settings.mouseTrigger]) then
            if hardwareMouse then
                settingMouseTrigger = true
            end
        end


        imgui.tree_pop();
    end

end)

re.on_config_save(function()
	saveSettings();
end)