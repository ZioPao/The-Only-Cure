require('Items/Distributions')
require('Items/SuburbsDistributions')

-- Insert Prosts and various items in the Medical Clinic loot table

local prosthesisLoot = {
    [1] = {
        name = "TOC.Prost_HookArm_L",
        chance = 3
    },

    [2] = {
        name = "TOC.Prost_NormalArm_L",
        chance = 2
    },

    [3] = {
        name = "TOC.Surg_Arm_Tourniquet_L",
        chance = 20
    }
}


for i=1, #prosthesisLoot do
    local tab = prosthesisLoot[i]
    table.insert(ProceduralDistributions.list.MedicalClinicTools.items, tab.name)
    table.insert(ProceduralDistributions.list.MedicalClinicTools.items, tab.chance)
end



