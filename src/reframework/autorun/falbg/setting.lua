local util = require('falbg.util')

local Setting = {
    Settings = {
        enabled = true,
        enableGamepad = true,
        gamepadTrigger = util.Settings.DEFAULT_GAMEPAD_TRIGGER,
        enableMouse = false,
        mouseTrigger = util.Settings.DEFAULT_MOUSE_TRIGGER,
    },
}

function Setting.SaveSettings()
	json.dump_file('falbg.json', Setting.Settings)
end

function Setting.LoadSettings()
	local loadedSettings = json.load_file('falbg.json')
	if loadedSettings then
        for k, v in pairs(loadedSettings) do
            Setting.Settings[k] = v
        end
	end
end

function Setting.UpdateKeyBinding()
    if util.Settings.SettingGamepadTrigger then
        Setting.Settings.gamepadTrigger = 0
        local button = util.AppGamepad:call('get_on')
        if button > 0 and util.PadButton[button] ~= nil then
            Setting.Settings.gamepadTrigger = button
            util.Settings.SettingGamepadTrigger = false
            Setting.SaveSettings()
        end
    end
    if util.Settings.SettingMouseTrigger then
        Setting.Settings.mouseTrigger = 0
        local button = util.HardwareMouse:call('get_on')
        if button > 0 and util.MouseButton[button] ~= nil then
            Setting.Settings.mouseTrigger = button
            util.Settings.SettingMouseTrigger = false
            Setting.SaveSettings()
        end
    end

end

return Setting
