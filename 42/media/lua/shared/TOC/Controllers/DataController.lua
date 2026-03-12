-- DataController: pure data model. Server-side lifecycle is handled by ServerDataController.
-- Client-side async load is handled by ClientDataController.

local CommandsData = require("TOC/CommandsData")
local CommonMethods = require("TOC/CommonMethods")
local StaticData = require("TOC/StaticData")
require("TOC/Events")
----------------

--- An instance will be abbreviated with dcInst

--- Handle all TOC mod data related stuff
---@class DataController
---@field username string
---@field tocData tocModDataType
---@field isDataReady boolean
---@field isResetForced boolean
local DataController = {}
DataController.instances = {}
DataController._readyCallbacks = {}

---Create a new shell instance of DataController. Does NOT initialize tocData.
---Use ServerDataController.Initialize (server/SP) or ClientDataController.Request (client) to populate data.
---@param username string
---@param isResetForced boolean?
---@return DataController
function DataController:new(username, isResetForced)
    ---@type DataController
    ---@diagnostic disable-next-line: missing-fields
    local o = {}
    setmetatable(o, self)
    self.__index = self

    o.username = username
    o.isDataReady = false
    o.isResetForced = isResetForced or false
    TOC_DEBUG.print("Creating new shell instance of DataController for " .. o.username)

    -- store instance immediately
    DataController.instances[o.username] = o

    return o
end

---Register a callback to run when DC data is ready for a username.
---If the instance already exists and is ready, fires immediately (synchronously).
---Otherwise queues the callback until setIsDataReady(true) is called.
---@param username string
---@param callback fun(dcInst: DataController)
function DataController.WhenReady(username, callback)
    local inst = DataController.instances[username]
    if inst and inst.isDataReady then
        callback(inst)
        return
    end
    if not DataController._readyCallbacks[username] then
        DataController._readyCallbacks[username] = {}
    end
    table.insert(DataController._readyCallbacks[username], callback)
end

---In case of desync between the table on ModData and the table here.
---Called by ClientDataController.OnDataReceived when the server data arrives.
---@param tocData tocModDataType
function DataController:save(tocData)
    if not tocData or not tocData.limbs then
        TOC_DEBUG.print("Received invalid tocData")
        return
    end
    local key = CommandsData.GetKey(self.username)
    ModData.add(key, tocData)
    self.tocData = tocData
    self:setIsResetForced(false)
    self:setIsDataReady(true)
end

-----------------
--* Setters *--

---@param isDataReady boolean
function DataController:setIsDataReady(isDataReady)
    self.isDataReady = isDataReady
    if isDataReady then
        triggerEvent("OnTOCDataReady", self.username)
    end
end

---Listener for OnTOCDataReady. Fires and clears any queued WhenReady callbacks for the username.
---@param username string
function DataController.OnDataReady(username)
    local callbacks = DataController._readyCallbacks[username]
    if not callbacks then return end
    DataController._readyCallbacks[username] = nil
    local inst = DataController.instances[username]
    for _, cb in ipairs(callbacks) do
        pcall(cb, inst)
    end
end

Events.OnTOCDataReady.Add(DataController.OnDataReady)

---@param isResetForced boolean
function DataController:setIsResetForced(isResetForced)
    self.isResetForced = isResetForced
end

---Set a generic boolean that toggles varies function of the mod
---@param isAnyLimbCut boolean
function DataController:setIsAnyLimbCut(isAnyLimbCut)
    self.tocData.isAnyLimbCut = isAnyLimbCut
end

---Set isIgnoredPartInfected
---@param isIgnoredPartInfected boolean
function DataController:setIsIgnoredPartInfected(isIgnoredPartInfected)
    self.tocData.isIgnoredPartInfected = isIgnoredPartInfected
end

---Set isCut
---@param limbName string
---@param isCut boolean
function DataController:setIsCut(limbName, isCut)
    self.tocData.limbs[limbName].isCut = isCut
end

---Set isInfected.
---@param limbName string
---@param isInfected boolean
function DataController:setIsInfected(limbName, isInfected)
    self.tocData.limbs[limbName].isInfected = isInfected
end

---Set isCicatrized
---@param limbName string
---@param isCicatrized boolean
function DataController:setIsCicatrized(limbName, isCicatrized)
    self.tocData.limbs[limbName].isCicatrized = isCicatrized
end

---Set isCauterized
---@param limbName string
---@param isCauterized boolean
function DataController:setIsCauterized(limbName, isCauterized)
    self.tocData.limbs[limbName].isCauterized = isCauterized
end

---Set woundDirtyness
---@param limbName string
---@param woundDirtyness number
function DataController:setWoundDirtyness(limbName, woundDirtyness)
    self.tocData.limbs[limbName].woundDirtyness = woundDirtyness
end

---Set cicatrizationTime
---@param limbName string
---@param cicatrizationTime number
function DataController:setCicatrizationTime(limbName, cicatrizationTime)
    self.tocData.limbs[limbName].cicatrizationTime = cicatrizationTime
end

---Set isProstEquipped
---@param group string
---@param isProstEquipped boolean
function DataController:setIsProstEquipped(group, isProstEquipped)
    self.tocData.prostheses[group].isProstEquipped = isProstEquipped
end

---Set prostFactor
---@param group string
---@param prostFactor number
function DataController:setProstFactor(group, prostFactor)
    self.tocData.prostheses[group].prostFactor = prostFactor
end

-----------------
--* Getters *--

---@return boolean
function DataController:getIsDataReady()
    return self.isDataReady
end

---@return boolean
function DataController:getIsAnyLimbCut()
    if not self.isDataReady then return false end
    return self.tocData.isAnyLimbCut
end

---Get isIgnoredPartInfected
---@return boolean
function DataController:getIsIgnoredPartInfected()
    if not self.isDataReady then return false end
    return self.tocData.isIgnoredPartInfected
end

---Get isCut
---@param limbName string
---@return boolean
function DataController:getIsCut(limbName)
    if not self.isDataReady or not self.tocData or not self.tocData.limbs then return false end
    return self.tocData.limbs[limbName] and self.tocData.limbs[limbName].isCut or false
end

---Get isVisible
---@param limbName string
---@return boolean
function DataController:getIsVisible(limbName)
    if not self.isDataReady then return false end
    return self.tocData.limbs[limbName].isVisible
end

---Get isCicatrized
---@param limbName string
---@return boolean
function DataController:getIsCicatrized(limbName)
    if not self.isDataReady then return false end
    return self.tocData.limbs[limbName].isCicatrized
end

---Get isCauterized
---@param limbName string
---@return boolean
function DataController:getIsCauterized(limbName)
    if not self.isDataReady then return false end
    return self.tocData.limbs[limbName].isCauterized
end

---Get isInfected
---@param limbName string
---@return boolean
function DataController:getIsInfected(limbName)
    return self.tocData.limbs[limbName].isInfected
end

---Get woundDirtyness
---@param limbName string
---@return number
function DataController:getWoundDirtyness(limbName)
    if not self.isDataReady then return -1 end
    return self.tocData.limbs[limbName].woundDirtyness
end

---Get cicatrizationTime
---@param limbName string
---@return number
function DataController:getCicatrizationTime(limbName)
    if not self.isDataReady then return -1 end
    return self.tocData.limbs[limbName].cicatrizationTime
end

---Get isProstEquipped
---@param limbName string
---@return boolean
function DataController:getIsProstEquipped(limbName)
    if not self.isDataReady then return false end
    local prostGroup = StaticData.LIMBS_TO_AMP_GROUPS_MATCH_IND_STR[limbName]
    return self.tocData.prostheses[prostGroup].isProstEquipped
end

---Get prostFactor
---@param group string
---@return number
function DataController:getProstFactor(group)
    return self.tocData.prostheses[group].prostFactor
end

--* Limbs data handling *--

---Set a limb and its dependend limbs as cut
---@param limbName string
---@param isOperated boolean
---@param isCicatrized boolean
---@param isCauterized boolean
---@param surgeonFactor number?
function DataController:setCutLimb(limbName, isOperated, isCicatrized, isCauterized, surgeonFactor)
    local cicatrizationTime = 0
    if isCicatrized == false or isCauterized == false then
        cicatrizationTime = StaticData.LIMBS_CICATRIZATION_TIME_IND_NUM[limbName] - surgeonFactor
    end

    ---@type partDataType
    local params = {isCut = true, isInfected = false, isOperated = isOperated, isCicatrized = isCicatrized, isCauterized = isCauterized, woundDirtyness = 0, isVisible = true}
    self:setLimbParams(limbName, params, cicatrizationTime)

    for i=1, #StaticData.LIMBS_DEPENDENCIES_IND_STR[limbName] do
        local dependedLimbName = StaticData.LIMBS_DEPENDENCIES_IND_STR[limbName][i]

        -- We don't care about isOperated, isCicatrized, isCauterized since this is depending on another limb
        -- Same story for cicatrizationTime, which will be 0
        -- isCicatrized is to true to prevent it from doing the cicatrization process
        self:setLimbParams(dependedLimbName, {isCut = true, isInfected = false, isVisible = false, isCicatrized = true}, 0)
    end

    -- Set that a limb has been cut, to activate some functions without having to loop through the parts
    self:setIsAnyLimbCut(true)

end

---Set a limb data
---@param limbName string
---@param ampStatus partDataType {isCut, isInfected, isOperated, isCicatrized, isCauterized, isVisible}
---@param cicatrizationTime integer?
function DataController:setLimbParams(limbName, ampStatus, cicatrizationTime)
    local limbData = self.tocData.limbs[limbName]
    for k, v in pairs(ampStatus) do
        if v ~= nil then
            limbData[k] = v
        end
    end
    if cicatrizationTime ~= nil then limbData.cicatrizationTime = cicatrizationTime end
end

--* Update statuses of a limb *--

---Decreases the cicatrization time
---@param limbName string
---@client
function DataController:decreaseCicatrizationTime(limbName)
    self.tocData.limbs[limbName].cicatrizationTime = self.tocData.limbs[limbName].cicatrizationTime - 1
end

--* Specific updates from Client
---@param limbName string
---Sends only the necessary data to update cicatrization stats to server, while being already ok on the client
function DataController:updateAmputationsFromClient(limbName)
    if self:getIsDataReady() then
        local cicTime = self:getCicatrizationTime(limbName)
        local dirtyness = self:getWoundDirtyness(limbName)
        local isInfected = self:getIsInfected(limbName)
        local isCicatrized = self:getIsCicatrized(limbName)
        local isCauterized = self:getIsCauterized(limbName)

        sendClientCommand(CommandsData.modules.TOC_RELAY, CommandsData.server.Relay.UpdateDataControllerFromClient, {limbName = limbName,
        cicTime = cicTime,
        dirtyness = dirtyness,
        isInfected = isInfected,
        isCauterized = isCauterized,
        isCicatrized = isCicatrized})
    end
end


function DataController:updateIsIgnoredPartInfectedFromClient()
    local isIgnoredPartInfected = self:getIsIgnoredPartInfected()
    sendClientCommand(CommandsData.modules.TOC_RELAY, CommandsData.server.Relay.UpdateDataControllerFromClient, {
    isIgnoredPartInfected = isIgnoredPartInfected})
end

--* Global Mod Data Handling *--

---SERVER: push current state to a specific client (MP) or fire OnInitTocData (SP/server)
---@param player IsoPlayer player to receive updated data
function DataController:apply(player)
    if isClient() then return end

    if isServer() then
        sendServerCommand(player, CommandsData.modules.TOC_RELAY, CommandsData.client.Relay.ReceiveApplyFromServer,
            {patientUsername = self.username})
    end

    -- To be used with Cache, SP and MP (Server)
    TOC_DEBUG.print("Finished apply, triggering OnInitTocData")
    triggerEvent("OnInitTocData", player, self.username, true)
end

-----------------

---@param username string
---@return DataController?
function DataController.GetInstance(username)
    return DataController.instances[username]
end

function DataController.DestroyInstance(username)
    if DataController.instances[username] ~= nil then
        DataController.instances[username] = nil
    end
    DataController._readyCallbacks[username] = nil
end

return DataController
