------------------------------------------
------------- JUST CUT IT OFF ------------
------------------------------------------
------------- SERVER COMMANDS ------------

local ServerCommands = {}

ServerCommands.ResponseCanAct = function(arg)


    print("JCIO: ResponseCanAct")
    local ui = GetConfirmUIMP()
    ui.responseReceive = true
    ui.responseAction = arg["toSend"][2]
    ui.responsePartName = arg["toSend"][1]
    ui.responseCan = arg["toSend"][3]
    ui.responseUserName = getPlayerByOnlineID(arg["From"]):getUsername()
    ui.responseActionIsBitten = getPlayerByOnlineID(arg["From"]):getBodyDamage():getBodyPart(JCIO_Common.GetBodyPartFromPartName(ui
        .responsePartName)):bitten()
end



ServerCommands.CanCutLimb = function(arg)
    local part_name = arg["toSend"]

    arg["To"] = arg["From"]
    arg["From"] = getPlayer():getOnlineID()
    arg["command"] = "ResponseCanAct"
    arg["toSend"] = { part_name, "Cut", JCIO_Common.CheckIfCanBeCut(part_name) }
    sendClientCommand("JCIO", "SendServer", arg)
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
    arg["toSend"] = { part_name, "Operate", JCIO_Common.CheckIfCanBeOperated(part_name) }
    sendClientCommand("JCIO", "SendServer", arg)
end
ServerCommands.OperateLimb = function(arg)

    local data = arg["toSend"]

    local partName = data[1]
    local surgeonFactor = data[2]
    local useOven = data[3]

    JCIO.OperateLimb(partName, surgeonFactor, useOven)
end


ServerCommands.CanEquipProsthesis = function(arg)
    local part_name = arg["toSend"]
    --local item = arg["toSend"][2]     -- TODO Add item prosth here

    arg["To"] = arg["From"]
    arg["From"] = getPlayer():getOnlineID()
    arg["command"] = "ResponseCanAct"
    arg["toSend"] = {part_name, "Equip", JCIO_Common.CheckIfProsthesisCanBeEquipped(part_name) }
    sendClientCommand("JCIO", "SendServer", arg)

end
ServerCommands.EquipProsthesis = function(arg)

    -- part_name = arg[1]
    -- prosthesis_item = arg[2]
    -- prosthesis_name = arg[3]
    
    local data = arg["toSend"]

    local partName = data[1]
    local prosthesisItem = data[2]
    
    JCIO.EquipProsthesis(partName, prosthesisItem, _)       -- TODO Add the third param

end


ServerCommands.CanUnequipProsthesis = function(arg)
    local part_name = arg["toSend"]
    arg["To"] = arg["From"]
    arg["From"] = getPlayer():getOnlineID()
    arg["command"] = "ResponseCanAct"
    arg["toSend"] = { part_name, "Unequip", JCIO_Common.CheckIfProsthesisCanBeUnequipped(part_name)}
    sendClientCommand("JCIO", "SendServer", arg)
end
ServerCommands.UnequipProsthesis = function(arg)
    local data = arg["toSend"]

    local patient = data[1]
    local partName = data[2]
    local equippedProsthesis = data[3]

    JCIO.UnequipProsthesis(patient, partName, equippedProsthesis)

end


ServerCommands.CanResetEverything = function(arg)
    local part_name = "RightHand" --useless

    arg["To"] = arg["From"]
    arg["From"] = getPlayer():getOnlineID()
    arg["command"] = "ResponseCanAct"
    arg["toSend"] = { part_name, "Cut", true }
    sendClientCommand("JCIO", "SendServer", arg)
end
ServerCommands.ResetEverything = function(_)
    JCIO_Cheat.ResetEverything()
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



local function OnServerCommand(module, command, args)
    if module == 'JCIO' then
        print("JCIO: On JCIO Server Command " .. command)
        if ServerCommands[command] then
            print("Found command, executing it now")
            args = args or {}
            ServerCommands[command](args)

        end
    end
end

Events.OnServerCommand.Add(OnServerCommand)


---------------------------------- Global Mod Data -----------------------------


local function OnReceiveGlobalModData(key, modData)
    if modData then
        ModData.remove(key)
        ModData.add(key, modData)
    end
end


Events.OnReceiveGlobalModData.Add(OnReceiveGlobalModData)

local function OnConnected()
    ModData.request("JCIO_PLAYER_DATA")
end


Events.OnConnected.Add(OnConnected)


--------------------------------------------------------


function SendCutLimb(player, part_name, surgeon_factor, bandage_table, painkiller_table)
    local arg = {}
    arg["From"] = getPlayer():getOnlineID()
    arg["To"] = player:getOnlineID()
    arg["command"] = "CutLimb"


    -- TODO Hotfix for sound, fix this later
    arg["toSend"] = {part_name, surgeon_factor, bandage_table, painkiller_table}



    sendClientCommand("JCIO", "SendServer", arg)
end

function SendOperateLimb(player, part_name, surgeon_factor, use_oven)
    local arg = {}
    arg["From"] = getPlayer():getOnlineID()
    arg["To"] = player:getOnlineID()
    arg["command"] = "OperateLimb"
    arg["toSend"] = { part_name, surgeon_factor, use_oven }
    sendClientCommand("JCIO", "SendServer", arg)
end

function SendEquipProsthesis(player, part_name, item, prosthesis_base_name)
    local arg = {}
    arg["From"] = getPlayer():getOnlineID()
    arg["To"] = player:getOnlineID()
    arg["command"] = "EquipProsthesis"
    arg["toSend"] = { part_name, item, prosthesis_base_name}
    sendClientCommand("JCIO", "SendServer", arg)
end

function SendUnequipProsthesis(player, part_name, item)
    local arg = {}
    arg["From"] = getPlayer():getOnlineID()
    arg["To"] = player:getOnlineID()
    arg["command"] = "UnequipProsthesis"
    arg["toSend"] = { player, part_name, item}
    sendClientCommand("JCIO", "SendServer", arg)
end

function AskCanCutLimb(player, part_name)
    GetConfirmUIMP().responseReceive = false
    local arg = {}
    arg["From"] = getPlayer():getOnlineID()
    arg["To"] = player:getOnlineID()
    arg["command"] = "CanCutLimb"
    arg["toSend"] = part_name
    sendClientCommand("JCIO", "SendServer", arg)
end

function AskCanOperateLimb(player, part_name)
    GetConfirmUIMP().responseReceive = false
    local arg = {}
    arg["From"] = getPlayer():getOnlineID()
    arg["To"] = player:getOnlineID()
    arg["command"] = "CanOperateLimb"
    arg["toSend"] = part_name
    sendClientCommand("JCIO", "SendServer", arg)
end

function AskCanEquipProsthesis(player, part_name)
    GetConfirmUIMP().responseReceive = false
    local arg = {}
    arg["From"] = getPlayer():getOnlineID()
    arg["To"] = player:getOnlineID()
    arg["command"] = "CanEquipProsthesis"
    arg["toSend"] = part_name               -- TODO to be more precise there should be prosthesis item here too to check

    sendClientCommand("JCIO", "SendServer", arg)
end

function AskCanUnequipProsthesis(player, part_name)
    GetConfirmUIMP().responseReceive = false
    local arg = {}
    arg["From"] = getPlayer():getOnlineID()
    arg["To"] = player:getOnlineID()
    arg["command"] = "CanUnequipProsthesis"
    arg["toSend"] = part_name

    sendClientCommand("JCIO", "SendServer", arg)
end
