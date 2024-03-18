local builder = {}
local Race = Race or {}

builder.rendering = false

Race.Config = {
    password = nil,
    maxplayers = nil,
    checkpointsAmount = 0,
    startpointsAmount = 0,
    checkpointsCoords = {},
    startpointsCoords = {},
    startpointsHeading = {}
}


builder.resetConfig = function ()
    Race.Config.password = nil
    Race.Config.maxplayers = nil
    Race.Config.checkpointsAmount = 0
    Race.Config.startpointsAmount = 0
    Race.Config.checkpointsCoords = {}
    Race.Config.startpointsCoords = {}
    Race.Config.startpointsHeading = {}
end

builder.getInput = function(title, prompt, placeholder)
    local input = lib.inputDialog(title, {
        { type = 'input', label = prompt, description = placeholder, required = true, min = 1, max = 16 },
    })

    if not input then
        return builder.getInput(title, prompt, placeholder)
    end
    return input[1]
end

builder.startpointsMenu = function ()
    local startpointsMenu = Menu.new("Puntos de inicio", "startpoints", "top-right")

    local addStartPoint = Button.new("Añadir un punto de inicio", "Añade un punto de inicio a la carrera", function ()
        local ped = PlayerPedId()
        local pedCo = GetEntityCoords(ped)
        local pedHead = GetEntityHeading(ped)

        Race.Config.startpointsAmount = Race.Config.startpointsAmount + 1
        table.insert(Race.Config.startpointsCoords, #Race.Config.startpointsCoords + 1, pedCo)

        table.insert(Race.Config.startpointsHeading, #Race.Config.startpointsHeading + 1, pedHead)

        builder.startpointsMenu()
    end)
    addStartPoint:setIcon("fa-solid fa-plus")
    startpointsMenu:add(addStartPoint)
    
    -- Delete checkpoint
    
    local subStartPoint = Button.new("Eliminar un punto de inicio", "Elimina el ultimo punto de inicio establecido", function ()
        Race.Config.startpointsAmount = Race.Config.startpointsAmount - 1
        table.remove(Race.Config.startpointsCoords, #Race.Config.startpointsCoords)
        table.remove(Race.Config.startpointsHeading, #Race.Config.startpointsHeading)
        builder.startpointsMenu()
    end)
    subStartPoint:setIcon("fa-solid fa-minus")
    startpointsMenu:add(subStartPoint)

    startpointsMenu:onClose(function ()
        builder.optionsMenu()
    end)

    startpointsMenu:open()
end

builder.checkpointsMenu  = function ()
    local checkPointMenu = Menu.new("checkpoints", "Checkpoints", "top-right")

    -- Make the player be in noclip to 

    
    -- Add checkpoint button

    local addCheckpoint = Button.new("Añadir un checkpoint", "Añade un checkpoint a la carrera", function ()
        local ped = PlayerPedId()
        local pedCo = GetEntityCoords(ped)

        Race.Config.checkpointsAmount = Race.Config.checkpointsAmount + 1
        table.insert(Race.Config.checkpointsCoords, #Race.Config.checkpointsCoords + 1, pedCo)

        builder.checkpointsMenu()
    end)
    addCheckpoint:setIcon("fa-solid fa-plus")
    checkPointMenu:add(addCheckpoint)
    
    -- Delete checkpoint
    
    local subCheckpoint = Button.new("Eliminar checkpoint", "Elimina el ultimo checkpoint establecido", function ()
        Race.Config.checkpointsAmount = Race.Config.checkpointsAmount - 1
        table.remove(Race.Config.checkpointsCoords, #Race.Config.checkpointsCoords)
        builder.checkpointsMenu()
    end)
    subCheckpoint:setIcon("fa-solid fa-minus")
    checkPointMenu:add(subCheckpoint)

    checkPointMenu:onClose(function ()
        builder.optionsMenu()
    end)

    checkPointMenu:open()
end

builder.optionsMenu = function ()
    local optionMenu = Menu.new("options", "Opciones de la carrera", "top-right")

    -- Checkpoints button:
    local checkpointsButton = Button.new("Añadir Checkpoints", "Elige el transcurso de tu carrera!", function ()
        builder.checkpointsMenu()
    end)
    checkpointsButton:setIcon("fa-solid fa-user-group")
    optionMenu:add(checkpointsButton)

    -- Startpoints button:
    local startpointsButton = Button.new("Añadir puntos de inicio", "Elige los puntos de salida de tu carrera!", function ()
        builder.startpointsMenu()
    end)
    startpointsButton:setIcon("fa-solid fa-flag-checkered")
    optionMenu:add(startpointsButton)

    -- Open and close stuff

    optionMenu:open()

    optionMenu:onClose(function ()
        builder.mainMenu()
    end)
end

builder.mainMenu = function ()

    local menu = Menu.new("Configurador", "configcarrera", "top-right")
    builder.rendering = true
    -- Password Button

    local passButton = Button.new("Contraseña: (".. (Race.Config.password or "Sin asignar") ..")", "Introduce la contraseña para tu carrera!", function()
        local password = builder.getInput("Contraseña", "Introduce tu contraseña:", "")
        if password then
            Race.Config.password = password
        end
        builder.mainMenu()
    end)
    
    passButton:setIcon("fa-solid fa-lock")
    menu:add(passButton)

    -- Config button
    local optionsButton = Button.new("Opciones de la carrera", "Ajusta la carrera a tu gusto!", function ()
        builder.optionsMenu()
    end)
    optionsButton:setIcon("fa-solid fa-gear")
    menu:add(optionsButton)

    -- Start button
    local buttonStartRace = Button.new("Empezar carrera", "Empieza la carrera!", function ()
           
        local password, maxplayers, checkpointsAmount, checkpointsCoords, startpointsCoords, startpointsHeading = Race.Config.password, Race.Config.startpointsAmount, Race.Config.checkpointsAmount, Race.Config.checkpointsCoords, Race.Config.startpointsCoords, Race.Config.startpointsHeading
        
        TriggerServerEvent('ybn_racesystem:startrace', password, maxplayers, checkpointsAmount, checkpointsCoords, startpointsCoords, startpointsHeading)

        builder.rendering = false

        Wait(250)

        builder.resetConfig()
    end)

    buttonStartRace:setIcon("fa-solid fa-play")
    menu:add(buttonStartRace)
    -- Open and close stuff

    menu:open()
    menu:onClose(function ()
        builder.rendering = false
        builder.resetConfig()
    end)
end

builder.render = function ()
        for k, v in ipairs(Race.Config.checkpointsCoords) do
            DrawMarker(1, v.x, v.y, v.z - 1, 0, 0, 0, 0, 0, 0, 2.0, 2.0, 5.0, 255, 0, 0, 100, false, true, 2, false, false, false, false)
        end

        for k, v in ipairs(Race.Config.startpointsCoords) do
            DrawMarker(1, v.x, v.y, v.z - 1, 0, 0, 0, 0, 0, 0, 2.0, 2.0, 5.0, 0, 255, 0, 100, false, true, 2, false, false, false, false)
        end
end

CreateThread(function ()

    while true do
        local sleep = 3000
        if builder.rendering then
            sleep = 0
            builder.render()
        end
        Wait(sleep)
    end

end)

RegisterCommand('cc', function (args, _)

    builder.mainMenu()

end)
