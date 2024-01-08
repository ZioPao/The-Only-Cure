TOC_DEBUG = {}
TOC_DEBUG.disablePaneMod = false
TOC_DEBUG.enableHealthPanelDebug = false

function TOC_DEBUG.TogglePaneMod()
    TOC_DEBUG.disablePaneMod = not TOC_DEBUG.disablePaneMod
end

function TOC_DEBUG.ToggleHealthPanelDebug()
    TOC_DEBUG.enableHealthPanelDebug = not TOC_DEBUG.enableHealthPanelDebug 
end

---Print debug
---@param string string
function TOC_DEBUG.print(string)
    if isDebugEnabled() then
        local runningFile = TOC_DEBUG.getRunningFile()
        print("[TOC]" .. "[" .. runningFile .. "] " .. tostring(string))
    end
end

---Horrendous but I don't really care about performance for this
---@return string
function TOC_DEBUG.getRunningFile()
    local coroutine = getCurrentCoroutine()

    local o = getCoroutineObjStack(coroutine, 0)
    if o then
        local s = KahluaUtil.rawTostring2(o)
        local match = string.match(s, "file: (%w+)%.lua")
        if match then return match end

    end

    return ""

end

function TOC_DEBUG.printTable(table, indent)
    if not table then return end
    indent = indent or ""

    for key, value in pairs(table) do
        if type(value) == "table" then
            print(indent .. key .. " (table):")
            TOC_DEBUG.printTable(value, indent .. "  ")
        else
            print(indent .. key .. ":", value)
        end
    end
end

---------------------------------
--* Random debug commands *--

function TOC_DEBUG.TestBodyDamage(id)
    local StaticData = require("TOC/StaticData")

    local pl = getPlayerByOnlineID(id)
    local bd = pl:getBodyDamage()

    TOC_DEBUG.print(tostring(bd))

    if bd then
        TOC_DEBUG.print("bd for " .. pl:getUsername() .. " exists")
        local bptEnum = StaticData.BODYLOCS_IND_BPT["Hand_L"]
        local bodyPart = bd:getBodyPart(bptEnum)

        bodyPart:setBleeding(true)
        bodyPart:setCut(true)
        TOC_DEBUG.print(tostring(bodyPart))
    end
end

function TOC_DEBUG.TestBloodDrop()
    local pl = getPlayer()

    --IsoZombieGiblets.GibletType.A
    --local giblets = IsoZombieGiblets.new(getCell())

    local sq = pl:getSquare()
    local t = IsoZombieGiblets.class.GibletType

    print(t)
    --IsoBall.new(getCell(), pl:getX(), pl:)
    addBloodSplat(sq, 100)


    --pl:getChunk():addBloodSplat(pl:getX(), pl:getY(), pl:getZ(), 100)
    --IsoZombieGiblets.new(x, getCell(), pl:getX(), pl:getY(), pl:getZ(), 100, 1)

end
---------------------------------
--* Debug server commands *--

local CommandsData = require("TOC/CommandsData")

function TOC_DEBUG.printPlayerServerModData(username)
    sendClientCommand(CommandsData.modules.TOC_DEBUG, CommandsData.server.Debug.PrintTocData, {username = username})
end

function TOC_DEBUG.printAllServerModData()
    sendClientCommand(CommandsData.modules.TOC_DEBUG, CommandsData.server.Debug.PrintAllTocData, {})
end

function TOC_DEBUG.testRelayDamage()
    ---@type relayDamageDuringAmputationParams
    local params = {limbName = "Hand_R", patientNum = getPlayer():getOnlineID()}
    sendClientCommand(CommandsData.modules.TOC_RELAY, CommandsData.server.Relay.RelayDamageDuringAmputation, params)
end