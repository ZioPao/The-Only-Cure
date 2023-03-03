------------------------------------------
-------------- THE ONLY CURE -------------
------------------------------------------
------------- SERVER COMMANDS ------------

local ServerCommands = {}

ServerCommands.ResponseCanAct = function(arg)


    print("TOC: ResponseCanAct")
    local ui = GetConfirmUIMP()
    ui.responseReceive = true
    ui.responseAction = arg["toSend"][2]
    ui.responsePartName = arg["toSend"][1]
    ui.responseCan = arg["toSend"][3]
    ui.responseUserName = getPlayerByOnlineID(arg["From"]):getUsername()
    ui.responseActionIsBitten = getPlayerByOnlineID(arg["From"]):getBodyDamage():getBodyPart(TOC_Common.GetBodyPartFromPartName(ui
        .responsePartName)):bitten()
end



ServerCommands.CanCutLimb = function(arg)
    local partName = arg["toSend"]

    arg["To"] = arg["From"]
    arg["From"] = getPlayer():getOnlineID()
    arg["command"] = "ResponseCanAct"
    arg["toSend"] = { partName, "Cut", TOC_Common.CheckIfCanBeCut(partName) }
    sendClientCommand("TOC", "SendServer", arg)
end
ServerCommands.CutLimb = function(arg)
    local data = arg["toSend"]

    local partName = data[1]
    local surgeonFactor = data[2]
    local bandageTable = data[3]
    local painkillerTable = data[4]


    TOC.CutLimb(partName, surgeonFactor, bandageTable, painkillerTable)
end


ServerCommands.CanOperateLimb = function(arg)
    local partName = arg["toSend"]

    arg["To"] = arg["From"]
    arg["From"] = getPlayer():getOnlineID()
    arg["command"] = "ResponseCanAct"
    arg["toSend"] = { partName, "Operate", TOC_Common.CheckIfCanBeOperated(partName) }
    sendClientCommand("TOC", "SendServer", arg)
end
ServerCommands.OperateLimb = function(arg)

    local data = arg["toSend"]

    local partName = data[1]
    local surgeonFactor = data[2]
    local useOven = data[3]

    TOC.OperateLimb(partName, surgeonFactor, useOven)
end


ServerCommands.CanEquipProsthesis = function(arg)
    local partName = arg["toSend"]
    --local item = arg["toSend"][2]     -- TODO Add item prosth here

    arg["To"] = arg["From"]
    arg["From"] = getPlayer():getOnlineID()
    arg["command"] = "ResponseCanAct"
    arg["toSend"] = {partName, "Equip", TOC_Common.CheckIfProsthesisCanBeEquipped(partName) }
    sendClientCommand("TOC", "SendServer", arg)

end
ServerCommands.EquipProsthesis = function(arg)

    -- part_name = arg[1]
    -- prosthesis_item = arg[2]
    -- prosthesis_name = arg[3]
    
    local data = arg["toSend"]

    local partName = data[1]
    local prosthesisItem = data[2]
    
    TOC.EquipProsthesis(partName, prosthesisItem, _)       -- TODO Add the third param when modular prost are done

end


ServerCommands.CanUnequipProsthesis = function(arg)
    local partName = arg["toSend"]
    arg["To"] = arg["From"]
    arg["From"] = getPlayer():getOnlineID()
    arg["command"] = "ResponseCanAct"
    arg["toSend"] = { partName, "Unequip", TOC_Common.CheckIfProsthesisCanBeUnequipped(partName)}
    sendClientCommand("TOC", "SendServer", arg)
end
ServerCommands.UnequipProsthesis = function(arg)
    local data = arg["toSend"]

    local patient = data[1]
    local partName = data[2]
    local equippedProsthesis = data[3]

    TOC.UnequipProsthesis(patient, partName, equippedProsthesis)

end


ServerCommands.CanResetEverything = function(arg)
    local partName = "RightHand" --useless

    arg["To"] = arg["From"]
    arg["From"] = getPlayer():getOnlineID()
    arg["command"] = "ResponseCanAct"
    arg["toSend"] = { partName, "Cut", true }
    sendClientCommand("TOC", "SendServer", arg)
end
ServerCommands.ResetEverything = function(_)
    TOC_Cheat.ResetEverything()
end


-- Used when amputating the limb of another player
ServerCommands.AcceptDamageOtherPlayer = function(arg)
    local patient = getPlayerByOnlineID(arg[1])
    local partName = arg[2]
    TOC.DamagePlayerDuringAmputation(patient, partName)
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
    if module == 'TOC' then
        print("TOC: On TOC Server Command " .. command)
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
    ModData.request("TOC_PLAYER_DATA")
end


Events.OnConnected.Add(OnConnected)


--------------------------------------------------------


function SendCutLimb(player, partName, surgeonFactor, bandageTable, painkillerTable)
    local arg = {}
    arg["From"] = getPlayer():getOnlineID()
    arg["To"] = player:getOnlineID()
    arg["command"] = "CutLimb"


    -- TODO Hotfix for sound, fix this later
    arg["toSend"] = {partName, surgeonFactor, bandageTable, painkillerTable}
    sendClientCommand("TOC", "SendServer", arg)
end

function SendOperateLimb(player, partName, surgeonFactor, useOven)
    local arg = {}
    arg["From"] = getPlayer():getOnlineID()
    arg["To"] = player:getOnlineID()
    arg["command"] = "OperateLimb"
    arg["toSend"] = { partName, surgeonFactor, useOven }
    sendClientCommand("TOC", "SendServer", arg)
end

function SendEquipProsthesis(player, partName, item, prosthesisBaseName)
    local arg = {}
    arg["From"] = getPlayer():getOnlineID()
    arg["To"] = player:getOnlineID()
    arg["command"] = "EquipProsthesis"
    arg["toSend"] = { partName, item, prosthesisBaseName}
    sendClientCommand("TOC", "SendServer", arg)
end

function SendUnequipProsthesis(player, partName, item)
    local arg = {}
    arg["From"] = getPlayer():getOnlineID()
    arg["To"] = player:getOnlineID()
    arg["command"] = "UnequipProsthesis"
    arg["toSend"] = { player, partName, item}
    sendClientCommand("TOC", "SendServer", arg)
end

function AskCanCutLimb(player, partName)
    GetConfirmUIMP().responseReceive = false
    local arg = {}
    arg["From"] = getPlayer():getOnlineID()
    arg["To"] = player:getOnlineID()
    arg["command"] = "CanCutLimb"
    arg["toSend"] = partName
    sendClientCommand("TOC", "SendServer", arg)
end

function AskCanOperateLimb(player, partName)
    GetConfirmUIMP().responseReceive = false
    local arg = {}
    arg["From"] = getPlayer():getOnlineID()
    arg["To"] = player:getOnlineID()
    arg["command"] = "CanOperateLimb"
    arg["toSend"] = partName
    sendClientCommand("TOC", "SendServer", arg)
end

function AskCanEquipProsthesis(player, partName)
    GetConfirmUIMP().responseReceive = false
    local arg = {}
    arg["From"] = getPlayer():getOnlineID()
    arg["To"] = player:getOnlineID()
    arg["command"] = "CanEquipProsthesis"
    arg["toSend"] = partName               -- TODO to be more precise there should be prosthesis item here too to check

    sendClientCommand("TOC", "SendServer", arg)
end

function AskCanUnequipProsthesis(player, partName)
    GetConfirmUIMP().responseReceive = false
    local arg = {}
    arg["From"] = getPlayer():getOnlineID()
    arg["To"] = player:getOnlineID()
    arg["command"] = "CanUnequipProsthesis"
    arg["toSend"] = partName

    sendClientCommand("TOC", "SendServer", arg)
end
