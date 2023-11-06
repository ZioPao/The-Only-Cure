local StaticData = require("TOC_StaticData")

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
    for i=1, #StaticData.BP_STRINGS do
        self:setLimbParams(StaticData.BP_STRINGS[i], false, false, false, false, false, false)
    end
end

------

---Set a limb and its dependend limbs as cut
---@param limbName string
function ModDataHandler:setCutLimb(limbName, isOperated, isCicatrized, isCauterized)
    self:setLimbParams(limbName, true, false, isOperated, isCicatrized, isCauterized, false)

    for i=1, #StaticData.LIMB_DEPENDENCIES.limbName do
        local dependedLimbName = StaticData.LIMB_DEPENDENCIES.limbName[i]

        -- We don't care about isOperated, isCicatrized and isCauterized since this is depending on another limb
        self:setLimbParams(dependedLimbName, true, false, nil, nil, nil, true)
    end
end



---Internal use only
---@param limbName string
---@param isCut boolean?
---@param isInfected boolean?
---@param isOperated boolean?
---@param isCicatrized boolean?
---@param isCauterized boolean?
---@param isDependant boolean?
---@private
function ModDataHandler:setLimbParams(limbName, isCut, isInfected, isOperated, isCicatrized, isCauterized, isDependant)
    local limbData = self.playerObj:getModData()[StaticData.MOD_NAME][limbName]
    if isCut ~= nil then
        limbData.isCut = isCut
    end
    if isInfected ~= nil then
        limbData.isInfected = isInfected
    end
    if isOperated ~= nil then
        limbData.isOperated = isOperated
    end
    if isCicatrized ~= nil then
        limbData.isCicatrized = isCicatrized
    end
    if isCauterized ~= nil then
        limbData.isCauterized = isCauterized
    end
    if isDependant ~= nil then
        limbData.isDependant = isDependant
    end
end



return ModDataHandler