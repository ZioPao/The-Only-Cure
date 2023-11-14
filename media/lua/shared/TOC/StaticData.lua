---@alias partData { isCut : boolean?, isInfected : boolean?, isOperated : boolean?, isCicatrized : boolean?, isCauterized : boolean?, isVisible : boolean?, cicatrizationTime : number }
---@alias limbsTable {Hand_L : partData, ForeArm_L : partData, UpperArm_L : partData, Hand_R : partData, ForeArm_R : partData, UpperArm_R : partData }
---@alias prosthesisData {isEquipped : boolean, prostFactor : number }
---@alias prosthesesTable {top : table, bottom : table }
---@alias tocModData { limbs : limbsTable, prostheses : prosthesesTable, isIgnoredPartInfected : boolean, isAnyLimbCut : boolean }
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

StaticData.SIDES_IND_STR = {
    R = "R",
    L = "L"
}
StaticData.PARTS_IND_STR = {
    Hand = "Hand",
    ForeArm = "ForeArm",
    UpperArm = "UpperArm"
}
StaticData.MOD_BODYLOCS_BASE_IND_STR = {
    TOC_ArmProst = "TOC_ArmProst",
    TOC_Arm = "TOC_Arm",
}

-- No "MAX" here.
StaticData.IGNORED_BODYLOCS_IND_BPT = {
    BodyPartType.Foot_L, BodyPartType.Foot_R, BodyPartType.Groin, BodyPartType.Head, 
    BodyPartType.LowerLeg_L, BodyPartType.LowerLeg_R, BodyPartType.Neck, BodyPartType.Torso_Lower, 
    BodyPartType.Torso_Upper, BodyPartType.UpperLeg_L, BodyPartType.UpperLeg_R
}


-- Assembled BodyParts string
StaticData.LIMBS_STR = {}
StaticData.LIMBS_DEPENDENCIES_IND_STR = {}
StaticData.LIMBS_CICATRIZATION_TIME_IND_NUM = {}
StaticData.LIMBS_BASE_DAMAGE_IND_NUM = {}
StaticData.LIMBS_TIME_MULTIPLIER_IND_NUM = {}
StaticData.BODYLOCS_IND_BPT = {}

local function AssembleHandData(assembledName)
    StaticData.LIMBS_BASE_DAMAGE_IND_NUM[assembledName] = 60
    StaticData.LIMBS_CICATRIZATION_TIME_IND_NUM[assembledName] = 1700
    StaticData.LIMBS_TIME_MULTIPLIER_IND_NUM[assembledName] = 2
    StaticData.LIMBS_DEPENDENCIES_IND_STR[assembledName] = {}
end

local function AssembleForearmData(assembledName, side)
    StaticData.LIMBS_BASE_DAMAGE_IND_NUM[assembledName] = 80
    StaticData.LIMBS_CICATRIZATION_TIME_IND_NUM[assembledName] = 1800
    StaticData.LIMBS_TIME_MULTIPLIER_IND_NUM[assembledName] = 3
    StaticData.LIMBS_DEPENDENCIES_IND_STR[assembledName] = { StaticData.PARTS_IND_STR.Hand .. "_" .. side }
end

local function AssembleUpperarmData(assembledName, side)
    StaticData.LIMBS_BASE_DAMAGE_IND_NUM[assembledName] = 100
    StaticData.LIMBS_CICATRIZATION_TIME_IND_NUM[assembledName] = 2000
    StaticData.LIMBS_TIME_MULTIPLIER_IND_NUM[assembledName] = 4
    StaticData.LIMBS_DEPENDENCIES_IND_STR[assembledName] = { StaticData.PARTS_IND_STR.Hand .. "_" .. side,
        StaticData.PARTS_IND_STR.ForeArm .. "_" .. side }
end

for side, _ in pairs(StaticData.SIDES_IND_STR) do
    for part, _ in pairs(StaticData.PARTS_IND_STR) do
        local assembledName = part .. "_" .. side

        -- Assembled strings
        table.insert(StaticData.LIMBS_STR, assembledName)   -- We need a table like this to cycle through it easily
        StaticData.BODYLOCS_IND_BPT[assembledName] = BodyPartType[assembledName]

        -- Dependencies and cicatrization time
        if part == StaticData.PARTS_IND_STR.Hand then
            AssembleHandData(assembledName)
        elseif part == StaticData.PARTS_IND_STR.ForeArm then
            AssembleForearmData(assembledName, side)
        elseif part == StaticData.PARTS_IND_STR.UpperArm then
            AssembleUpperarmData(assembledName, side)
        end
    end
end

-----------------
--* Prostheses

StaticData.PROSTHESES_GROUPS = {
    top = "top",
    bottom = "bottom"
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
-- TODO We need male variations
StaticData.HEALTH_PANEL_TEXTURES = {

    Female = {
        Hand_L = getTexture("media/ui/Hand_L.png"),
        ForeArm_L = getTexture("media/ui/ForeArm_L.png"),
        UpperArm_L = getTexture("media/ui/UpperArm_L.png"),

        Hand_R = getTexture("media/ui/Hand_R.png"),
        ForeArm_R = getTexture("media/ui/ForeArm_R.png"),
        UpperArm_R = getTexture("media/ui/UpperArm_R.png")
    },

    Male = {
        Hand_L = getTexture("media/ui/Hand_L.png"),
        ForeArm_L = getTexture("media/ui/ForeArm_L.png"),
        UpperArm_L = getTexture("media/ui/UpperArm_L.png"),

        Hand_R = getTexture("media/ui/Hand_R.png"),
        ForeArm_R = getTexture("media/ui/ForeArm_R.png"),
        UpperArm_R = getTexture("media/ui/UpperArm_R.png")
    }

}

StaticData.AMPUTATION_CLOTHING_ITEM_BASE = "TOC.Amputation_"


return StaticData
