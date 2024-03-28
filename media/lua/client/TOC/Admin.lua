
local CommandsData = require("TOC/CommandsData")

---@param playerNum number
---@param context ISContextMenu
---@param items any
local function AddAdminTocOptions(playerNum, context, items)
    if not isAdmin() then return end

    -- This is a global var already handled in vanilla zomboid, we don't need to find the player once again
    ---@cast clickedPlayer IsoPlayer
    if clickedPlayer then

        local clickedPlayerNum = clickedPlayer:getOnlineID()

        local option = context:addOption(getText("ContextMenu_Admin_TOC"), items, nil)
        local subMenu = ISContextMenu:getNew(context)
        context:addSubMenu(option, subMenu)

        subMenu:addOption(getText("ContextMenu_Admin_ResetTOC"), items, function()
            sendClientCommand(CommandsData.modules.TOC_RELAY, CommandsData.server.Relay.RelayExecuteInitialization, {patientNum=clickedPlayerNum} )
        end)

        -- TODO add other options

    end



end
Events.OnFillWorldObjectContextMenu.Add(AddAdminTocOptions)