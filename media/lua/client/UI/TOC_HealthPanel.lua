local PlayerHandler = require("TOC_PlayerHandler")
local StaticData = require("TOC_StaticData")

---@diagnostic disable: duplicate-set-field
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

    -- To not recreate it but reuse the one that has been created in the original method
    local context = getPlayerContextMenu(playerNum) 
    local cutLimbHandler = CutLimbHandler:new(self, bodyPart)
    cutLimbHandler:addToMenu(context)
end


--* Modification to handle visible amputation on the health menu *--

-- TODO We need male variations


---@return {partL : string?, partR : string?}
local function GetHighestAmputation()
    -- TODO Cache this instead of doing it here!

    local tab = {}
    local prevDepSize = {}
    for i=1, #StaticData.LIMBS_STRINGS do
        local limbName = StaticData.LIMBS_STRINGS[i]
        local index
        if string.find(limbName, "_L") then index = "L" else index = "R" end
        if PlayerHandler.modDataHandler:getIsCut(limbName) then

            if tab[index] ~= nil then
                local cDependencySize = #StaticData.LIMBS_DEPENDENCIES[limbName]
                if cDependencySize > prevDepSize[index] then
                    tab[index] = limbName
                    prevDepSize[index] = StaticData.LIMBS_DEPENDENCIES[limbName]
                end
            else
                tab[index] = limbName
                prevDepSize[index] = #StaticData.LIMBS_DEPENDENCIES[limbName]
            end
        end

    end
    return tab
end


local og_ISHealthPanel_render = ISHealthPanel.render
function ISHealthPanel:render()
    og_ISHealthPanel_render(self)

    -- TODO Handle another player health panel

    local highestAmputations = GetHighestAmputation()

    -- Left Texture
    if highestAmputations["L"] then
        local textureL = StaticData.HEALTH_PANEL_TEXTURES[highestAmputations["L"]]
        self:drawTextureScaled(textureL, self.healthPanel.x/2 - 2, self.healthPanel.y/2, 123, 302, 1, 1, 0, 0)
    end

    if highestAmputations["R"] then
        
    end



    -- Right Texture

end

-- We need to override this to force the alpha to 1
local og_ISCharacterInfoWindow_render = ISCharacterInfoWindow.prerender
function ISCharacterInfoWindow:prerender()
    og_ISCharacterInfoWindow_render(self)
    self.backgroundColor.a = 1
end