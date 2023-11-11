local PlayerHandler = require("Handlers/TOC_PlayerHandler")
local StaticData = require("TOC_StaticData")
local CommonMethods = require("TOC_Common")

---@diagnostic disable: duplicate-set-field
local CutLimbHandler = require("UI/TOC_CutLimbInteractions")

-- TODO Use this to replace the sprites once a limb is cut
ISHealthBodyPartPanel = ISBodyPartPanel:derive("ISHealthBodyPartPanel")

--* Handling drag n drop of the saw *--

local og_ISHealthPanel_dropItemsOnBodyPart = ISHealthPanel.dropItemsOnBodyPart
function ISHealthPanel:dropItemsOnBodyPart(bodyPart, items)
    og_ISHealthPanel_dropItemsOnBodyPart(self, bodyPart, items)
    local cutLimbHandler = CutLimbHandler:new(self, bodyPart)
    for _,item in ipairs(items) do
        cutLimbHandler:checkItem(item)
    end
    if cutLimbHandler:dropItems(items) then
        return
    end

end

local og_ISHealthPanel_doBodyPartContextMenu = ISHealthPanel.doBodyPartContextMenu
function ISHealthPanel:doBodyPartContextMenu(bodyPart, x, y)
    og_ISHealthPanel_doBodyPartContextMenu(self, bodyPart, x, y)
    local playerNum = self.otherPlayer and self.otherPlayer:getPlayerNum() or self.character:getPlayerNum()

    -- To not recreate it but reuse the one that has been created in the original method
    local context = getPlayerContextMenu(playerNum) 
    local cutLimbHandler = CutLimbHandler:new(self, bodyPart)
    cutLimbHandler:addToMenu(context)
end


--* Modification to handle visible amputation on the health menu *--

function ISHealthPanel.GetHighestAmputation()
    ISHealthPanel.highestAmputations = {}
    for i=1, #PlayerHandler.amputatedLimbs do
        local limbName = PlayerHandler.amputatedLimbs[i]
        local index = CommonMethods.GetSide(limbName)
        if PlayerHandler.modDataHandler:getIsCut(limbName) and PlayerHandler.modDataHandler:getIsVisible(limbName) then
            ISHealthPanel.highestAmputations[index] = limbName
        end
    end
end


local og_ISHealthPanel_initialise = ISHealthPanel.initialise
function ISHealthPanel:initialise()
    if self.character:isFemale() then
        self.sexPl = "Female"
    else
        self.sexPl = "Male"
    end
    og_ISHealthPanel_initialise(self)
end

local og_ISHealthPanel_render = ISHealthPanel.render
function ISHealthPanel:render()
    og_ISHealthPanel_render(self)

    -- TODO Handle another player health panel

    if ISHealthPanel.highestAmputations then
        -- Left Texture
        if ISHealthPanel.highestAmputations["L"] then
            local textureL = StaticData.HEALTH_PANEL_TEXTURES[self.sexPl][ISHealthPanel.highestAmputations["L"]]
            self:drawTexture(textureL, self.healthPanel.x/2 - 2, self.healthPanel.y/2, 1, 1, 0, 0)
        end

        -- Right Texture
        if ISHealthPanel.highestAmputations["R"] then
            local textureR = StaticData.HEALTH_PANEL_TEXTURES[self.sexPl][ISHealthPanel.highestAmputations["R"]]
            self:drawTexture(textureR, self.healthPanel.x/2 + 2, self.healthPanel.y/2, 1, 1, 0, 0)
        end
    else
        ISHealthPanel.GetHighestAmputation()
    end
end

-- We need to override this to force the alpha to 1
local og_ISCharacterInfoWindow_render = ISCharacterInfoWindow.prerender
function ISCharacterInfoWindow:prerender()
    og_ISCharacterInfoWindow_render(self)
    self.backgroundColor.a = 1
end