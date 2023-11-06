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
---@param ampStatus amputationTable {isOperated, isCicatrized, isCauterized}
---@param surgeonFactor number
function ModDataHandler:setCutLimb(limbName, ampStatus, surgeonFactor)
    local cicatrizationTime = -1
    if ampStatus.isCicatrized == false or ampStatus.isCauterized == false then
        cicatrizationTime = StaticData.LIMBS_CICATRIZATION_TIME[limbName] - surgeonFactor
    end

    ---@type amputationTable
    local params = {isCut = true, isInfected = false, isOperated = ampStatus.isOperated, isCicatrized = ampStatus.isCicatrized, isCauterized = ampStatus.isCauterized, isDependant = false}
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