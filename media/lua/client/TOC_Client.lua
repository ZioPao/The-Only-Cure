-- Synchronization and MP related stuff

local Commands = {}

Commands["ResponseCanAct"] = function(arg)


    print("TOC: ResponseCanAct")
    local ui = GetConfirmUIMP()
    ui.responseReceive = true
    ui.responseAction = arg["toSend"][2]
    ui.responsePartName = arg["toSend"][1]
    ui.responseCan = arg["toSend"][3]
    ui.responseUserName = getPlayerByOnlineID(arg["From"]):getUsername()
    ui.responseActionIsBitten = getPlayerByOnlineID(arg["From"]):getBodyDamage():getBodyPart(TocGetBodyPartTypeFromPartName(ui
        .responsePartName)):bitten()
end


function SendCutLimb(player, part_name, surgeon_factor, bandage_table, painkiller_table)
    local arg = {}
    arg["From"] = getPlayer():getOnlineID()
    arg["To"] = player:getOnlineID()
    arg["command"] = "CutLimb"
    arg["toSend"] = { part_name, surgeon_factor, bandage_table, painkiller_table }
    sendClientCommand("TOC", "SendServer", arg)
end

function SendOperateLimb(player, part_name, surgeon_factor, use_oven)
    local arg = {}
    arg["From"] = getPlayer():getOnlineID()
    arg["To"] = player:getOnlineID()
    arg["command"] = "OperateLimb"
    arg["toSend"] = { part_name, surgeon_factor, use_oven }
    sendClientCommand("TOC", "SendServer", arg)
end

function SendEquipProsthesis(player, part_name, prosthesis_base_name)
    local arg = {}
    arg["From"] = getPlayer():getOnlineID()
    arg["To"] = player:getOnlineID()
    arg["command"] = "EquipProsthesis"
    arg["toSend"] = { part_name, prosthesis_base_name}
    sendClientCommand("TOC", "SendServer", arg)
end

function SendUnequipProsthesis(player, part_name, equipped_prosthesis)
    local arg = {}
    arg["From"] = getPlayer():getOnlineID()
    arg["To"] = player:getOnlineID()
    arg["command"] = "UnequipProsthesis"
    arg["toSend"] = { part_name, equipped_prosthesis}
    sendClientCommand("TOC", "SendServer", arg)
end

function AskCanCutLimb(player, part_name)
    GetConfirmUIMP().responseReceive = false
    local arg = {}
    arg["From"] = getPlayer():getOnlineID()
    arg["To"] = player:getOnlineID()
    arg["command"] = "CanCutLimb"
    arg["toSend"] = part_name
    sendClientCommand("TOC", "SendServer", arg)
end

function AskCanOperateLimb(player, part_name)
    GetConfirmUIMP().responseReceive = false
    local arg = {}
    arg["From"] = getPlayer():getOnlineID()
    arg["To"] = player:getOnlineID()
    arg["command"] = "CanOperateLimb"
    arg["toSend"] = part_name
    sendClientCommand("TOC", "SendServer", arg)
end

function AskCanEquipProsthesis(player, part_name)
    GetConfirmUIMP().responseReceive = false
    local arg = {}
    arg["From"] = getPlayer():getOnlineID()
    arg["To"] = player:getOnlineID()
    arg["command"] = "CanEquipProsthesis"
    arg["toSend"] = part_name

    sendClientCommand("TOC", "SendServer", arg)
end


function AskCanUnequipProsthesis(player, part_name)
    GetConfirmUIMP().responseReceive = false
    local arg = {}
    arg["From"] = getPlayer():getOnlineID()
    arg["To"] = player:getOnlineID()
    arg["command"] = "CanUnequipProsthesis"
    arg["toSend"] = part_name

    sendClientCommand("TOC", "SendServer", arg)
end


-- Patient (receive)
Commands["CutLimb"] = function(arg)
    local arg = arg["toSend"]
    TheOnlyCure.CutLimb(arg[1], arg[2], arg[3], arg[4])
end

Commands["OperateLimb"] = function(arg)
    local arg = arg["toSend"]
    TheOnlyCure.OperateLimb(arg[1], arg[2], arg[3])
end


Commands["EquipProsthesis"] = function(arg)

    -- part_name = arg[1]
    -- prosthesis = arg[2]

    local arg = arg["toSend"]

    TheOnlyCure.EquipProsthesis(arg[1], arg[2])

end

Commands["UnequipProsthesis"] = function(arg)

    -- part_name = arg[1]

    local arg = arg["toSend"]

    TheOnlyCure.UnequipProsthesis(arg[1])

end

Commands["CanCutLimb"] = function(arg)
    local part_name = arg["toSend"]

    arg["To"] = arg["From"]
    arg["From"] = getPlayer():getOnlineID()
    arg["command"] = "ResponseCanAct"
    arg["toSend"] = { part_name, "Cut", CheckIfCanBeCut(part_name) }
    sendClientCommand("TOC", "SendServer", arg)
end

Commands["CanOperateLimb"] = function(arg)
    local part_name = arg["toSend"]

    arg["To"] = arg["From"]
    arg["From"] = getPlayer():getOnlineID()
    arg["command"] = "ResponseCanAct"
    arg["toSend"] = { part_name, "Operate", CheckIfCanBeOperated(part_name) }
    sendClientCommand("TOC", "SendServer", arg)
end

Commands["CanEquipProsthesis"] = function(arg)
    local part_name = arg["toSend"]
    arg["To"] = arg["From"]
    arg["From"] = getPlayer():getOnlineID()
    arg["command"] = "ResponseCanAct"
    arg["toSend"] = { part_name, "Equip", true }        -- FIXME true just for test
    sendClientCommand("TOC", "SendServer", arg)

end

Commands["CanUnequipProsthesis"] = function(arg)
    local part_name = arg["toSend"]
    arg["To"] = arg["From"]
    arg["From"] = getPlayer():getOnlineID()
    arg["command"] = "ResponseCanAct"
    arg["toSend"] = { part_name, "Unequip", true }        -- FIXME true just for test
    sendClientCommand("TOC", "SendServer", arg)

end

Commands["CanResetEverything"] = function(arg)
    local part_name = "RightHand" --useless

    arg["To"] = arg["From"]
    arg["From"] = getPlayer():getOnlineID()
    arg["command"] = "ResponseCanAct"
    arg["toSend"] = { part_name, "Cut", true }
    sendClientCommand("TOC", "SendServer", arg)
end

Commands["ResetEverything"] = function(arg)
    local arg = arg["toSend"]
    TocResetEverything()
end

-- Cheating stuff
Commands["AcceptResetEverything"] = function(arg)

    local clicked_player = getPlayerByOnlineID(arg[1]) -- TODO delete this
    TocResetEverything()
end


-- Base stuff
Commands["GivePlayerData"] = function(arg)
    local surgeon_id = arg[1]
    local patient = getPlayerByOnlineID(arg[2])
    local toc_data = patient:getModData().TOC
    sendClientCommand(patient, "TOC", "SendPlayerData", { surgeon_id, toc_data })
end

Commands["SendTocData"] = function(arg)
    print("Sending TOC data")
    local patient = getPlayerByOnlineID(arg[1])

    MP_other_player_toc_data = arg[2]

end








local function OnTocServerCommand(module, command, args)
    if module == 'TOC' then
        print("OnTocServerCommand " .. command)
        if Commands[command] then
            print("Found command, executing it now")
            args = args or {}
            Commands[command](args)

        end
    end
end

Events.OnServerCommand.Add(OnTocServerCommand)
