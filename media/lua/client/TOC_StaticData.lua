local StaticData = {}

StaticData.MOD_NAME = "TOC"


StaticData.PARTS_STRINGS = {
    Hand = "Hand",
    ForeArm = "ForeArm",
    UpperArm = "UpperArm"
}

StaticData.IGNORED_PARTS_STRINGS = { "Foot_L", "Foot_R", "Groin", "Head", "LowerLeg_L", "LowerLeg_R", "MAX", "Neck", "Torso_Lower", "Torso_Upper", "UpperLeg_L", "UpperLeg_R" }

StaticData.SIDES_STRINGS = {
    R = "R",
    L = "L"
}
-- Assembled BodyParts string
---@enum
StaticData.LIMBS_STRINGS = {}
StaticData.BODYPARTSTYPES_ENUM = {}
StaticData.LIMBS_DEPENDENCIES = {}
StaticData.LIMBS_CICATRIZATION_TIME = {}
StaticData.LIMBS_BASE_DAMAGE = {}


-- Link a trait to a specific body part
StaticData.TRAITS_BP = {
    AmputeeHand = "Hand_L",
    AmputeeLowerArm = "ForeArm_L",
    AmputeeUpeerArm = "UpperArm_L"
}

for side, _ in pairs(StaticData.SIDES_STRINGS) do
    for part, _ in pairs(StaticData.PARTS_STRINGS) do
        local assembledName = part .. "_" .. side

        -- Assembled strings
        table.insert(StaticData.LIMBS_STRINGS, assembledName)   -- We need a table like this to cycle through it easily
        StaticData.BODYPARTSTYPES_ENUM[assembledName] = BodyPartType[assembledName]

        -- Dependencies and cicatrization time
        if part == StaticData.PARTS_STRINGS.Hand then
            StaticData.LIMBS_BASE_DAMAGE[assembledName] = 60
            StaticData.LIMBS_CICATRIZATION_TIME[assembledName] = 1700
            StaticData.LIMBS_DEPENDENCIES[assembledName] = {}
        elseif part == StaticData.PARTS_STRINGS.ForeArm then
            StaticData.LIMBS_BASE_DAMAGE[assembledName] = 80
            StaticData.LIMBS_CICATRIZATION_TIME[assembledName] = 1800
            StaticData.LIMBS_DEPENDENCIES[assembledName] = { StaticData.PARTS_STRINGS.Hand .. "_" .. side, }
        elseif part == StaticData.PARTS_STRINGS.UpperArm then
            StaticData.LIMBS_BASE_DAMAGE[assembledName] = 100
            StaticData.LIMBS_CICATRIZATION_TIME[assembledName] = 2000
            StaticData.LIMBS_DEPENDENCIES[assembledName] = { StaticData.PARTS_STRINGS.Hand .. "_" .. side, 
                StaticData.PARTS_STRINGS.ForeArm .. "_" .. side }
        end
    end
end

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
    }

}


-----------------
-- Visuals and clothing




StaticData.AMPUTATION_CLOTHING_ITEM_BASE = "TOC.Amputation_"


return StaticData
