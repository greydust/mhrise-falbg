local nativeUI = require('falbg.native_ui')
local setting = require('falbg.setting')
local util = require('falbg.util')

local padDevice = sdk.find_type_definition('snow.Pad.Device');
local mouseDevice = sdk.find_type_definition('snow.StmMouse.HardwareDevice');

setting.LoadSettings()

nativeUI.Init()

local function isUsingLbg()
    if util.PlayerManager then
        local players = util.PlayerManager:get_field('PlayerList')
        local playerId = util.PlayerManager:call('getMasterPlayerID')
        if #players > playerId then
            local player = players[playerId]
            if player and player:get_type_definition():get_full_name() == 'snow.player.LightBowgun' then
                return true
            end
        end
    end
    return false
end

sdk.hook(padDevice:get_method('update'), function(args) end,
function(retval)
    if setting.Settings.enabled and setting.Settings.enableGamepad and util.AppGamepad and isUsingLbg() then
        local on = util.AppGamepad:get_field('_on')
        if on & setting.Settings.gamepadTrigger ~= 0 then
            local trg = util.AppGamepad:get_field('_trg')
            trg = trg | setting.Settings.gamepadTrigger
            util.AppGamepad:set_field('_trg', trg)
        end
    end
    return retval
end)

sdk.hook(mouseDevice:get_method('update'), function(args) end,
function(retval)
    if setting.Settings.enabled and setting.Settings.enableMouse and util.HardwareMouse and isUsingLbg() then
        local on = util.HardwareMouse:get_field('_on')
        if on & setting.Settings.mouseTrigger ~= 0 then
            local trg = util.HardwareMouse:get_field('_trg')
            trg = trg | setting.Settings.mouseTrigger
            util.HardwareMouse:set_field('_trg', trg)
        end
    end
    return retval
end)

re.on_pre_application_entry('UpdateBehavior', function()
    if not util.PlayerManager then
        util.PlayerManager = sdk.get_managed_singleton('snow.player.PlayerManager')
    end

    if not util.AppGamepad then
        local pad = sdk.get_managed_singleton('snow.Pad')
        if pad then
            util.AppGamepad = pad:get_field('app')
            local padType = util.AppGamepad:get_field("_DeviceKindDetails")
            if padType ~= nil then
                if padType >= 5 and padType <= 9 then
                    util.PadButton = require('falbg.button.ps_button')
                elseif padType >= 10 and padType <= 14 then
                    util.PadButton = require('falbg.button.xbox_button')
                elseif padType >= 16 and padType <= 18 then
                    util.PadButton = require('falbg.button.joy_con_button')
                else
                    util.PadButton = require('falbg.button.xbox_button')
                end
            else
                util.PadButton = require('falbg.button.xbox_button')
            end
        end
    end

    if not util.HardwareMouse then
        local stmMouse = sdk.get_managed_singleton('snow.StmMouse')
        if stmMouse then
            util.HardwareMouse = stmMouse:get_field('hardmouse')
        end
    end

    setting.UpdateKeyBinding()
end)

re.on_draw_ui(function()
    if imgui.tree_node('Fully Automatic LBG') then
        local changed, value = imgui.checkbox('Enabled', setting.Settings.enabled)
        if changed then
            setting.Settings.enabled = value
            setting.SaveSettings()
        end

        imgui.new_line()

        changed, value = imgui.checkbox('Enable Gamepad', setting.Settings.enableGamepad)
        if changed then
            setting.Settings.enableGamepad = value
            setting.SaveSettings()
        end
        imgui.text('Gamepad Trigger')
        imgui.same_line()
        if imgui.button(util.PadButton[setting.Settings.gamepadTrigger]) then
            if util.AppGamepad then
                util.Settings.SettingGamepadTrigger = true
            end
        end

        changed, value = imgui.checkbox('Enable Mouse', setting.Settings.enableMouse)
        if changed then
            setting.Settings.enableMouse = value
            setting.SaveSettings()
        end
        imgui.text('Mouse Trigger')
        imgui.same_line()
        if imgui.button(util.MouseButton[setting.Settings.mouseTrigger]) then
            if util.HardwareMouse then
                util.Settings.SettingMouseTrigger = true
            end
        end

        imgui.tree_pop();
    end
end)

re.on_config_save(function()
	setting.SaveSettings();
end)
