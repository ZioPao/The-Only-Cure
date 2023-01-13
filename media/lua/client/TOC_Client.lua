-- Synchronization and MP related stuff

local Commands = {}

Commands["ResponseCanAct"] = function(arg)
    local ui = GetConfirmUIMP()
    ui.responseReceive = true
    ui.responseAction = arg["toSend"][2]
    ui.responsePartName = arg["toSend"][1]
    ui.responseCan = arg["toSend"][3]
    ui.responseUserName = getPlayerByOnlineID(arg["From"]):getUsername()
    ui.responseActionIsBitten = getPlayerByOnlineID(arg["From"]):getBodyDamage():getBodyPart(TOC_getBodyPart(ui.responsePartName)):bitten()
end


function SendCutLimb(player, part_name, surgeon_factor, bandage_table, painkiller_table)
    local arg = {}
    arg["From"] = getPlayer():getOnlineID()
    arg["To"] = player:getOnlineID()
    arg["command"] = "CutLimb"
    arg["toSend"] = {part_name, surgeon_factor, bandage_table, painkiller_table}
    sendClientCommand("TOC", "SendServer", arg)
end

function SendOperateLimb(player, part_name, surgeon_factor, use_oven)
    local arg = {}
    arg["From"] = getPlayer():getOnlineID()
    arg["To"] = player:getOnlineID()
    arg["command"] = "OperateLimb"
    arg["toSend"] = {part_name, surgeon_factor, use_oven}
    sendClientCommand("TOC", "SendServer", arg)
end

function AskCanCutLimb(player, part_name)
    GetConfirmUIMP().responseReceive = false;
    local arg = {};
    arg["From"] = getPlayer():getOnlineID();
    arg["To"] = player:getOnlineID();
    arg["command"] = "CanCutLimb";
    arg["toSend"] = part_name;
    sendClientCommand("TOC", "SendServer", arg);
end

function AskCanOperateLimb(player, part_name)
    GetConfirmUIMP().responseReceive = false;
    local arg = {};
    arg["From"] = getPlayer():getOnlineID();
    arg["To"] = player:getOnlineID();
    arg["command"] = "CanOperateLimb";
    arg["toSend"] = part_name;
    sendClientCommand("TOC", "SendServer", arg);
end


function AskCanResetEverything(_, other_player)
    GetConfirmUIMP().responseReceive = false;
    local arg = {}
    arg["From"] = getPlayer():getOnlineID()
    arg["To"] = other_player:getOnlineID()
    arg["command"] = "CanResetEverything"
    arg["toSend"] = {}
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

Commands["CanCutLimb"] = function(arg)
    local part_name = arg["toSend"]
    
    arg["To"] = arg["From"]
    arg["From"] = getPlayer():getOnlineID()
    arg["command"] = "ResponseCanAct"
    arg["toSend"] = {part_name, "Cut", CanBeCut(part_name)}
    sendClientCommand("TOC", "SendServer", arg)
end

Commands["CanOperateLimb"] = function(arg)
    local part_name = arg["toSend"]

    arg["To"] = arg["From"]
    arg["From"] = getPlayer():getOnlineID()
    arg["command"] = "ResponseCanAct"
    arg["toSend"] = {part_name, "Operate", CanBeOperate(part_name)}
    sendClientCommand("TOC", "SendServer", arg)
end

Commands["CanResetEverything"] = function(arg)
    local arg = arg["toSend"]       --useless
    
    arg["To"] = arg["From"]
    arg["From"] = getPlayer():getOnlineID()
    arg["command"] = "ResponseCanAct"
    arg["toSend"] = {}
    sendClientCommand("TOC", "SendServer", arg)
    --ResetEverything()
end

Commands["ResetEverything"] = function(arg)
    local arg = arg["toSend"]
    ResetEverything()
end

local function OnTocServerCommand(module, command, args)
    if module == 'TOC' then
        if command == 'GivePlayerData' then
            --local surgeon = getPlayerByOnlineID(args[1])

            local surgeon_id = args[1]
            
            local patient =  getPlayerByOnlineID(args[2])
            local toc_data = patient:getModData().TOC

            -- todo maybe we cant send a table like this. Let's try something easier
            --local moneyAmount = playerTwo:getInventory():getCountTypeRecurse("Money")
            print("Giving info")

            -- not fast enough, wont get toc_data in time. FInd a better way to send and get data
            
            sendClientCommand(patient, "TOC", "SendPlayerData", {surgeon_id, toc_data})

        elseif command == 'SendTocData' then
            print("Sending TOC data")
            local patient = getPlayerByOnlineID(args[1])        --todo cant we delete this>?


            -- ew a global var.... but dunno if there's a better way to do this
            MP_other_player_toc_data = args[2]
        elseif Commands[command] then
            args = args or {}
            Commands[command](args)

        end
    end
end




Events.OnServerCommand.Add(OnTocServerCommand)