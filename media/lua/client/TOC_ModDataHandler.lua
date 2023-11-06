local StaticData = require("TOC_StaticData")

----------------
---@alias amputationTable { isCut : boolean?, isInfected : boolean?, isOperated : boolean?, isCicatrized : boolean?, isCauterized : boolean?, isDependant : boolean? }

----------------
-- TODO This class should handle all the stuff related to the mod data

---@class ModDataHandler
---@field playerObj IsoPlayer
local ModDataHandler = {}

---@param playerObj IsoPlayer
---@return ModDataHandler
function ModDataHandler:new(playerObj)
    local o = {}
    setmetatable(o, self)
    self.__index = self

    o.playerObj = playerObj

    ModDataHandler.instance = o

    return o
end

---Setup a newly instanced ModDataHandler
function ModDataHandler:setup()
    local modData = self.playerObj:getModData()[StaticData.MOD_NAME]
    if modData == nil or modData.Hand_L == nil or modData.Hand_L.isCut == nil then
        self:createData()
    end
    -- TODO Check compatibility or do we just skip it at this point?

end

function ModDataHandler:createData()
    print("TOC: createData")

    local modData = self.playerObj:getModData()
    modData[StaticData.MOD_NAME] = {}

    ---@type amputationTable
    local defaultParams = {isCut = false, isInfected = false, isOperated = false, isCicatrized = false, isCauterized = false, isDependant = false}

    local test = StaticData.LIMBS_STRINGS
    -- Initialize limbs
    for i=1, #StaticData.LIMBS_STRINGS do
        local limbName = StaticData.LIMBS_STRINGS[i]
        modData[StaticData.MOD_NAME][limbName] = {}
        self:setLimbParams(StaticData.LIMBS_STRINGS[i], defaultParams, 0)
    end
end


-----------------
--* Setters *--

---Set isCut
---@param limbName string
---@param isCut boolean
function ModDataHandler:setIsCut(limbName, isCut)
    self.playerObj:getModData()[StaticData.MOD_NAME][limbName].isCut = isCut
end

---Set isInfected
---@param limbName string
---@param isInfected boolean
function ModDataHandler:setIsInfected(limbName, isInfected)
    self.playerObj:getModData()[StaticData.MOD_NAME][limbName].isInfected = isInfected
end

-----------------
--* Getters *--
---Get isCut
---@param limbName string
---@return boolean
function ModDataHandler:getIsCut(limbName)
    return self.playerObj:getModData()[StaticData.MOD_NAME][limbName].isCut
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

    ---@type amputationTable
    local params = {isCut = true, isInfected = false, isOperated = isOperated, isCicatrized = isCicatrized, isCauterized = isCauterized, isDependant = false}
    self:setLimbParams(limbName, params, cicatrizationTime)


    for i=1, #StaticData.LIMBS_DEPENDENCIES[limbName] do
        local dependedLimbName = StaticData.LIMBS_DEPENDENCIES[limbName][i]

        -- We don't care about isOperated, isCicatrized, isCauterized since this is depending on another limb
        -- Same story for cicatrizationTime, which will be 0
        self:setLimbParams(dependedLimbName, {isCut = true, isInfected = false, isDependant = true}, 0)
    end
end


---Internal use only, set a limb data
---@param limbName string
---@param ampStatus amputationTable {isCut, isInfected, isOperated, isCicatrized, isCauterized, isDependant}
---@param cicatrizationTime integer?
---@private
function ModDataHandler:setLimbParams(limbName, ampStatus, cicatrizationTime)
    local limbData = self.playerObj:getModData()[StaticData.MOD_NAME][limbName]
    if ampStatus.isCut ~= nil then limbData.isCut = ampStatus.isCut end
    if ampStatus.isInfected ~= nil then limbData.isInfected = ampStatus.isInfected end
    if ampStatus.isOperated ~= nil then limbData.isOperated = ampStatus.isOperated end
    if ampStatus.isCicatrized ~= nil then limbData.isCicatrized = ampStatus.isCicatrized end
    if ampStatus.isCauterized ~= nil then limbData.isCauterized = ampStatus.isCauterized end
    if ampStatus.isDependant ~= nil then limbData.isDependant = ampStatus.isDependant end

    if cicatrizationTime ~= nil then limbData.cicatrizationTime = cicatrizationTime end
end



return ModDataHandler