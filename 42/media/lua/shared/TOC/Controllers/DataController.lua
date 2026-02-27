--* REWORK PLAN --
-- DataController will mainly work Server side, with the client that will be able to REQUEST updates.
-- Server is the authoritative source

local CommandsData = require("TOC/CommandsData")
local CommonMethods = require("TOC/CommonMethods")
local StaticData = require("TOC/StaticData")
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

---Create a new instance of DataController. If is onClient, will request the creation serverside
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
    TOC_DEBUG.print("Creating new instance of DataController instance for " .. o.username)

    -- store instance immediately
    DataController.instances[o.username] = o

    local key = CommandsData.GetKey(o.username)

    -- Server / singleplayer: ensure data exists locally
    if isServer() then
        o:ensureDataInitialized(key)
    end


    -- For client in MP, placeholder DataController instance until it gets readied with data from the server

    return o
end

---encapsulate ModData operations and default data creation
---@private
---@server
function DataController:createDefaultData()
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

---@private
---@server
function DataController:loadModData(key)
    return ModData.get(key)
end

---@private
---@server
function DataController:saveModData(key, data)
    ModData.add(key, data)
end

---@private
---@server
function DataController:ensureDataInitialized(key)
    -- Tries to load already existing data
    local data = self:loadModData(key)
    if data and data.limbs then
        self.tocData = data
        TOC_DEBUG.print("Found and loaded local data")
        TOC_DEBUG.printTable(self.tocData)
    end

    if self.tocData == nil or self.isResetForced then
        self:setup(key)
    end

    self:setIsDataReady(true)
    self:setIsResetForced(false)
end


---Setup a new toc mod data data class
---@param key string
---@private
---@server
function DataController:setup(key)
    TOC_DEBUG.print("Running setup")

    -- Clean ModData
    ModData.remove(key)

    -- create default structure
    self.tocData = self:createDefaultData()

    -- persist
    self:saveModData(key, self.tocData)

    triggerEvent("OnSetupTocData")
end

---In case of desync between the table on ModData and the table here
---@param tocData tocModDataType
---@private
---@server
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
    --triggerEvent("OnReceivedTocData", self.username)
end

-------------------------------------------

---@param username string
---@param isForced boolean
---@client
function DataController.RequestFromServer(username, isForced)
    --fix sp and mp split here

    -- local pl = CommonMethods.GetPatientForServer(id)
    -- local username = pl:getUsername()

    TOC_DEBUG.print("Requesting DC from Server")

    -- placeholder datacontroller, to be initialized
    local h = DataController:new(username, isForced)
    sendClientCommand(CommandsData.modules.TOC_RELAY, CommandsData.server.Relay.RelayRequestDataController, {username = username, isForced = isForced})
    return h
end


-----------------
--* Setters *--

---@param isDataReady boolean
function DataController:setIsDataReady(isDataReady)
    self.isDataReady = isDataReady
end

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

---comment
---@return boolean
function DataController:getIsDataReady()
    return self.isDataReady
end
---Set a generic boolean that toggles varies function of the mod
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
    return self.tocData.limbs[limbName].woundDirtyness
end

---Get cicatrizationTime
---@param limbName string
---@return number
function DataController:getCicatrizationTime(limbName)
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

---SERVER
---@param player IsoPlayer player to receive updated data
function DataController:apply(player)
    if isClient() and self:getIsDataReady() then
        -- TOC_DEBUG.print("[WORKAROUND] Sending ModData to server for " .. self.username)
        -- ModData.transmit(CommandsData.GetKey(self.username))
    elseif isServer() then
        --TOC_DEBUG.print("Forwarding ModData to " .. playerObj:getUsername())
        -- Notify player that they must request the data from the server
        --B42 TEMPORARY WORKAROUND FOR B42.14 ugly
        sendServerCommand(player, CommandsData.modules.TOC_RELAY, CommandsData.client.Relay.ReceiveApplyFromServer, {patientUsername = self.username})

        -- To be used with Cache
        triggerEvent("OnInitTocData", player, self.username, true)
    end


end

--- SHARED
---@param key string
---@param data tocModDataType
function DataController.ReceiveData(key, data)
    -- During startup the game can return Bob as the player username, adding a useless ModData table
    if key == "TOC_Bob" then return end
    if not luautils.stringStarts(key, StaticData.MOD_NAME .. "_") then return end

    TOC_DEBUG.print("ReceiveData for " .. key)
    local username = key:sub(5)
    local handler = DataController.GetInstance(username)

    if data == nil or data == false or data.limbs == nil then
        TOC_DEBUG.print("data/data.limbs is nil, new character or something is wrong")
        return
    end

    handler:save(data)

    -- FIX Should be an event
    if isClient() then
        -- Set a bool to use an overriding GetDamagedParts
        SetHealthPanelTOC()
    end

end

Events.OnReceiveGlobalModData.Add(DataController.ReceiveData)

-----------------

---@param username string
---@param isReset boolean?
---@return DataController
function DataController.GetInstance(username, isReset)

    if DataController.instances[username] ~= nil then
        -- If instance exists (even placeholder), return it
        return DataController.instances[username]
    elseif isServer() then      --B42 broken in sp
        return DataController:new(username, isReset)
    end
    -- elseif isClient() then
    --     return DataController.RequestFromServer(username, isReset)
    -- end
end



function DataController.DestroyInstance(username)
    if DataController.instances[username] ~= nil then
        DataController.instances[username] = nil
    end

end

return DataController