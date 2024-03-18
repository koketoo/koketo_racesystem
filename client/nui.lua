local nui = {
    show = function ()

            SendNUIMessage({
                type = "toggle",
                newState = "show"
            }) 
    end,
    hide = function ()
        SendNUIMessage({
            type = "toggle",
            newState = "hide"
        })
    end,
    updateData = function (checkpointsAmount, checkpointsReached)
        SendNUIMessage({
            type = "newData",
            checkpointsAmount = checkpointsAmount,
            checkpointsReached = checkpointsReached
        })
    end,
    showvictory = function (winnerName)
        SendNUIMessage({
            type = "showvictory",
            winnerName = winnerName,

        })
    end,
    hidevictory = function ()
        SendNUIMessage({
            type = "hidevictory",
        })
    end,
    showPlayersFeed = function (maxplayers, joinedPlayers)
        SendNUIMessage({
            type = "playersfeed",
            maxplayers = maxplayers,
            playersJoined = joinedPlayers
        })
    end,
    hidePlayersFeed = function ()
        SendNUIMessage({
            type = "playersfeedHide"
        })
    end
}

GetNui = function ()
    return nui
end
