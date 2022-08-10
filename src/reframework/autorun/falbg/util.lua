require('falbg.button.joy_con_pad_button')
require('falbg.button.mouse_button')
require('falbg.button.ps_pad_button')
require('falbg.button.steam_pad_button')
require('falbg.button.xbox_pad_button')

local Util = {
    Settings = {
        SettingGamepadTrigger = false,
        SettingMouseTrigger = false,
        DEFAULT_GAMEPAD_TRIGGER = 2048,
        DEFAULT_MOUSE_TRIGGER = 1,
    },
    PlayerManager = nil,
    AppGamepad = nil,
    HardwareMouse = nil,
    MouseButton = require('falbg.button.mouse_button'),
    PadButton = require('falbg.button.xbox_pad_button'),
}

function Util.SafeRequire(name)
    local success = pcall(function() require(name) end) 
    if success then
        return require(name)
    end
    return nil
end

return Util
