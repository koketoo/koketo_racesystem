Scaleform = {}

Scaleform.BigNotification = function(title, subtitle,duration)
    Citizen.CreateThread(function()
        local scaleform = RequestScaleformMovie("mp_big_message_freemode")
        while not HasScaleformMovieLoaded(scaleform) do
            Citizen.Wait(0)
        end
        BeginScaleformMovieMethod(scaleform, "SHOW_SHARD_WASTED_MP_MESSAGE")
        PushScaleformMovieMethodParameterString(title)
        PushScaleformMovieMethodParameterString(subtitle)
        PushScaleformMovieMethodParameterInt(5)
        EndScaleformMovieMethod()
        local drawing = true
        Citizen.SetTimeout((duration), function()
            drawing = false
        end)
        while drawing do
            Citizen.Wait(0)
            DrawScaleformMovieFullscreen(scaleform, 255, 255, 255, 255)
        end
        SetScaleformMovieAsNoLongerNeeded(scaleform)
        AnimpostfxStopAll()
    end)
end

function Scaleform.Request(scaleform)
    local scaleform_handle = RequestScaleformMovie(scaleform)
    while not HasScaleformMovieLoaded(scaleform_handle) do
        Citizen.Wait(0)
    end
    return scaleform_handle
end
function Scaleform.CallFunction(scaleform, returndata, the_function, ...)
    BeginScaleformMovieMethod(scaleform, the_function)
    local args = { ... }

    if args ~= nil then
        for i = 1, #args do
            local arg_type = type(args[i])

            if arg_type == "boolean" then
                ScaleformMovieMethodAddParamBool(args[i])
            elseif arg_type == "number" then
                if not string.find(args[i], '%.') then
                    ScaleformMovieMethodAddParamInt(args[i])
                else
                    ScaleformMovieMethodAddParamFloat(args[i])
                end
            elseif arg_type == "string" then
                ScaleformMovieMethodAddParamTextureNameString(args[i])
            end
        end

        if not returndata then
            EndScaleformMovieMethod()
        else
            return EndScaleformMovieMethodReturnValue()
        end
    end
end

Scaleform.Countdown = function(_number, _r, _g, _b)
    local scaleform = Scaleform.Request('COUNTDOWN')
    Scaleform.CallFunction(scaleform, false, "SET_MESSAGE", _number, _r, _g, _b, true)
    Scaleform.CallFunction(scaleform, false, "FADE_MP", _number, _r, _g, _b)
    return scaleform
end

Scaleform.ShowCountdown = function(title, _r, _g, _b, _playSound)
    local showCD = true
    local scale = 0
    if _playSound ~= nil and _playSound == true then
        PlaySoundFrontend(-1, "Checkpoint_Finish", "DLC_Stunt_Race_Frontend_Sounds", 1)
    end

    Citizen.CreateThread(function()
        scale = Scaleform.Countdown(title, _r, _g, _b)

        SetTimeout(1000, function()
            showCD = false
        end)
        while showCD do
            Citizen.Wait(1)
            DrawScaleformMovieFullscreen(scale, 255, 255, 255, 255)
        end
    end)
end

Scaleform.GoCountDown = function( _r, _g, _b, _playSound)
    local showCD = true
    local scale = 0
    if _playSound ~= nil and _playSound == true then
        PlaySoundFrontend(-1, "Checkpoint_Finish", "DLC_AW_Frontend_Sounds", 1)
    end

    Citizen.CreateThread(function()
        scale = Scaleform.Countdown("YA", _r, _g, _b)

        SetTimeout(1000, function()
            showCD = false
        end)
        while showCD do
            Citizen.Wait(1)
            DrawScaleformMovieFullscreen(scale, 255, 255, 255, 255)
        end
    end)
end

Scaleform.DrawText = function(text, x, y, scale)

    SetTextFont(4)
    SetTextProportional(1)
    SetTextScale(scale, scale)
    SetTextColour(255, 255, 255, 255)
    SetTextDropshadow(0, 0, 0, 0, 255)
    SetTextEdge(2, 0, 0, 0, 150)
    SetTextDropShadow()
    SetTextOutline()
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(x, y)
end

Scaleform.Draw3D = function(x, y, z, text, scale, color)
    if not color then
        color = {
            r = 255,
            g = 255,
            b = 255,
            a = 255
        }
    end
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    SetTextScale(scale, scale)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextDropshadow(1, 1, 0, 0, 255)

    SetTextColour(color.r, color.g, color.b, color.a)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x, _y)

    local factor = string.len(text) / 370
end
