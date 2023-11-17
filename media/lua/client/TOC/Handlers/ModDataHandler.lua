local CommandsData = require("TOC/CommandsData")
local StaticData = require("TOC/StaticData")
----------------

--- Handle all mod data related stuff
---@class ModDataHandler
---@field username string
---@field tocData tocModData 
local ModDataHandler = {}
ModDataHandler.instances = {}

---Setup a new Mod Data Handler
---@param username string
---@param isResetForced boolean?
---@return ModDataHandler
function ModDataHandler:new(username, isResetForced)
    local o = {}
    setmetatable(o, self)
    self.__index = self

    o.username = username
    local key = CommandsData.GetKey(username)

    -- We don't want to request ModData if we're in SP, or if we're forcing a reset
    if isClient() and not isResetForced then
        ModData.request(key)
    end

    o.tocData = ModData.get(key)        -- TODO This is working like a placeholder at the moment, it's gonna get replaced later in reapplyTocData

    if isResetForced or o.tocData == nil or o.tocData.limbs == nil or o.tocData.limbs.Hand_L == nil or o.tocData.limbs.Hand_L.isCut == nil then
        TOC_DEBUG.print("tocData in ModDataHandler for " .. username .. " is nil, creating it now")
        o:setup(key)
    end


    -- Transmit it to the server
    ModData.transmit(key)
    TOC_DEBUG.print("initialized ModDataHandler for " .. username)

    ModDataHandler.instances[username] = o

    return o
end

function ModDataHandler:initialize()

end

---Setup a new toc mod data data class
---@param key string
function ModDataHandler:setup(key)

    ---@type tocModData
    self.tocData = {
        -- Generic stuff that does not belong anywhere else
        isIgnoredPartInfected = false,
        isAnyLimbCut = false,
        limbs = {},
        prostheses = {}
    }

    ---@type partData
    local defaultParams = {
        isCut = false, isInfected = false, isOperated = false, isCicatrized = false,
        isCauterized = false, isVisible = false
    }

    -- Initialize limbs
    for i=1, #StaticData.LIMBS_STR do
        local limbName = StaticData.LIMBS_STR[i]
        self.tocData.limbs[limbName] = {}
        self:setLimbParams(StaticData.LIMBS_STR[i], defaultParams, 0)
    end

    -- Initialize prostheses stuff
    for i=1, #StaticData.PROSTHESES_GROUPS_STR do
        local group = StaticData.PROSTHESES_GROUPS_STR[i]
        self.tocData.prostheses[group] = {
            isProstEquipped = false,
            prostFactor = 0,
        }
    end

    -- Add it to global mod data
    ModData.add(key, self.tocData)

end

---In case of desync between the table on ModData and the table here
---@param key string
---@param tocData tocModData
function ModDataHandler:reapplyTocData(key, tocData)
    ModData.add(key, tocData)
    self.tocData = ModData.get(key)
end

-----------------
--* Setters *--

---Set a generic boolean that toggles varies function of the mod
---@param isAnyLimbCut boolean
function ModDataHandler:setIsAnyLimbCut(isAnyLimbCut)
    self.tocData.isAnyLimbCut = isAnyLimbCut
end

---Set isIgnoredPartInfected
---@param isIgnoredPartInfected boolean
function ModDataHandler:setIsIgnoredPartInfected(isIgnoredPartInfected)
    self.tocData.isIgnoredPartInfected = isIgnoredPartInfected
end

---Set isCut 
---@param limbName string
---@param isCut boolean
function ModDataHandler:setIsCut(limbName, isCut)
    self.tocData.limbs[limbName].isCut = isCut
end

---Set isInfected
---@param limbName string
---@param isInfected boolean
function ModDataHandler:setIsInfected(limbName, isInfected)
    self.tocData.limbs[limbName].isInfected = isInfected
end

---Set isCicatrized
---@param limbName string
---@param isCicatrized boolean
function ModDataHandler:setIsCicatrized(limbName, isCicatrized)
    self.tocData.limbs[limbName].isCicatrized = isCicatrized
end

---Set isCauterized
---@param limbName string
---@param isCauterized boolean
function ModDataHandler:setIsCauterized(limbName, isCauterized)
    self.tocData.limbs[limbName].isCauterized = isCauterized
end

---Set cicatrizationTime
---@param limbName string
---@param cicatrizationTime number
function ModDataHandler:setCicatrizationTime(limbName, cicatrizationTime)
    self.tocData.limbs[limbName].cicatrizationTime = cicatrizationTime
end

---Set isProstEquipped
---@param group string
---@param isProstEquipped boolean
function ModDataHandler:setIsProstEquipped(group, isProstEquipped)
    self.tocData.prostheses[group].isProstEquipped = isProstEquipped
end

---Set prostFactor
---@param group string
---@param prostFactor number
function ModDataHandler:setProstFactor(group, prostFactor)
    self.tocData.prostheses[group].prostFactor = prostFactor
end

-----------------
--* Getters *--

---Set a generic boolean that toggles varies function of the mod
---@return boolean
function ModDataHandler:getIsAnyLimbCut()
    return self.tocData.isAnyLimbCut
end

---Get isIgnoredPartInfected
---@return boolean
function ModDataHandler:getIsIgnoredPartInfected()
    return self.tocData.isIgnoredPartInfected
end

---Get isCut
---@param limbName string
---@return boolean
function ModDataHandler:getIsCut(limbName)
    return self.tocData.limbs[limbName].isCut
end

---Get isVisible
---@param limbName string
---@return boolean
function ModDataHandler:getIsVisible(limbName)
    return self.tocData.limbs[limbName].isVisible
end

---Get isCicatrized
---@param limbName string
---@return boolean
function ModDataHandler:getIsCicatrized(limbName)
    return self.tocData.limbs[limbName].isCicatrized
end

---Get isCauterized
---@param limbName string
---@return boolean
function ModDataHandler:getIsCauterized(limbName)
    return self.tocData.limbs[limbName].isCauterized
end

---Get cicatrizationTime
---@param limbName string
---@return number
function ModDataHandler:getCicatrizationTime(limbName)
    return self.tocData.limbs[limbName].cicatrizationTime
end

---Get isProstEquipped
---@param group string
---@return boolean
function ModDataHandler:getIsProstEquipped(group)
    return self.tocData.prostheses[group].isProstEquipped
end

---Get prostFactor
---@param group string
---@return number
function ModDataHandler:getProstFactor(group)
    return self.tocData.prostheses[group].prostFactor
end

--* Limbs data handling *--

---Set a limb and its dependend limbs as cut
---@param limbName string
---@param isOperated boolean
---@param isCicatrized boolean
---@param isCauterized boolean
---@param surgeonFactor number?
function ModDataHandler:setCutLimb(limbName, isOperated, isCicatrized, isCauterized, surgeonFactor)
    local cicatrizationTime = 0
    if isCicatrized == false or isCauterized == false then
        cicatrizationTime = StaticData.LIMBS_CICATRIZATION_TIME_IND_NUM[limbName] - surgeonFactor
    end

    ---@type partData
    local params = {isCut = true, isInfected = false, isOperated = isOperated, isCicatrized = isCicatrized, isCauterized = isCauterized, isVisible = true}
    self:setLimbParams(limbName, params, cicatrizationTime)

    for i=1, #StaticData.LIMBS_DEPENDENCIES_IND_STR[limbName] do
        local dependedLimbName = StaticData.LIMBS_DEPENDENCIES_IND_STR[limbName][i]

        -- We don't care about isOperated, isCicatrized, isCauterized since this is depending on another limb
        -- Same story for cicatrizationTime, which will be 0
        self:setLimbParams(dependedLimbName, {isCut = true, isInfected = false, isVisible = false}, 0)
    end

    -- Set that a limb has been cut, to activate some functions without having to loop through the parts
    self:setIsAnyLimbCut(true)

end

---Set a limb data
---@param limbName string
---@param ampStatus partData {isCut, isInfected, isOperated, isCicatrized, isCauterized, isVisible}
---@param cicatrizationTime integer?
function ModDataHandler:setLimbParams(limbName, ampStatus, cicatrizationTime)
    local limbData = self.tocData.limbs[limbName]
    if ampStatus.isCut ~= nil then limbData.isCut = ampStatus.isCut end
    if ampStatus.isInfected ~= nil then limbData.isInfected = ampStatus.isInfected end
    if ampStatus.isOperated ~= nil then limbData.isOperated = ampStatus.isOperated end
    if ampStatus.isCicatrized ~= nil then limbData.isCicatrized = ampStatus.isCicatrized end
    if ampStatus.isCauterized ~= nil then limbData.isCauterized = ampStatus.isCauterized end
    if ampStatus.isVisible ~= nil then limbData.isVisible = ampStatus.isVisible end

    if cicatrizationTime ~= nil then limbData.cicatrizationTime = cicatrizationTime end
end

--* Update statuses of a limb *--

---Decreases the cicatrization time
---@param limbName string
function ModDataHandler:decreaseCicatrizationTime(limbName)
    self.tocData.limbs[limbName].cicatrizationTime = self.tocData.limbs[limbName].cicatrizationTime - 1
end

--* Global Mod Data Handling *--

function ModDataHandler:apply()
    ModData.transmit(CommandsData.GetKey(self.username))
end

function ModDataHandler.ReceiveData(key, table)
    if not isClient() then
        TOC_DEBUG.print("SP, skipping ModDataHandler.ReceiveData")
    end
    TOC_DEBUG.print("receiving data from server")

    if key == "TOC_Bob" then return end     -- TODO Fix this

    TOC_DEBUG.print("receive data for " .. key)
    if table == {} or table == nil then
        TOC_DEBUG.print("table is nil... returning")
        return
    end

    -- Create ModDataHandler instance if there was none for that user and reapply the correct ModData table as a reference
    local username = key:sub(5)
    ModDataHandler.GetInstance(username):reapplyTocData(key, table) --tocData = table        -- TODO Ugly, use a setter
end
Events.OnReceiveGlobalModData.Add(ModDataHandler.ReceiveData)

-------------------

---@param username string?
---@return ModDataHandler
function ModDataHandler.GetInstance(username)
    if username == nil or username == "Bob" then
        username = getPlayer():getUsername()
    end

    if ModDataHandler.instances[username] == nil then
        return ModDataHandler:new(username)
    else
        return ModDataHandler.instances[username]
    end
end

return ModDataHandler