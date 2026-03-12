local DataController = require("TOC/Controllers/DataController")
local CommandsData = require("TOC/CommandsData")
local StaticData = require("TOC/StaticData")

---Owns the ModData lifecycle for TOC. The only place that populates tocData.
---@class ServerDataController
local ServerDataController = {}

---@private
local function createDefaultData()
    local tocData = {
        isIgnoredPartInfected = false,
        isAnyLimbCut = false,
        limbs = {},
        prostheses = {}
    }

    local defaultParams = {
        isCut = false, isInfected = false, isOperated = false, isCicatrized = false, isCauterized = false,
        woundDirtyness = -1, cicatrizationTime = -1,
        isVisible = false
    }

    for i=1, #StaticData.LIMBS_STR do
        local limbName = StaticData.LIMBS_STR[i]
        tocData.limbs[limbName] = {}
        for k, v in pairs(defaultParams) do tocData.limbs[limbName][k] = v end
        tocData.limbs[limbName].cicatrizationTime = 0
    end

    for i=1, #StaticData.AMP_GROUPS_STR do
        local group = StaticData.AMP_GROUPS_STR[i]
        tocData.prostheses[group] = {
            isProstEquipped = false,
            prostFactor = 0,
        }
    end

    return tocData
end

---Initialize or reset a DataController for a player. The only authoritative way to create DC instances.
---Creates the DC shell, loads or resets ModData, marks data ready (fires WhenReady callbacks),
---then optionally pushes the state to the client via apply().
---@param username string
---@param isResetForced boolean?
---@param playerObj IsoPlayer?
---@return DataController
function ServerDataController.Initialize(username, isResetForced, playerObj)
    local key = CommandsData.GetKey(username)

    -- Create or reuse shell; forced reset always creates a fresh shell
    local dcInst = DataController.instances[username]
    if not dcInst or isResetForced then
        dcInst = DataController:new(username, isResetForced)
    end

    -- Load existing data or create default
    local data
    if not isResetForced then
        data = ModData.get(key)
    end

    if data and data.limbs then
        dcInst.tocData = data
        TOC_DEBUG.print("ServerDataController: loaded existing data for " .. username)
    else
        TOC_DEBUG.print("ServerDataController: creating default data for " .. username)
        ModData.remove(key)
        dcInst.tocData = createDefaultData()
        ModData.add(key, dcInst.tocData)
    end

    dcInst:setIsResetForced(false)
    dcInst:setIsDataReady(true)  -- fires any queued WhenReady callbacks

    if playerObj then
        dcInst:apply(playerObj)
    end

    return dcInst
end

---Return the existing ready DC instance, or initialize a new one.
---@param username string
---@param playerObj IsoPlayer?
---@return DataController
function ServerDataController.GetOrCreate(username, playerObj)
    local inst = DataController.GetInstance(username)
    if inst and inst.isDataReady then
        return inst
    end
    return ServerDataController.Initialize(username, false, playerObj)
end

return ServerDataController
