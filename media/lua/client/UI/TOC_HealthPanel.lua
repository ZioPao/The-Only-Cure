local CutLimbHandler = require("UI/TOC_CutLimbHandler")

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
    local context = getPlayerContextMenu(playerNum)     -- To not recreate it but reuse the one that has been created in the original method
    local cutLimbHandler = CutLimbHandler:new(self, bodyPart)
    cutLimbHandler:addToMenu(context)
end


--* Modification to handle visible amputation on the health menu *--


local handL = getTexture("media/ui/Hand_L.png")
local forearmL = getTexture("media/ui/ForeArm_L.png")
local upperarmL = getTexture("media/ui/UpperArm_L.png")

local og_ISHealthPanel_render = ISHealthPanel.render
function ISHealthPanel:render()
    og_ISHealthPanel_render(self)

    -- Left Texture


    --self:drawTextureScaled(forearmL, self.healthPanel.x/2 - 2, self.healthPanel.y/2, 123, 302, 1, 1, 0, 0)

    -- Right Texture

end

-- We need to override this to force the alpha to 1
local og_ISCharacterInfoWindow_render = ISCharacterInfoWindow.prerender
function ISCharacterInfoWindow:prerender()
    og_ISCharacterInfoWindow_render(self)
    self.backgroundColor.a = 1
end