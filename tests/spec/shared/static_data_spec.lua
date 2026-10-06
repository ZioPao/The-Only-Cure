local StaticData = require("TOC/StaticData")

describe("TOC StaticData (in-game)", function()
    it("defines six limbs", function()
        assert.eq(6, #StaticData.LIMBS_STR)
    end)

    it("wires every limb to a real BodyPartType", function()
        for _, limb in ipairs(StaticData.LIMBS_STR) do
            assert.is_not_nil(BodyPartType[limb])
        end
    end)

    it("exposes the TOC mod name", function()
        assert.eq("TOC", StaticData.MOD_NAME)
    end)

    it("loads amputation textures for both genders", function()
        assert.is_not_nil(StaticData.HEALTH_PANEL_TEXTURES.Female)
        assert.is_not_nil(StaticData.HEALTH_PANEL_TEXTURES.Male)
    end)
end)

return ZBSpec.run()
