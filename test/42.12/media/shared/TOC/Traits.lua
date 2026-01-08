
---Setups the custom TOC traits

local TRAITS = {
    Amputee_Hand = "Amputee_Hand",
    Amputee_ForeArm = "Amputee_ForeArm",
    Amputee_UpperArm = "Amputee_UpperArm",
    --Insensitive = "Insensitive"       -- TODO Disabled for now, until we reintroduce it
}


local function GetTraitText(trait)
    return getText("UI_trait_" .. trait)
end

local function GetTraitDesc(trait)
    return getText("UI_trait_" .. trait .. "_desc")
end


local function SetupTraits()
    local traitsTable = {
        [1] = TraitFactory.addTrait(TRAITS.Amputee_Hand, GetTraitText(TRAITS.Amputee_Hand), -8, GetTraitDesc(TRAITS.Amputee_Hand), false, false),
        [2] = TraitFactory.addTrait(TRAITS.Amputee_ForeArm, GetTraitText(TRAITS.Amputee_ForeArm), -10, GetTraitDesc(TRAITS.Amputee_ForeArm), false, false),
        [3] = TraitFactory.addTrait(TRAITS.Amputee_UpperArm, GetTraitText(TRAITS.Amputee_UpperArm), -20, GetTraitDesc(TRAITS.Amputee_UpperArm), false, false)
    }

    for i=1, #traitsTable do

        ---@type Trait
        local t = traitsTable[i]
        ---@diagnostic disable-next-line: undefined-field
        t:addXPBoost(Perks.Side_L, 4)
        t:addXPBoost(Perks.Fitness, -1)
        t:addXPBoost(Perks.Strength, -1)
    end

    --TraitFactory.addTrait(TRAITS.Insensitive, GetTraitText(TRAITS.Insensitive), 6, GetTraitDesc(TRAITS.Insensitive), false, false)

    TraitFactory.setMutualExclusive(TRAITS.Amputee_Hand, TRAITS.Amputee_ForeArm)
    TraitFactory.setMutualExclusive(TRAITS.Amputee_Hand, TRAITS.Amputee_UpperArm)
    TraitFactory.setMutualExclusive(TRAITS.Amputee_ForeArm, TRAITS.Amputee_UpperArm)
end



Events.OnGameBoot.Add(SetupTraits)
