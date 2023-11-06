local StaticData = {}


StaticData.MOD_NAME = "TOC"


StaticData.SIDES_STRINGS = {
    Right = "Right",
    Left = "Left"
}

StaticData.PARTS_STRINGS = {
    Hand = "Hand",
    LowerArm = "LowerArm",
    UpperArm = "UpperArm"
}


-- Assembled BodyParts string
---@enum
StaticData.BP_STRINGS = {}
StaticData.LIMB_DEPENDENCIES = {}
StaticData.LIMB_CICATRIZATION_TIME = {}

for i=1, #StaticData.SIDES_STRINGS do
    local side = StaticData.PARTS_STRINGS[i]
    for y=1, #StaticData.PARTS_STRINGS do
        local part = StaticData.PARTS_STRINGS[y]
        local assembledName = side .. part

        -- Assembled strings
        StaticData.BP_STRINGS[assembledName] = assembledName

        -- Dependencies and cicatrization time
        if part == StaticData.PARTS_STRINGS.Hand then
            StaticData.LIMB_CICATRIZATION_TIME[assembledName] = 1700
            StaticData.LIMB_DEPENDENCIES[assembledName] = {}
        elseif part == StaticData.PARTS_STRINGS.LowerArm then
            StaticData.LIMB_CICATRIZATION_TIME[assembledName] = 1800
            StaticData.LIMB_DEPENDENCIES[assembledName] = {side .. StaticData.PARTS_STRINGS.Hand}

        elseif part == StaticData.PART_STRINGS.UpperArm then
            StaticData.LIMB_CICATRIZATION_TIME[assembledName] = 2000
            StaticData.LIMB_DEPENDENCIES[assembledName] = {side .. StaticData.PARTS_STRINGS.Hand, side .. StaticData.PARTS_STRINGS.LowerArm}
        end
    end
end


-- Link a trait to a specific body part
StaticData.TRAITS_BP = {
    AmputeeHand = "LeftHand",
    AmputeeLowerArm = "LeftLowerArm",
    AmputeeUpeerArm = "LeftUpperArm"
}



return StaticData


-- TODO We should pick BodyPartType or strings, not both. It's a mess


-- TODO We need strings for 
    -- Searching items
    -- ...
-- TODO We need Enums for
    -- Accessing data in moddata


-- Unified model with single string






-- local SIDES = {"Right", "Left"}
-- local PARTS = { "Hand", "LowerArm", "UpperArm", "Foot" }


-- local Data = {}

-- Data.AmputableBodyParts = {
--     BodyPartType.Hand_R, BodyPartType.ForeArm_R, BodyPartType.UpperArm_R,
--     BodyPartType.Hand_L, BodyPartType.ForeArm_L, BodyPartType.UpperArm_L
-- }


