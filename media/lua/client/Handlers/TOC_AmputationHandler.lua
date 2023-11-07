local ModDataHandler = require("Handlers/TOC_ModDataHandler")
local StaticData = require("TOC_StaticData")
local CommonMethods = require("TOC_Common")

---------------------------

-- TODO Add Bandages, Torniquet, etc.
--- This will be run EXCLUSIVELY on the client which is getting the amputation
---@class AmputationHandler
---@field patient IsoPlayer
---@field limbName string
---@field bodyPartType BodyPartType
---@field surgeonPl IsoPlayer?
local AmputationHandler = {}


---@param limbName string
---@param surgeonPl IsoPlayer?
---@return AmputationHandler
function AmputationHandler:new(limbName, surgeonPl)
    local o = {}
    setmetatable(o, self)
    self.__index = self

    o.patient = getPlayer()
    o.limbName = limbName
    o.bodyPartType = BodyPartType[self.limbName]
    if surgeonPl then
        o.surgeonPl = surgeonPl
    else
        o.surgeonPl = o.patient
    end

    AmputationHandler.instance = o
    return o
end


--* Main methods *--

---Starts bleeding from the point where the saw is being used
function AmputationHandler:damageDuringAmputation()
    print("TOC: Damage patient")
    local bodyDamage = self.patient:getBodyDamage()
    local bodyDamagePart = bodyDamage:getBodyPart(self.bodyPartType)

    bodyDamagePart:setBleeding(true)
    bodyDamagePart:setCut(true)
    bodyDamagePart:setBleedingTime(ZombRand(10, 20))
end

---Execute the amputation
function AmputationHandler:execute()

    -- TODO Calculate surgeonStats
    local surgeonFactor = 100


    local patientStats = self.patient:getStats()
    local bd = self.patient:getBodyDamage()
    local bodyPart = bd:getBodyPart(self.bodyPartType)
    local baseDamage = StaticData.LIMBS_BASE_DAMAGE[self.limbName]

    -- Set the bleeding and all the damage stuff in that part
    bodyPart:AddDamage(baseDamage - surgeonFactor)
    bodyPart:setAdditionalPain(baseDamage - surgeonFactor)
    bodyPart:setBleeding(true)
    bodyPart:setBleedingTime(baseDamage - surgeonFactor)
    bodyPart:setDeepWounded(true)
    bodyPart:setDeepWoundTime(baseDamage - surgeonFactor)
    patientStats:setEndurance(surgeonFactor)
    patientStats:setStress(baseDamage - surgeonFactor)

    -- Set the data in modData
    ModDataHandler.GetInstance():setCutLimb(self.limbName, false, false, false, surgeonFactor)

    -- Give the player the correct amputation item
end

---Force the execution of the amputation for a trait
function AmputationHandler:executeForTrait()
    ModDataHandler.GetInstance():setCutLimb(self.limbName, true, true, true, 0)
end

---Deletes the instance
function AmputationHandler:close()
    AmputationHandler.instance = nil
end

--* Amputation Items *--

---Search and deletes an old amputation clothing item
---@private
function AmputationHandler:deleteOldAmputationItem()
    local side = CommonMethods.GetSide(self.limbName)

    for partName, _ in pairs(StaticData.PARTS_STRINGS) do
        local othLimbName = partName .. "_" .. side
        local othClothingItemName = StaticData.AMPUTATION_CLOTHING_ITEM_BASE .. othLimbName
        local othClothingItem = self.patient:getInventory():FindAndReturn(othClothingItemName)
        if othClothingItem then
            self.patient:getInventory():Remove(othClothingItem) -- It accepts it as an Item, not a string
            print("TOC: found and deleted " .. othClothingItemName)
            return
        end
    end
end

---Returns the correct index for the textures of the amputation
---@param isCicatrized boolean
---@return number
---@private
function AmputationHandler:getAmputationTexturesIndex(isCicatrized)
    local textureString = self.patient:getHumanVisual():getSkinTexture()
    local isHairy = string.find(textureString, "a$")
    -- Hairy bodies
    if isHairy then
        textureString = textureString:sub(1, -2)      -- Removes b at the end to make it compatible
    end

    local matchedIndex = string.match(textureString, "%d$")

    -- TODO Rework this
    if isHairy then
        matchedIndex = matchedIndex + 5
    end

    if isCicatrized then
        if isHairy then
            matchedIndex = matchedIndex + 5           -- to use the cicatrized texture on hairy bodies
        else
            matchedIndex = matchedIndex + 10          -- cicatrized texture only, no hairs
        end
    end

    return matchedIndex - 1
end

---Spawns and equips the correct amputation item to the player. In case there was another amputation on the same side, it's gonna get deleted
---@private
function AmputationHandler:spawnAmputationItem()
    -- TODO Check if there are previous amputation clothing items on that side and deletes them

    local clothingItem = self.patient:getInventory():AddItem(StaticData.AMPUTATION_CLOTHING_ITEM_BASE .. self.limbName)
    local texId = self:getAmputationTexturesIndex(false)

    ---@cast clothingItem InventoryItem
    clothingItem:getVisual():setTextureChoice(texId) -- it counts from 0, so we have to subtract 1
    self.patient:setWornItem(clothingItem:getBodyLocation(), clothingItem)
end



return AmputationHandler