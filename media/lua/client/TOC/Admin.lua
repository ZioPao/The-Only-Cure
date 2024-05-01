local CommandsData = require("TOC/CommandsData")
-------------------

---@param playerNum number
---@param context ISContextMenu
---@param worldobjects table
local function AddAdminTocOptions(playerNum, context, worldobjects)
    if not isAdmin() then return end

    local players = {}
    for _, v in ipairs(worldobjects) do
        for x = v:getSquare():getX() - 1, v:getSquare():getX() + 1 do
            for y = v:getSquare():getY() - 1, v:getSquare():getY() + 1 do
                local sq = getCell():getGridSquare(x, y, v:getSquare():getZ());
                if sq then
                    for z = 0, sq:getMovingObjects():size() - 1 do
                        local o = sq:getMovingObjects():get(z)
                        if instanceof(o, "IsoPlayer") then
                            ---@cast o IsoPlayer

                            local oId = o:getOnlineID()
                            players[oId] = o
                        end
                    end
                end
            end
        end
    end


    for _, pl in pairs(players) do
        ---@cast pl IsoPlayer

        local clickedPlayerNum = pl:getOnlineID()

        local option = context:addOption(getText("ContextMenu_Admin_TOC") .. " - " .. pl:getUsername(), nil, nil)
        local subMenu = ISContextMenu:getNew(context)
        context:addSubMenu(option, subMenu)

        subMenu:addOption(getText("ContextMenu_Admin_ResetTOC"), nil, function()
            sendClientCommand(CommandsData.modules.TOC_RELAY, CommandsData.server.Relay.RelayExecuteInitialization,
                { patientNum = clickedPlayerNum })
        end)
    end
end
Events.OnFillWorldObjectContextMenu.Add(AddAdminTocOptions)


--* Override to cheats to fix stuff

local og_ISHealthPanel_onCheatCurrentPlayer = ISHealthPanel.onCheatCurrentPlayer

function ISHealthPanel.onCheatCurrentPlayer(bodyPart, action, player)
    og_ISHealthPanel_onCheatCurrentPlayer(bodyPart, action, player)

    if action == "healthFullBody" then
        -- todo loop all limbs and reset them if infected
    end

    if action == "healthFull" then
        -- todo get limbname from bodypart
    end
end