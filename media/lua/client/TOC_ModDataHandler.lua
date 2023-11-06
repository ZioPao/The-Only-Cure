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
    if self.modData == nil then self:createData() end
    -- TODO Check compatibility or do we just skip it at this point?

end

function ModDataHandler:createData()
    print("TOC: createData")

    self.playerObj:getModData()[StaticData.MOD_NAME] = {}

    -- Initialize limbs
    for i=1, #StaticData.LIMBS_STRINGS do
        self:setLimbParams(StaticData.LIMBS_STRINGS[i], false, false, false, false, false, false)
    end
end


--* Limbs data handling *--

---Set a limb and its dependend limbs as cut
---@param limbName string
---@param amputationStatus amputationTable {isOperated, isCicatrized, isCauterized}
---@param surgeonFactor number
function ModDataHandler:setCutLimb(limbName, amputationStatus, surgeonFactor)
    local cicatrizationTime = -1
    if amputationStatus.isCicatrized == false or amputationStatus.isCauterized == false then
        cicatrizationTime = StaticData.LIMBS_CICATRIZATION_TIME[limbName] - surgeonFactor
    end

    ---@type amputationTable
    local params = {isCut = true, isInfected = false, isOperated = amputationStatus.isOperated, isCicatrized = amputationStatus.isCicatrized, isCauterized = amputationStatus.isCauterized, isDependant = false}
    self:setLimbParams(limbName, params, cicatrizationTime)

    local dependentParams = {isCut = true, isInfected = false, isDependant = true}

    for i=1, #StaticData.LIMBS_DEPENDENCIES[limbName] do
        local dependedLimbName = StaticData.LIMBS_DEPENDENCIES[limbName][i]

        -- We don't care about isOperated, isCicatrized and isCauterized since this is depending on another limb
        self:setLimbParams(dependedLimbName, dependentParams, cicatrizationTime)
    end
end


---Internal use only, set a limb data
---@param limbName string
---@param amputationStatus amputationTable {isCut, isInfected, isOperated, isCicatrized, isCauterized, isDependant}
---@param cicatrizationTime integer
---@private
function ModDataHandler:setLimbParams(limbName, amputationStatus, cicatrizationTime)
    local limbData = self.playerObj:getModData()[StaticData.MOD_NAME][limbName]
    if amputationStatus.isCut ~= nil then
        limbData.isCut = amputationStatus.isCut
    end
    if amputationStatus.isInfected ~= nil then
        limbData.isInfected = amputationStatus.isInfected
    end
    if amputationStatus.isOperated ~= nil then
        limbData.isOperated = amputationStatus.isOperated
    end
    if amputationStatus.isCicatrized ~= nil then
        limbData.isCicatrized = amputationStatus.isCicatrized
    end
    if amputationStatus.isCauterized ~= nil then
        limbData.isCauterized = amputationStatus.isCauterized
    end
    if amputationStatus.isDependant ~= nil then
        limbData.isDependant = amputationStatus.isDependant
    end
    if cicatrizationTime ~= nil then
        limbData.cicatrizationTime = cicatrizationTime
    end
end



return ModDataHandler