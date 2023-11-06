local StaticData = {}

StaticData.MOD_NAME = "TOC"


StaticData.PARTS_STRINGS = {
    Hand = "Hand",
    ForeArm = "ForeArm",
    UpperArm = "UpperArm"
}

StaticData.SIDES_STRINGS = {
    R = "R",
    L = "L"
}
-- Assembled BodyParts string
---@enum
StaticData.LIMBS_STRINGS = {}
StaticData.LIMBS_DEPENDENCIES = {}
StaticData.LIMBS_CICATRIZATION_TIME = {}

for i = 1, #StaticData.SIDES_STRINGS do
    local side = StaticData.PARTS_STRINGS[i]
    for y = 1, #StaticData.PARTS_STRINGS do
        local part = StaticData.PARTS_STRINGS[y]
        local assembledName = part .. "_" .. side

        -- Assembled strings
        StaticData.LIMBS_STRINGS[assembledName] = assembledName

        -- Dependencies and cicatrization time
        if part == StaticData.PARTS_STRINGS.Hand then
            StaticData.LIMBS_BASE_DAMAGE[assembledName] = 60
            StaticData.LIMBS_CICATRIZATION_TIME[assembledName] = 1700
            StaticData.LIMBS_DEPENDENCIES[assembledName] = {}
        elseif part == StaticData.PARTS_STRINGS.ForeArm then
            StaticData.LIMBS_BASE_DAMAGE[assembledName] = 80
            StaticData.LIMBS_CICATRIZATION_TIME[assembledName] = 1800
            StaticData.LIMBS_DEPENDENCIES[assembledName] = { side .. StaticData.PARTS_STRINGS.Hand }
        elseif part == StaticData.PART_STRINGS.UpperArm then
            StaticData.LIMBS_BASE_DAMAGE[assembledName] = 100
            StaticData.LIMBS_CICATRIZATION_TIME[assembledName] = 2000
            StaticData.LIMBS_DEPENDENCIES[assembledName] = { side .. "_" .. StaticData.PARTS_STRINGS.Hand,
                side .. "_" .. StaticData.PARTS_STRINGS.ForeArm }
        end
    end
end

-- Link a trait to a specific body part
StaticData.TRAITS_BP = {
    AmputeeHand = "Hand_L",
    AmputeeLowerArm = "ForeArm_L",
    AmputeeUpeerArm = "UpperArm_L"
}


--------

StaticData.AMPUTATION_VALUES = {}



return StaticData
