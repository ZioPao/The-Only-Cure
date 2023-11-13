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

    ModData.request(key)
    o.tocData = ModData.get(key)

    if isResetForced or o.tocData == nil or o.tocData.Hand_L == nil or o.tocData.Hand_L.isCut == nil then
        TOC_DEBUG.print("tocData in ModDataHandler for " .. username .. " is nil, creating it now")
        self:setup(key)
    end
    -- Transmit it to the server
    ModData.transmit(key)

    ModDataHandler.instances[username] = o

    return o
end

---Setup a new toc mod data data class
---@param key string
function ModDataHandler:setup(key)

    ---@type tocModData
    self.tocData = {
        -- Generic stuff that does not belong anywhere else
        isIgnoredPartInfected = false,
        isAnyLimbCut = false
    }

    ---@type partData
    local defaultParams = {isCut = false, isInfected = false, isOperated = false, isCicatrized = false, isCauterized = false, isVisible = false}

    -- Initialize limbs
    for i=1, #StaticData.LIMBS_STRINGS do
        local limbName = StaticData.LIMBS_STRINGS[i]
        self.tocData[limbName] = {}
        self:setLimbParams(StaticData.LIMBS_STRINGS[i], defaultParams, 0)
    end

    -- Add it to global mod data
    ModData.add(key, self.tocData)


end


-----------------
--* Setters *--

---Set a generic boolean that toggles varies function of the mod
---@param isAnyLimbCut boolean
function ModDataHandler:setIsAnyLimbCut(isAnyLimbCut)
    self.tocData.isAnyLimbCut = isAnyLimbCut
end

---Set isCut 
---@param limbName string
---@param isCut boolean
function ModDataHandler:setIsCut(limbName, isCut)
    self.tocData[limbName].isCut = isCut
end

---Set isInfected
---@param limbName string
---@param isInfected boolean
function ModDataHandler:setIsInfected(limbName, isInfected)
    self.tocData[limbName].isInfected = isInfected
end

---Set isIgnoredPartInfected
---@param isIgnoredPartInfected boolean
function ModDataHandler:setIsIgnoredPartInfected(isIgnoredPartInfected)
    self.tocData.isIgnoredPartInfected = isIgnoredPartInfected
end

-----------------
--* Getters *--

---Set a generic boolean that toggles varies function of the mod
---@return boolean
function ModDataHandler:getIsAnyLimbCut()
    return self.tocData.isAnyLimbCut
end

---Get isCut
---@param limbName string
---@return boolean
function ModDataHandler:getIsCut(limbName)
    return self.tocData[limbName].isCut
end

---Get isIgnoredPartInfected
---@return boolean
function ModDataHandler:getIsIgnoredPartInfected()
    return self.tocData.isIgnoredPartInfected
end

---Get isVisible
---@return boolean
function ModDataHandler:getIsVisible(limbName)
    return self.tocData[limbName].isVisible
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
        cicatrizationTime = StaticData.LIMBS_CICATRIZATION_TIME[limbName] - surgeonFactor
    end

    ---@type partData
    local params = {isCut = true, isInfected = false, isOperated = isOperated, isCicatrized = isCicatrized, isCauterized = isCauterized, isVisible = true}
    self:setLimbParams(limbName, params, cicatrizationTime)

    for i=1, #StaticData.LIMBS_DEPENDENCIES[limbName] do
        local dependedLimbName = StaticData.LIMBS_DEPENDENCIES[limbName][i]

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
    local limbData = self.tocData[limbName]
    if ampStatus.isCut ~= nil then limbData.isCut = ampStatus.isCut end
    if ampStatus.isInfected ~= nil then limbData.isInfected = ampStatus.isInfected end
    if ampStatus.isOperated ~= nil then limbData.isOperated = ampStatus.isOperated end
    if ampStatus.isCicatrized ~= nil then limbData.isCicatrized = ampStatus.isCicatrized end
    if ampStatus.isCauterized ~= nil then limbData.isCauterized = ampStatus.isCauterized end
    if ampStatus.isVisible ~= nil then limbData.isVisible = ampStatus.isVisible end

    if cicatrizationTime ~= nil then limbData.cicatrizationTime = cicatrizationTime end
end


--* Global Mod Data Handling *--

function ModDataHandler:apply()
    ModData.transmit(CommandsData.GetKey(self.username))
end

function ModDataHandler.ReceiveData(key, table)
    TOC_DEBUG.print("receive data for " .. key)
    if table == {} or table == nil then
        TOC_DEBUG.print("table is nil... returning")
        return
    end
    ModData.add(key, table)     -- Add it to the client mod data (not sure)
    local username = key:sub(5)
    ModDataHandler.GetInstance(username)
end
Events.OnReceiveGlobalModData.Add(ModDataHandler.ReceiveData)

-------------------

---@param username string?
---@return ModDataHandler
function ModDataHandler.GetInstance(username)
    if username == nil then
        username = getPlayer():getUsername()
    end

    if ModDataHandler.instances[username] == nil then
        return ModDataHandler:new(username)
    else
        return ModDataHandler.instances[username]
    end
end

return ModDataHandler