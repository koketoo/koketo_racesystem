nui = GetNui()
IsInRace = false

local getCheckpointColors = function (index)
    local colors = {
        [1] = { r = 255, g = 0, b = 0 },
        [2] = { r = 255, g = 165, b = 0 },
        [3] = { r = 255, g = 255, b = 0 }
    }
    
    return colors[index]
end

function addBlip(x, y, z, sprite, colour, text)
    local blip = AddBlipForCoord(x, y, z)
    SetBlipSprite(blip, sprite)
    SetBlipColour(blip, colour)
    SetBlipDisplay(blip, 2)
    SetBlipScale(blip, 1.0)

    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(text)
    EndTextCommandSetBlipName(blip)

    return blip
end

RegisterCommand('uc', function (source, args)

    local player = PlayerPedId()
    local passToCheck = args[1]

    if IsPedInAnyVehicle(player, false) then
        TriggerServerEvent('ybn_racesystem:check', passToCheck)
    else
        TriggerEvent('chat:addMessage', {
            args = {'^1Tines que estar en un coche para unirte a la carrera!'}
        })
    end
end)

function DeattachFromRace()
    RemoveBlip(firstCheckpointBlip)
    RemoveBlip(secondCheckpointBlip)
    if finishCheckpointBlip then
        RemoveBlip(finishCheckpointBlip)
    end

    DeleteCheckpoint(CheckpointHandler)
    if FinishChekcpointHandler then
        DeleteCheckpoint(FinishChekcpointHandler)
    end
end

function FinishCamAnim(password)
    nui.hide()
    local rot = GetGameplayCamRot(2)
    cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)

    RenderScriptCams(true, true, 500, true, false)

    AnimpostfxPlay("MP_Celeb_Preload", 0, false)
    AnimpostfxPlay("MP_Celeb_Preload_Fade", 0, false)
    Scaleform.BigNotification('HAS GANADO', ' ',5000)
    AnimpostfxPlay("MP_Celeb_Win", 0, false)
    AnimpostfxPlay("MP_Celeb_Win_Out", 0, false)
    local IsFinishingCamAnim = true
    Citizen.SetTimeout((5000), function()
        IsFinishingCamAnim = false
        TriggerServerEvent('ybn_racesystem:leaverace', password)
    end)

    while IsFinishingCamAnim do 
        SetCamCoord(cam, GetEntityCoords(PlayerPedId()).x, GetEntityCoords(PlayerPedId()).y, GetEntityCoords(PlayerPedId()).z + 5)
        SetCamRot(cam, -60.0, rot.y, rot.z, 2)
        DisableControlAction(1, 71, true)
        DisableControlAction(1, 72, true)
        DisableControlAction(1, 59, true)
        Citizen.Wait(0)
    end
    IsInRace = false
    RenderScriptCams(false, false, 0, false, false)
    DeattachFromRace()
end

RegisterNetEvent('ybn_racesystem:leaveracebycmd', function ()
    DeattachFromRace()
end)

RegisterNetEvent('ybn_racesystem:losescreen', function ()
    nui.hide()
    DeattachFromRace()
    AnimpostfxPlay("DeathFailOut", 5000, false)

    local IsLosing = false
    local scaleform = RequestScaleformMovie("MP_BIG_MESSAGE_FREEMODE")

    while not HasScaleformMovieLoaded(scaleform) do
        Wait(0)
    end

    PushScaleformMovieFunction(scaleform, "SHOW_SHARD_WASTED_MP_MESSAGE")
    BeginTextComponent("STRING")
    AddTextComponentString("~r~has perdido")
    EndTextComponent()
    PopScaleformMovieFunctionVoid()

    IsLosing = true

    SetTimeout((5000), function ()
        IsLosing = false
        IsInRace = false
    end)

    PlaySoundFrontend(-1, "Orientation_Fail", "DLC_Air_Race_Sounds_Player", 1)

    while IsLosing do
        DisableControlAction(1, 71, true)
        DisableControlAction(1, 72, true)
        DisableControlAction(1, 59, true)
        DrawScaleformMovieFullscreen(scaleform, 255, 255, 255, 255)
        Wait(0)

    end
end)

RegisterNetEvent('ybn_racesystem:joinrace', function (maxplayers, playersJoined)

    IsWaiting = true

    local ped = PlayerPedId()
    local veh = GetVehiclePedIsIn(ped, false)
    FreezeEntityPosition(veh, true)

    local joinedPlayers = #playersJoined

    while IsWaiting do
        DisableControlAction(1, 75, true)
        nui.showPlayersFeed(maxplayers, joinedPlayers)
        Wait(0)
    end

end)

RegisterNetEvent('ybn_racesystem:startrace', function (checkpointsCoords, checkpointsAmount, password)

    IsWaiting = false

    nui.hidePlayersFeed()
    nui.show()

    local ped = PlayerPedId()
    local veh = GetVehiclePedIsIn(ped, false)

    SetEntityInvincible(ped, true)
    SetEntityInvincible(veh, true)
    SetVehicleDoorsLocked(veh, 2)

    for i=1, 3 do

        local color = getCheckpointColors(i)
        Scaleform.ShowCountdown(4 - i, color.r, color.g, color.b, true)
        Wait(1000)
    end

    IsInRace = true

    Scaleform.GoCountDown(0, 255, 0, true)
    Wait(0)

    FreezeEntityPosition(veh, false)
    local race = {
        currentCheckpoint = nil,
        nextCheckpoint = nil,
        checkpointIndex = 1,
        IsRacing = true,
        checkpoints = checkpointsCoords,
        HasReachedFinish = false
    }
    OnCheckpoint = function ()

        race.currentCheckpoint = race.checkpoints[race.checkpointIndex]
        race.nextCheckpoint = race.checkpoints[race.checkpointIndex + 1]

        if race.nextCheckpoint then
            CheckpointHandler = CreateCheckpoint(12, race.currentCheckpoint.x, race.currentCheckpoint.y, race.currentCheckpoint.z + 2.5, race.nextCheckpoint.x, race.nextCheckpoint.y, race.nextCheckpoint.z + 2.5, 5.0, 255, 192, 0, 200, 0)

            firstCheckpointBlip = addBlip(race.currentCheckpoint.x, race.currentCheckpoint.y, race.currentCheckpoint.z, 1, 5, "Checkpoint de la Carrera")

            if race.nextCheckpoint == race.checkpoints[#race.checkpoints] then
                secondCheckpointBlip = addBlip(race.nextCheckpoint.x, race.nextCheckpoint.y, race.nextCheckpoint.z, 379, 3, "Final de la Carrera")
            else
                secondCheckpointBlip = addBlip(race.nextCheckpoint.x, race.nextCheckpoint.y, race.nextCheckpoint.z, 1, 5, "Checkpoint de la Carrera")
            end

        elseif race.nextCheckpoint == nil then
            FinishChekcpointHandler = CreateCheckpoint(16, race.currentCheckpoint.x, race.currentCheckpoint.y, race.currentCheckpoint.z + 2.5, race.currentCheckpoint.x, race.currentCheckpoint.y, race.currentCheckpoint.z + 2.5, 5.0, 255, 192, 0, 200, 0)

            finishCheckpointBlip = addBlip(race.currentCheckpoint.x, race.currentCheckpoint.y, race.currentCheckpoint.z, 379, 3, "Final de la Carrera")
        end


    end

    CreateThread(function()
        OnCheckpoint()
        while IsInRace do
            local pos = GetEntityCoords(ped)

            if race.currentCheckpoint then
                local dist = #(pos - vector3(race.currentCheckpoint["x"], race.currentCheckpoint["y"], race.currentCheckpoint["z"]))
                if dist < 5 then

                    if race.nextCheckpoint == nil and race.HasReachedFinish == false then
                        DeleteCheckpoint(FinishChekcpointHandler)
                        RemoveBlip(finishCheckpointBlip)
                        race.HasReachedFinish = true
                        PlaySoundFrontend(-1, "Checkpoint_Finish", "Island_Race_Soundset", 1)

                        TriggerServerEvent('ybn_racesystem:loseevent', password)
                        FinishCamAnim(password)
                    elseif race.nextCheckpoint then
                        race.checkpointIndex = race.checkpointIndex + 1
                        race.currentCheckpoint = race.checkpoints[race.checkpointIndex]
                        RemoveBlip(firstCheckpointBlip)
                        RemoveBlip(secondCheckpointBlip)
                        DeleteCheckpoint(CheckpointHandler)
                        OnCheckpoint()
                    end
                end
            end

            nui.updateData(tostring(checkpointsAmount), tostring(race.checkpointIndex))
            Wait(0)
        end
    end)
end)
