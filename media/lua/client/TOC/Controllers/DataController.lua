if isServer() then return end

local CommandsData = require("TOC/CommandsData")
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

---Setup a new Mod Data Handler
---@param username string
---@param isResetForced boolean?
---@return DataController
function DataController:new(username, isResetForced)
    TOC_DEBUG.print("Creating new DataController instance for " .. username)
    ---@type DataController
    ---@diagnostic disable-next-line: missing-fields
    local o = {}
    setmetatable(o, self)
    self.__index = self

    o.username = username
    o.isResetForced = isResetForced or false
    o.isDataReady = false

    -- We're gonna set it already from here, to prevent it from looping in SP (in case we need to fetch this instance)
    DataController.instances[username] = o

    local key = CommandsData.GetKey(username)

    if isClient() then
        -- In MP, we request the data from the server to trigger DataController.ReceiveData
        ModData.request(key)
    else
        -- In SP, we handle it with another function which will reference the saved instance in DataController.instances
        o:initSinglePlayer(key)
    end

    return o
end


---Setup a new toc mod data data class
---@param key string
function DataController:setup(key)
    TOC_DEBUG.print("Running setup")

    ---@type tocModDataType
    self.tocData = {
        -- Generic stuff that does not belong anywhere else
        isInitializing = true,
        isIgnoredPartInfected = false,
        isAnyLimbCut = false,
        limbs = {},
        prostheses = {}
    }

    ---@type partDataType
    local defaultParams = {
        isCut = false, isInfected = false, isOperated = false, isCicatrized = false, isCauterized = false,
        woundDirtyness = -1, cicatrizationTime = -1,
        isVisible = false
    }

    -- Initialize limbs
    for i=1, #StaticData.LIMBS_STR do
        local limbName = StaticData.LIMBS_STR[i]
        self.tocData.limbs[limbName] = {}
        self:setLimbParams(StaticData.LIMBS_STR[i], defaultParams, 0)
    end

    -- Initialize prostheses stuff
    for i=1, #StaticData.AMP_GROUPS_STR do
        local group = StaticData.AMP_GROUPS_STR[i]
        self.tocData.prostheses[group] = {
            isProstEquipped = false,
            prostFactor = 0,
        }
    end

    -- Add it to client global mod data
    ModData.add(key, self.tocData)

    -- Sync with the server
    self:apply()

    -- -- Disable lock
    -- self.tocData.isInitializing = false
    -- ModData.add(key, self.tocData)



    -- FIX THIS THING HERE ISN'T REALLY CORRECT BUT IT'S A WORKAROUND UNTIL WE FIGURE IT OUT
    -- The issue is that we need to do this once, not every single time we load data.
    -- Manage their traits
    local LocalPlayerController = require("TOC/Controller/LocalPlayerController")
    LocalPlayerController.ManageTraits(getPlayer())

end

---In case of desync between the table on ModData and the table here
---@param tocData tocModDataType
function DataController:applyOnlineData(tocData)
    local key = CommandsData.GetKey(self.username)
    ModData.add(key, tocData)
    self.tocData = ModData.get(key)
end

---@param key string
function DataController:tryLoadLocalData(key)
    self.tocData = ModData.get(key)

    --TOC_DEBUG.printTable(self.tocData)

    if self.tocData and self.tocData.limbs then
        TOC_DEBUG.print("Found and loaded local data")
    else
        TOC_DEBUG.print("Local data failed to load! Running setup")
        self:setup(key)
    end
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

---Set isInfected
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
    if not self.isDataReady then return false end
    if self.tocData.limbs[limbName] then
        return self.tocData.limbs[limbName].isCut
    else
        return false
    end
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

    -- TODO In theory we should cache data from here, not AmputationHandler
end

---Set a limb data
---@param limbName string
---@param ampStatus partDataType {isCut, isInfected, isOperated, isCicatrized, isCauterized, isVisible}
---@param cicatrizationTime integer?
function DataController:setLimbParams(limbName, ampStatus, cicatrizationTime)
    local limbData = self.tocData.limbs[limbName]
    if ampStatus.isCut ~= nil then limbData.isCut = ampStatus.isCut end
    if ampStatus.isInfected ~= nil then limbData.isInfected = ampStatus.isInfected end
    if ampStatus.isOperated ~= nil then limbData.isOperated = ampStatus.isOperated end
    if ampStatus.isCicatrized ~= nil then limbData.isCicatrized = ampStatus.isCicatrized end
    if ampStatus.isCauterized ~= nil then limbData.isCauterized = ampStatus.isCauterized end
    if ampStatus.woundDirtyness ~= nil then limbData.woundDirtyness = ampStatus.woundDirtyness end
    if ampStatus.isVisible ~= nil then limbData.isVisible = ampStatus.isVisible end

    if cicatrizationTime ~= nil then limbData.cicatrizationTime = cicatrizationTime end
end

--* Update statuses of a limb *--

---Decreases the cicatrization time
---@param limbName string
function DataController:decreaseCicatrizationTime(limbName)
    self.tocData.limbs[limbName].cicatrizationTime = self.tocData.limbs[limbName].cicatrizationTime - 1
end

--* Global Mod Data Handling *--

function DataController:apply()
    TOC_DEBUG.print("Applying data for " .. self.username)
    ModData.transmit(CommandsData.GetKey(self.username))

    -- if getPlayer():getUsername() ~= self.username then
    --     sendClientCommand(CommandsData.modules.TOC_RELAY, CommandsData.server.Relay.RelayApplyFromOtherClient, {patientUsername = self.username} )
    --     -- force request from the server for that other client...
    -- end
end


---Online only, Global Mod Data doesn't trigger this in SP
---@param key string
---@param data tocModDataType
function DataController.ReceiveData(key, data)
    -- During startup the game can return Bob as the player username, adding a useless ModData table
    if key == "TOC_Bob" then return end
    if not luautils.stringStarts(key, StaticData.MOD_NAME .. "_") then return end


    TOC_DEBUG.print("ReceiveData for " .. key)

    -- if data == nil or data.limbs == nil then
    --     TOC_DEBUG.print("Data is nil, new character or something is wrong")
    -- end

    -- Get DataController instance if there was none for that user and reapply the correct ModData table as a reference
    local username = key:sub(5)
    local handler = DataController.GetInstance(username)

    -- Bit of a workaround, but in a perfect world, I'd use the server to get the data and that would be it.
    -- but Zomboid Mod Data handling is too finnicky at best to be that reliable, in case of an unwanted disconnection and what not,
    -- so for now, I'm gonna assume that the local data (for the local client) is the
    -- most recent (and correct) one instead of trying to fetch it from the server every single time


    -- TODO Add update from server scenario

    if handler.isResetForced then
        TOC_DEBUG.print("Forced reset")
        handler:setup(key)
    elseif data and data.limbs then
        -- Let's validate that the data structure is actually valid to prevent issues
        if data.isUpdateFromServer then
            TOC_DEBUG.print("Update from the server")
        end
        handler:applyOnlineData(data)
    elseif username == getPlayer():getUsername() then
        TOC_DEBUG.print("Trying to load local data or no data is available")
        handler:tryLoadLocalData(key)
    end


    handler:setIsResetForced(false)
    handler:setIsDataReady(true)

    triggerEvent("OnReceivedTocData", handler.username)

    -- TODO We need an event to track if initialization has been finalized



    -- if username == getPlayer():getUsername() and not handler.isResetForced then
    --     handler:loadLocalData(key)
    -- elseif handler.isResetForced or data == nil then
    --     TOC_DEBUG.print("Data is nil or empty!?")
    --     TOC_DEBUG.printTable(data)
    --     handler:setup(key)
    -- elseif data and data.limbs then
    --     handler:applyOnlineData(data)
    -- end

    -- handler:setIsResetForced(false)
    -- handler:setIsDataReady(true)

    -- -- Event, triggers caching
    -- triggerEvent("OnReceivedTocData", handler.username)

    -- Transmit it back to the server
    --ModData.transmit(key)
    --TOC_DEBUG.print("Transmitting data after receiving it for: " .. handler.username)

end

Events.OnReceiveGlobalModData.Add(DataController.ReceiveData)



--- SP Only initialization
---@param key string
function DataController:initSinglePlayer(key)
    self:tryLoadLocalData(key)
    if self.tocData == nil or self.isResetForced then
        self:setup(key)
    end

    self:setIsDataReady(true)
    self:setIsResetForced(false)

    -- Event, triggers caching
    triggerEvent("OnReceivedTocData", self.username)
end
-------------------

---@param username string?
---@return DataController
function DataController.GetInstance(username)
    if username == nil or username == "Bob" then
        username = getPlayer():getUsername()
    end

    if DataController.instances[username] == nil then
        TOC_DEBUG.print("Creating NEW instance for " .. username)
        return DataController:new(username)
    else
        return DataController.instances[username]
    end
end


function DataController.DestroyInstance(username)
    if DataController.instances[username] ~= nil then
        DataController.instances[username] = nil
    end

end

return DataController