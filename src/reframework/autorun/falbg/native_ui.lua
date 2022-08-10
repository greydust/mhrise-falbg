local modUI = nil
local setting = require('falbg.setting')
local util = require('falbg.util')

local NativeUI = {}

function NativeUI.draw()
    modUI.Header('Fully Automatic LBG')
    changed, value = modUI.CheckBox('Enabled', setting.Settings.enabled, 'Enable this mod.')
    if changed then
        setting.Settings.enabled = value
        setting.SaveSettings()
    end
    changed, value = modUI.CheckBox('Enable Gamepad', setting.Settings.enableGamepad, 'Enable gamepad support.')
    if changed then
        setting.Settings.enableGamepad = value
        setting.SaveSettings()
    end
    if modUI.Button('Gamepad Trigger', util.PadButton[setting.Settings.gamepadTrigger]) then
        if util.AppGamepad then
            util.Settings.SettingGamepadTrigger = true
        end
    end

    changed, value = modUI.CheckBox('Enable Mouse', setting.Settings.enableMouse, 'Enable mouse support.')
    if changed then
        setting.Settings.enableMouse = value
        setting.SaveSettings()
    end
    if modUI.Button('Mouse Trigger', util.MouseButton[setting.Settings.mouseTrigger], false, 'Please use keyboard or gamepad to press this button.') then
        if util.HardwareMouse then
            util.Settings.SettingMouseTrigger = true
        end
    end
end

function NativeUI.Init()
    modUI = util.SafeRequire('ModOptionsMenu.ModMenuApi')
    if modUI then
        modUI.OnMenu('Fully Automatic LBG', 'Turns your LBG into a fully automatic LBG.', NativeUI.draw)
    end
end

return NativeUI
