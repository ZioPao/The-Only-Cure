--- A rly big thx to Fenris_Wolf and Chuck to help me with that. Love you guy
if isClient() then return end

---Server side
local Commands = {}
Commands["SendServer"] = function(player, arg)
    local otherPlayer = getPlayerByOnlineID(arg["To"])
    print("The Only Cure Command: ", arg['command'])
    sendServerCommand(otherPlayer, "TOC", arg["command"], arg)
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
    arg["command"] = "CanOperateArm";
    arg["toSend"] = part_name;
    sendClientCommand("TOC", "SendServer", arg);
end

local function OnTocClientCommand(module, command, player, args)
    if module == 'TOC' then
        print(command)
        if command == 'GetPlayerData' then
            local surgeon_id = args[1]
            local patient_id = args[2]
            --local playerOne = getPlayerByOnlineID(args[1])
            local patient = getPlayerByOnlineID(args[2])
            --local playerOneID = args[1]
            sendServerCommand(patient, "TOC", "GivePlayerData", {surgeon_id, patient_id})
        elseif command == 'SendPlayerData' then
            local surgeon = getPlayerByOnlineID(args[1])
            local surgeon_id = args[1]
            local toc_data = args[2]
            sendServerCommand(surgeon, "TOC", "SendTocData", {surgeon_id, toc_data})
        elseif command == Commands[command] then
            args = args or {}
            Commands[command](_, args)
        end
    end

end

Events.OnClientCommand.Add(OnTocClientCommand)

