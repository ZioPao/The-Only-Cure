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
    ui.responseActionIsBitten = getPlayerByOnlineID(arg["From"]):getBodyDamage():getBodyPart(TocGetBodyPartFromPartName(ui
        .responsePartName)):bitten()
end


function SendCutLimb(player, part_name, surgeon_factor, bandage_table, painkiller_table)
    local arg = {}
    arg["From"] = getPlayer():getOnlineID()
    arg["To"] = player:getOnlineID()
    arg["command"] = "CutLimb"


    -- TODO Hotfix for sound, fix this later
    arg["toSend"] = {part_name, surgeon_factor, bandage_table, painkiller_table, getPlayer():getOnlineID()}



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

function SendUnequipProsthesis(player, part_name, item)
    local arg = {}
    arg["From"] = getPlayer():getOnlineID()
    arg["To"] = player:getOnlineID()
    arg["command"] = "UnequipProsthesis"
    arg["toSend"] = { player, part_name, item}
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
    arg["toSend"] = part_name               -- TODO to be more precise there should be prosthesis item here too to check

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
    local surgeon_id = arg[5]
    
    getPlayerByOnlineID(surgeon_id):getEmitter():stopSoundByName("Amputation_Sound")



    TocCutLimb(arg[1], arg[2], arg[3], arg[4])
end

Commands["OperateLimb"] = function(arg)
    local arg = arg["toSend"]
    TocOperateLimb(arg[1], arg[2], arg[3])
end


Commands["EquipProsthesis"] = function(arg)

    -- part_name = arg[1]
    -- prosthesis = arg[2]

    local arg = arg["toSend"]

    TocEquipProsthesis(arg[1], arg[2])

end

Commands["UnequipProsthesis"] = function(arg)

    -- part_name = arg[1]

    local arg = arg["toSend"]

    TheOnlyCure.UnequipProsthesis(arg[1], arg[2])

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
    --local item = arg["toSend"][2]     -- TODO Add item prosth here

    arg["To"] = arg["From"]
    arg["From"] = getPlayer():getOnlineID()
    arg["command"] = "ResponseCanAct"
    arg["toSend"] = {part_name, "Equip", CheckIfProsthesisCanBeEquipped(part_name) }
    sendClientCommand("TOC", "SendServer", arg)

end

Commands["CanUnequipProsthesis"] = function(arg)
    local part_name = arg["toSend"]
    arg["To"] = arg["From"]
    arg["From"] = getPlayer():getOnlineID()
    arg["command"] = "ResponseCanAct"
    arg["toSend"] = { part_name, "Unequip", CheckIfProsthesisCanBeUnequipped(part_name)}
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




-- Cut Limb stuff
Commands["AcceptDamageOtherPlayer"] = function(arg)

    local patient_id = arg[1]
    local patient = getPlayerByOnlineID(arg[1])
    local part_name = arg[2]
    TocDamagePlayerDuringAmputation(patient, part_name)
end


-- Hotfix for sounds
Commands.StopAmputationSound = function(args)

    local player = getPlayerByOnlineID(args.surgeon_id)
    player:getEmitter():stopSoundByName("Amputation_Sound")

end


-- Base stuff
local function OnTocServerCommand(module, command, args)
    if module == 'TOC' then
        print("TOC: On Toc Server Command " .. command)
        if Commands[command] then
            print("Found command, executing it now")
            args = args or {}
            Commands[command](args)

        end
    end
end

Events.OnServerCommand.Add(OnTocServerCommand)







---------------------------------- TEST -----------------------------


function TOC_OnReceiveGlobalModData(key, modData)
    if modData then
        ModData.remove(key)
        ModData.add(key, modData)
    end
end


Events.OnReceiveGlobalModData.Add(TOC_OnReceiveGlobalModData)

function TOC_OnConnected()
    ModData.request("TOC_PLAYER_DATA")
end


Events.OnConnected.Add(TOC_OnConnected)

