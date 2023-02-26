------------------------------------------
-------- JUST CUT IT OFF --------
------------------------------------------
------------ CLIENT COMMANDS -------------

local ServerCommands = {}

ServerCommands.ResponseCanAct = function(arg)


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



ServerCommands.CanCutLimb = function(arg)
    local part_name = arg["toSend"]

    arg["To"] = arg["From"]
    arg["From"] = getPlayer():getOnlineID()
    arg["command"] = "ResponseCanAct"
    arg["toSend"] = { part_name, "Cut", CheckIfCanBeCut(part_name) }
    sendClientCommand("TOC", "SendServer", arg)
end

ServerCommands.CutLimb = function(arg)
    local data = arg["toSend"]

    local partName = data[1]
    local surgeonFactor = data[2]
    local bandageTable = data[3]
    local painkillerTable = data[4]


    JCIO.CutLimb(partName, surgeonFactor, bandageTable, painkillerTable)
end



ServerCommands.CanOperateLimb = function(arg)
    local part_name = arg["toSend"]

    arg["To"] = arg["From"]
    arg["From"] = getPlayer():getOnlineID()
    arg["command"] = "ResponseCanAct"
    arg["toSend"] = { part_name, "Operate", CheckIfCanBeOperated(part_name) }
    sendClientCommand("TOC", "SendServer", arg)
end
ServerCommands.OperateLimb = function(arg)

    local data = arg["toSend"]
    TocOperateLimb(data[1], data[2], data[3])
end


ServerCommands.CanEquipProsthesis = function(arg)
    local part_name = arg["toSend"]
    --local item = arg["toSend"][2]     -- TODO Add item prosth here

    arg["To"] = arg["From"]
    arg["From"] = getPlayer():getOnlineID()
    arg["command"] = "ResponseCanAct"
    arg["toSend"] = {part_name, "Equip", CheckIfProsthesisCanBeEquipped(part_name) }
    sendClientCommand("TOC", "SendServer", arg)

end
ServerCommands.EquipProsthesis = function(arg)

    -- part_name = arg[1]
    -- prosthesis_item = arg[2]
    -- prosthesis_name = arg[3]
    
    local data = arg["toSend"]
    TocEquipProsthesis(data[1], data[2], data[3])

end


ServerCommands.CanUnequipProsthesis = function(arg)
    local part_name = arg["toSend"]
    arg["To"] = arg["From"]
    arg["From"] = getPlayer():getOnlineID()
    arg["command"] = "ResponseCanAct"
    arg["toSend"] = { part_name, "Unequip", CheckIfProsthesisCanBeUnequipped(part_name)}
    sendClientCommand("TOC", "SendServer", arg)
end
ServerCommands.UnequipProsthesis = function(arg)

    -- part_name = arg[1]

    local data = arg["toSend"]
    TheOnlyCure.TocUnequipProsthesis(data[1], data[2])

end



ServerCommands.CanResetEverything = function(arg)
    local part_name = "RightHand" --useless

    arg["To"] = arg["From"]
    arg["From"] = getPlayer():getOnlineID()
    arg["command"] = "ResponseCanAct"
    arg["toSend"] = { part_name, "Cut", true }
    sendClientCommand("TOC", "SendServer", arg)
end
ServerCommands.ResetEverything = function(_)
    TocResetEverything()
end


-- Used when amputating the limb of another player
ServerCommands.AcceptDamageOtherPlayer = function(arg)
    local patient = getPlayerByOnlineID(arg[1])
    local part_name = arg[2]
    TocDamagePlayerDuringAmputation(patient, part_name)
end

-- Used to propagate animation changes after amputating a foot
ServerCommands.SetCrawlAnimation = function(args)

    local player = getPlayerByOnlineID(args.id)
    local check = args.check

    player:setVariable('IsCrawling', tostring(check))

end

-- Used to propagate the stop of the sound of amputation
ServerCommands.StopAmputationSound = function(args)

    local player = getPlayerByOnlineID(args.surgeon_id)
    player:getEmitter():stopSoundByName("Amputation_Sound")

end



local function OnTocServerCommand(module, command, args)
    if module == 'TOC' then
        print("TOC: On Toc Server Command " .. command)
        if ServerCommands[command] then
            print("Found command, executing it now")
            args = args or {}
            ServerCommands[command](args)

        end
    end
end

Events.OnServerCommand.Add(OnTocServerCommand)


---------------------------------- Global Mod Data -----------------------------


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


--------------------------------------------------------


function SendCutLimb(player, part_name, surgeon_factor, bandage_table, painkiller_table)
    local arg = {}
    arg["From"] = getPlayer():getOnlineID()
    arg["To"] = player:getOnlineID()
    arg["command"] = "CutLimb"


    -- TODO Hotfix for sound, fix this later
    arg["toSend"] = {part_name, surgeon_factor, bandage_table, painkiller_table}



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

function SendEquipProsthesis(player, part_name, item, prosthesis_base_name)
    local arg = {}
    arg["From"] = getPlayer():getOnlineID()
    arg["To"] = player:getOnlineID()
    arg["command"] = "EquipProsthesis"
    arg["toSend"] = { part_name, item, prosthesis_base_name}
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
