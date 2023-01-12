--- A rly big thx to Fenris_Wolf and Chuck to help me with that. Love you guy
local Commands = {}

-- Surgeon (send)
function SendCutArm(player, partName, surgeonFact, useBandage, bandageAlcool, usePainkiller, painkillerCount)
    local arg = {};
    arg["From"] = getPlayer():getOnlineID();
    arg["To"] = player:getOnlineID();
    arg["command"] = "CutArm";
    arg["toSend"] = {partName, surgeonFact, useBandage, bandageAlcool, usePainkiller, painkillerCount};
    sendClientCommand("TOC", "SendServer", arg);
end

function SendOperateArm(player, partName, surgeonFact, useOven)
    local arg = {};
    arg["From"] = getPlayer():getOnlineID();
    arg["To"] = player:getOnlineID();
    arg["command"] = "OperateArm";
    arg["toSend"] = {partName, surgeonFact, useOven};
    sendClientCommand("TOC", "SendServer", arg);
end

function AskCanCutArm(player, partName)
    GetConfirmUIMP().responseReceive = false;
    local arg = {};
    arg["From"] = getPlayer():getOnlineID();
    arg["To"] = player:getOnlineID();
    arg["command"] = "CanCutArm";
    arg["toSend"] = partName;
    sendClientCommand("TOC", "SendServer", arg);
end

function AskCanOperateArm(player, partName)
    GetConfirmUIMP().responseReceive = false;
    local arg = {};
    arg["From"] = getPlayer():getOnlineID();
    arg["To"] = player:getOnlineID();
    arg["command"] = "CanOperateArm";
    arg["toSend"] = partName;
    sendClientCommand("TOC", "SendServer", arg);
end

Commands["responseCanArm"] = function(arg)
    local ui = GetConfirmUIMP()
    ui.responseReceive = true;
    ui.responseAction = arg["toSend"][2];
    ui.responsePartName = arg["toSend"][1];
    ui.responseCan = arg["toSend"][3];
    ui.responseUserName = getPlayerByOnlineID(arg["From"]):getUsername();
    ui.responseActionIsBitten = getPlayerByOnlineID(arg["From"]):getBodyDamage():getBodyPart(TOC_getBodyPart(ui.responsePartName)):bitten();
end


-- Patient (receive)
Commands["CutArm"] = function(arg)
    local arg = arg["toSend"];
    CutArm(arg[1], arg[2], arg[3], arg[4], arg[5], arg[6]);
end

Commands["OperateArm"] = function(arg)
    local arg = arg["toSend"];
    OperateArm(arg[1], arg[2], arg[3]);
end

Commands["CanCutArm"] = function(arg)
    local partName = arg["toSend"];
    
    arg["To"] = arg["From"];
    arg["From"] = getPlayer():getOnlineID();
    arg["command"] = "responseCanArm";
    arg["toSend"] = {partName, "Cut", CanBeCut(partName)};
    sendClientCommand("TOC", "SendServer", arg);
end

Commands["CanOperateArm"] = function(arg)
    local partName = arg["toSend"];

    arg["To"] = arg["From"];
    arg["From"] = getPlayer():getOnlineID();
    arg["command"] = "responseCanArm";
    arg["toSend"] = {partName, "Operate", CanBeOperate(partName)};
    sendClientCommand("TOC", "SendServer", arg);
end





--------------------------------------------------------------------

function AskGetOtherPlayerData(player)
    local arg = {}

    arg["From"] = getPlayer():getOnlineID()     --surgoen
    arg["To"] = player:getOnlineID()            --patient


    arg["command"] = "SendOtherPlayerData";
    arg["toSend"] = {player:getModData().TOC}       -- will it work?
    sendClientCommand("TOC", "SendServer", arg);

end





function SendGetOtherPlayerData(player)
    local arg = {}

    arg["From"] = getPlayer():getOnlineID()     --surgoen
    arg["To"] = player:getOnlineID()            --patient


    arg["command"] = "GetOtherPlayerData";
    arg["toSend"] = {player:getModData().TOC}       -- will it work?
    sendClientCommand("TOC", "SendServer", arg);
end



-- todo why is this here? this doesnt make any sense


-- Event
local onServerCommand = function(module, command, args)
    -- TODO change this name
    if module == "TOC" and Commands[command] then
        args = args or {}
        Commands[command](args)
    end
end

Events.OnServerCommand.Add(onServerCommand)