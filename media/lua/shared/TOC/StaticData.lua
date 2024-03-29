---@alias partDataType { isCut : boolean?, isInfected : boolean?, isOperated : boolean?, isCicatrized : boolean?, isCauterized : boolean?, isVisible : boolean?, woundDirtyness : number, cicatrizationTime : number }
---@alias limbsTable {Hand_L : partDataType, ForeArm_L : partDataType, UpperArm_L : partDataType, Hand_R : partDataType, ForeArm_R : partDataType, UpperArm_R : partDataType }
---@alias prosthesisData {isProstEquipped : boolean, prostFactor : number }
---@alias prosthesesTable {Top_L : prosthesisData, Top_R : prosthesisData }     -- TODO add Bottom_L and Bottom_R
---@alias tocModDataType { limbs : limbsTable, prostheses : prosthesesTable, isIgnoredPartInfected : boolean, isAnyLimbCut : boolean }
---------------------------


-- _STR = Only strings, no index
-- _IND_STR =  indexed Strings
-- _IND_BPT = Indexed BodyPartType

-- PART = Single part, could be hand, forearm, etc
-- LIMB = Part + side
-- BODYLOCS = Body Locations



local StaticData = {}

---Mod name, used to setup Global Mod Data and various stuff
StaticData.MOD_NAME = "TOC"

-------------------------
--* Base


-- TODO Add references inside tables instead of making multiple tables

StaticData.SIDES_IND_STR = {
    R = "R",
    L = "L"
}
StaticData.SIDES_STR = {
    "R", "L"
}
StaticData.PARTS_IND_STR = {
    Hand = "Hand",
    ForeArm = "ForeArm",
    UpperArm = "UpperArm"
}
StaticData.PARTS_STR = {
    "Hand",
    "ForeArm",
    "UpperArm"
}


StaticData.MOD_BODYLOCS_BASE_IND_STR = {
    TOC_ArmProst = "TOC_ArmProst",
    TOC_LegProst = "TOC_LegProst",
    TOC_Arm = "TOC_Arm",
}

-- No "MAX" here.
StaticData.IGNORED_BODYLOCS_BPT = {
    BodyPartType.Foot_L, BodyPartType.Foot_R, BodyPartType.Groin, BodyPartType.Head,
    BodyPartType.LowerLeg_L, BodyPartType.LowerLeg_R, BodyPartType.Neck, BodyPartType.Torso_Lower,
    BodyPartType.Torso_Upper, BodyPartType.UpperLeg_L, BodyPartType.UpperLeg_R
}


-- Assembled BodyParts string
StaticData.LIMBS_STR = {}
StaticData.LIMBS_IND_STR = {}
StaticData.LIMBS_DEPENDENCIES_IND_STR = {}
StaticData.LIMBS_ADJACENT_IND_STR = {}
StaticData.LIMBS_CICATRIZATION_TIME_IND_NUM = {}
StaticData.LIMBS_BASE_DAMAGE_IND_NUM = {}
StaticData.LIMBS_TIME_MULTIPLIER_IND_NUM = {}
StaticData.BODYLOCS_IND_BPT = {}


-- FIXME You weren't considering surgeonFactor, which decreases that base time. Fuck mod 60
-- CicatrizationBaseTime should be mod 60 since we're using EveryHours to update the cicatrizationTime

---@param assembledName string
---@param side string
local function AssembleHandData(assembledName, side)
    StaticData.LIMBS_BASE_DAMAGE_IND_NUM[assembledName] = 60
    StaticData.LIMBS_CICATRIZATION_TIME_IND_NUM[assembledName] = 120
    StaticData.LIMBS_TIME_MULTIPLIER_IND_NUM[assembledName] = 2
    StaticData.LIMBS_DEPENDENCIES_IND_STR[assembledName] = {}
    StaticData.LIMBS_ADJACENT_IND_STR[assembledName] = StaticData.PARTS_IND_STR.ForeArm .. "_" .. side
end

---@param assembledName string
---@param side string
local function AssembleForearmData(assembledName, side)
    StaticData.LIMBS_BASE_DAMAGE_IND_NUM[assembledName] = 80
    StaticData.LIMBS_CICATRIZATION_TIME_IND_NUM[assembledName] = 144
    StaticData.LIMBS_TIME_MULTIPLIER_IND_NUM[assembledName] = 3
    StaticData.LIMBS_DEPENDENCIES_IND_STR[assembledName] = { StaticData.PARTS_IND_STR.Hand .. "_" .. side }
    StaticData.LIMBS_ADJACENT_IND_STR[assembledName] = StaticData.PARTS_IND_STR.UpperArm .. "_" .. side
end

---@param assembledName string
---@param side string
local function AssembleUpperarmData(assembledName, side)
    StaticData.LIMBS_BASE_DAMAGE_IND_NUM[assembledName] = 100
    StaticData.LIMBS_CICATRIZATION_TIME_IND_NUM[assembledName] = 192
    StaticData.LIMBS_TIME_MULTIPLIER_IND_NUM[assembledName] = 4
    StaticData.LIMBS_DEPENDENCIES_IND_STR[assembledName] = { StaticData.PARTS_IND_STR.Hand .. "_" .. side,
        StaticData.PARTS_IND_STR.ForeArm .. "_" .. side }
    StaticData.LIMBS_ADJACENT_IND_STR[assembledName] = "Torso_Upper"
end

for side, _ in pairs(StaticData.SIDES_IND_STR) do
    for part, _ in pairs(StaticData.PARTS_IND_STR) do
        local assembledName = part .. "_" .. side

        -- Assembled strings
        table.insert(StaticData.LIMBS_STR, assembledName)   -- We need a table like this to cycle through it easily
        StaticData.LIMBS_IND_STR[assembledName] = assembledName
        StaticData.BODYLOCS_IND_BPT[assembledName] = BodyPartType[assembledName]

        -- Dependencies and cicatrization time
        if part == StaticData.PARTS_IND_STR.Hand then
            AssembleHandData(assembledName, side)
        elseif part == StaticData.PARTS_IND_STR.ForeArm then
            AssembleForearmData(assembledName, side)
        elseif part == StaticData.PARTS_IND_STR.UpperArm then
            AssembleUpperarmData(assembledName, side)
        end
    end
end

-----------------
--* Amputation Groups

StaticData.AMP_GROUPS_BASE_IND_STR = {
    Top = "Top",
    Bottom = "Bottom"
}

StaticData.AMP_GROUPS_IND_STR = {}
StaticData.AMP_GROUPS_STR = {}

for side, _ in pairs(StaticData.SIDES_IND_STR) do
    for group, _ in pairs(StaticData.AMP_GROUPS_BASE_IND_STR) do
        local sidedGroup = group .. "_" .. side
        StaticData.AMP_GROUPS_IND_STR[sidedGroup] = sidedGroup
        table.insert(StaticData.AMP_GROUPS_STR, sidedGroup)
    end
end


-- TODO We can do this in one pass if we do it before

StaticData.AMP_GROUP_TO_LIMBS_MATCH_IND_STR = {}  -- THis is probably unnecessary
StaticData.LIMBS_TO_AMP_GROUPS_MATCH_IND_STR = {}

for side, _ in pairs(StaticData.SIDES_IND_STR) do
    for part, _ in pairs(StaticData.PARTS_IND_STR) do
        local limbName = part .. "_" .. side
        local group
        if part == StaticData.PARTS_IND_STR.Hand or part == StaticData.PARTS_IND_STR.ForeArm or part == StaticData.PARTS_IND_STR.UpperArm then
            group = StaticData.AMP_GROUPS_BASE_IND_STR.Top
        else
            group = StaticData.AMP_GROUPS_BASE_IND_STR.Bottom
        end

        local sidedGroup = group .. "_" .. side
        if StaticData.AMP_GROUP_TO_LIMBS_MATCH_IND_STR[sidedGroup] == nil then
            StaticData.AMP_GROUP_TO_LIMBS_MATCH_IND_STR[sidedGroup] = {}
        end
        table.insert(StaticData.AMP_GROUP_TO_LIMBS_MATCH_IND_STR[sidedGroup], limbName)

        StaticData.LIMBS_TO_AMP_GROUPS_MATCH_IND_STR[limbName] = sidedGroup

    end
end


StaticData.TOURNIQUET_BODYLOCS_TO_GROUPS_IND_STR = {
    ["HandsLeft"] = StaticData.AMP_GROUPS_IND_STR.Top_L,
    ["HandsRight"] = StaticData.AMP_GROUPS.IND_STR.Top_R
}





-----------------
--* Traits

-- Link a trait to a specific body part
StaticData.TRAITS_BP = {
    AmputeeHand = "Hand_L",
    AmputeeLowerArm = "ForeArm_L",
    AmputeeUpeerArm = "UpperArm_L"
}

-----------------
--* Visuals and clothing

--- Textures
StaticData.HEALTH_PANEL_TEXTURES = {

    Female = {
        Hand_L = getTexture("media/ui/Female/Hand_L.png"),
        ForeArm_L = getTexture("media/ui/Female/ForeArm_L.png"),
        UpperArm_L = getTexture("media/ui/Female/UpperArm_L.png"),

        Hand_R = getTexture("media/ui/Female/Hand_R.png"),
        ForeArm_R = getTexture("media/ui/Female/ForeArm_R.png"),
        UpperArm_R = getTexture("media/ui/Female/UpperArm_R.png")
    },

    Male = {
        Hand_L = getTexture("media/ui/Male/Hand_L.png"),
        ForeArm_L = getTexture("media/ui/Male/ForeArm_L.png"),
        UpperArm_L = getTexture("media/ui/Male/UpperArm_L.png"),

        Hand_R = getTexture("media/ui/Male/Hand_R.png"),
        ForeArm_R = getTexture("media/ui/Male/ForeArm_R.png"),
        UpperArm_R = getTexture("media/ui/Male/UpperArm_R.png")
    },

    ProstArm = {
        L = getTexture("media/ui/ProstArm_L.png"),
        R = getTexture("media/ui/ProstArm_R.png")
    }

}

StaticData.AMPUTATION_CLOTHING_ITEM_BASE = "TOC.Amputation_"


------------------
--* Items check

local sawObj = InventoryItemFactory.CreateItem("Base.Saw")
local gardenSawObj = InventoryItemFactory.CreateItem("Base.GardenSaw")

StaticData.SAWS_NAMES_IND_STR = {
    saw = sawObj:getName(),
    gardenSaw = gardenSawObj:getName()
}

StaticData.SAWS_TYPES_IND_STR = {
    saw = sawObj:getType(),
    gardenSaw = gardenSawObj:getType()
}


return StaticData
