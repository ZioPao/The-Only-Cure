local StaticData = require("TOC/StaticData")

----------------

--- Handle all mod data related stuff
---@class ModDataHandler
---@field playerObj IsoPlayer
---@field tocData tocModData 
local ModDataHandler = {}
ModDataHandler.instances = {}


function ModDataHandler.AddExternalTocData(username, tocData)

end


---@param username string
---@param tocData tocModData
---@return ModDataHandler
function ModDataHandler:new(username, tocData)
    local o = {}
    setmetatable(o, self)
    self.__index = self
    -- Instead of requiring a player, to make it compatible in a MP env, we should require the table containing the modData for the init

    o.tocData = tocData
    ModDataHandler.instances[username] = o

    return o
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


---@param username string?
---@return ModDataHandler?
function ModDataHandler.GetInstance(username)

    if username == nil then username = getPlayer():getUsername() end

    if ModDataHandler.instances[username] ~= nil then
        return ModDataHandler.instances[username]
    else
        return nil      -- TODO This isn't exactly good
        --return ModDataHandler:new(getPlayer())
    end
end

return ModDataHandler