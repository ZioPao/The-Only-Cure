local t = require("harness.testkit")
require("harness.init")

local StaticData = require("TOC/StaticData")

t.describe("StaticData", function()
    t.it("defines all six limbs", function()
        t.assertTable(StaticData.LIMBS_STR)
        t.assertEquals(6, #StaticData.LIMBS_STR)

        local expected = { "Hand_L", "Hand_R", "ForeArm_L", "ForeArm_R", "UpperArm_L", "UpperArm_R" }
        for _, name in ipairs(expected) do
            t.assertString(StaticData.LIMBS_IND_STR[name])
        end
    end)

    t.it("hands have no dependencies", function()
        t.assertEquals(0, #StaticData.LIMBS_DEPENDENCIES_IND_STR["Hand_L"])
        t.assertEquals(0, #StaticData.LIMBS_DEPENDENCIES_IND_STR["Hand_R"])
    end)

    t.it("forearms depend on hands", function()
        t.assertEquals(1, #StaticData.LIMBS_DEPENDENCIES_IND_STR["ForeArm_L"])
        t.assertEquals("Hand_L", StaticData.LIMBS_DEPENDENCIES_IND_STR["ForeArm_L"][1])
        t.assertEquals("Hand_R", StaticData.LIMBS_DEPENDENCIES_IND_STR["ForeArm_R"][1])
    end)

    t.it("upper arms depend on two limbs", function()
        t.assertEquals(2, #StaticData.LIMBS_DEPENDENCIES_IND_STR["UpperArm_L"])
        t.assertEquals(2, #StaticData.LIMBS_DEPENDENCIES_IND_STR["UpperArm_R"])
    end)

    t.it("adjacent mappings point up the chain", function()
        t.assertEquals("ForeArm_L", StaticData.LIMBS_ADJACENT_IND_STR["Hand_L"])
        t.assertEquals("ForeArm_R", StaticData.LIMBS_ADJACENT_IND_STR["Hand_R"])
        t.assertEquals("UpperArm_L", StaticData.LIMBS_ADJACENT_IND_STR["ForeArm_L"])
        t.assertEquals("UpperArm_R", StaticData.LIMBS_ADJACENT_IND_STR["ForeArm_R"])
        t.assertEquals("Torso_Upper", StaticData.LIMBS_ADJACENT_IND_STR["UpperArm_L"])
        t.assertEquals("Torso_Upper", StaticData.LIMBS_ADJACENT_IND_STR["UpperArm_R"])
    end)

    t.it("arm limbs map to top amputation groups", function()
        t.assertEquals("Top_L", StaticData.LIMBS_TO_AMP_GROUPS_MATCH_IND_STR["Hand_L"])
        t.assertEquals("Top_L", StaticData.LIMBS_TO_AMP_GROUPS_MATCH_IND_STR["ForeArm_L"])
        t.assertEquals("Top_L", StaticData.LIMBS_TO_AMP_GROUPS_MATCH_IND_STR["UpperArm_L"])
        t.assertEquals("Top_R", StaticData.LIMBS_TO_AMP_GROUPS_MATCH_IND_STR["Hand_R"])
        t.assertEquals("Top_R", StaticData.LIMBS_TO_AMP_GROUPS_MATCH_IND_STR["ForeArm_R"])
    end)
end)
