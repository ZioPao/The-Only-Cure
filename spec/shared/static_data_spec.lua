local StaticData = require("TOC/StaticData")

describe("TOC StaticData (in-game)", function()
    it("wires every limb to a real BodyPartType", function()
        assert.is_equal(6, #StaticData.LIMBS_STR)
        for _, limb in ipairs(StaticData.LIMBS_STR) do
            assert.is_not_nil(BodyPartType[limb], limb .. " is missing a BodyPartType")
        end
    end)

    it("exposes the TOC mod name", function()
        assert.is_equal("TOC", StaticData.MOD_NAME)
    end)

    it("loads amputation textures for both genders", function()
        assert.is_not_nil(StaticData.HEALTH_PANEL_TEXTURES.Female)
        assert.is_not_nil(StaticData.HEALTH_PANEL_TEXTURES.Male)
    end)
end)

return ZBSpec.run()
