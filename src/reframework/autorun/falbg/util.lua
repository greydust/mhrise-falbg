require('falbg.button.joy_con_button')
require('falbg.button.mouse_button')
require('falbg.button.ps_button')
require('falbg.button.steam_button')
require('falbg.button.xbox_button')

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
    PadButton = require('falbg.button.xbox_button'),
}

function Util.SafeRequire(name)
    local success = pcall(function() require(name) end) 
    if success then
        return require(name)
    end
    return nil
end

function Util.DeepCopy(target, source)
    if type(source) ~= 'table' then return end
    
    for k, v in pairs(source) do
        if type(v) == 'table' then
            if type(target[k]) ~= 'table' then
                target[k] = {}
            end
            Util.DeepCopy(target[k], v)
        else
            target[k] = v
        end
    end
end

return Util
