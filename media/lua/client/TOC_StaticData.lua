local StaticData = {}


StaticData.MOD_NAME = "TOC"

---@enum
StaticData.BP_STRINGS = {
    RightHand = "RightHand",
    RightLowerArm = "RightLowerArm",
    RightUpperArm = "RightUpperArm",

    LeftHand = "LeftHand",
    LeftLowerArm = "LeftLowerArm",
    LeftUpperArm = "LeftUpperArm"
}

-- Body Parts Strings
-- StaticData.BP_STRINGS = {
--     "RightHand", "RightLowerArm", "RightUpperArm",
--     "LeftHand", "LeftLowerArm", "LeftUpperArm"
-- }

-- Link a trait to a specific body part
StaticData.TRAITS_BP = {
    AmputeeHand = "LeftHand",
    AmputeeLowerArm = "LeftLowerArm",
    AmputeeUpeerArm = "LeftUpperArm"
}


StaticData.LIMB_DEPENDENCIES = {
    RightHand = {},
    RightLowerArm = {StaticData.BP_STRINGS.RightHand},
    RightUpperArm = {StaticData.BP_STRINGS.RightHand, StaticData.BP_STRINGS.RightLowerArm},

    LeftHand = {},
    LeftLowerArm = {StaticData.BP_STRINGS.LeftHand},
    LeftUpperArm = {StaticData.BP_STRINGS.LeftHand, StaticData.BP_STRINGS.LeftLowerArm},

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


