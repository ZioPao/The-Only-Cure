local PlayerHandler = require("TOC/Handlers/PlayerHandler")
local StaticData = require("TOC/StaticData")
local CommonMethods = require("TOC/CommonMethods")
local ModDataHandler = require("TOC/Handlers/ModDataHandler")

---@diagnostic disable: duplicate-set-field
local CutLimbHandler = require("TOC/UI/CutLimbInteractions")

---------------------------------

-- We're overriding ISHealthPanel to add custom textures to the body panel.
-- By doing so we can show the player which limbs have been cut without having to use another menu
-- We can show prosthesis too this way
-- We also manage the drag'n drop of items on the body to let the players use the saw this way too

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



function ISHealthPanel:setHighestAmputation()
    if self.otherPlayer ~= nil then
        self.tocUsername = self.otherPlayer:getUsername()
    else
        self.tocUsername = self.character:getUsername()
    end

    ISHealthPanel.highestAmputations[self.tocUsername] = {}
    local modDataHandler = ModDataHandler.GetInstance(self.tocUsername)
    if modDataHandler == nil then return end        -- TODO Test this
    for i=1, #PlayerHandler.amputatedLimbs do
        local limbName = PlayerHandler.amputatedLimbs[i]
        local index = CommonMethods.GetSide(limbName)
        if modDataHandler:getIsCut(limbName) and modDataHandler:getIsVisible(limbName) then
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

    self:setHighestAmputation()

    og_ISHealthPanel_initialise(self)
end

local og_ISHealthPanel_setOtherPlayer = ISHealthPanel.setOtherPlayer
---comment
---@param playerObj IsoPlayer
function ISHealthPanel:setOtherPlayer(playerObj)
    og_ISHealthPanel_setOtherPlayer(self, playerObj)
    self:setHighestAmputation()
end


local og_ISHealthPanel_render = ISHealthPanel.render
function ISHealthPanel:render()
    og_ISHealthPanel_render(self)

    -- TODO Handle another player health panel

    if ISHealthPanel.highestAmputations[self.tocUsername] then
        -- Left Texture
        if ISHealthPanel.highestAmputations[self.tocUsername]["L"] then
            local textureL = StaticData.HEALTH_PANEL_TEXTURES[self.sexPl][ISHealthPanel.highestAmputations["L"]]
            self:drawTexture(textureL, self.healthPanel.x/2 - 2, self.healthPanel.y/2, 1, 1, 0, 0)
        end

        -- Right Texture
        if ISHealthPanel.highestAmputations[self.tocUsername]["R"] then
            local textureR = StaticData.HEALTH_PANEL_TEXTURES[self.sexPl][ISHealthPanel.highestAmputations["R"]]
            self:drawTexture(textureR, self.healthPanel.x/2 + 2, self.healthPanel.y/2, 1, 1, 0, 0)
        end
    else
        ISHealthPanel.GetHighestAmputation(self.tocUsername)
    end
end

-- We need to override this to force the alpha to 1
local og_ISCharacterInfoWindow_render = ISCharacterInfoWindow.prerender
function ISCharacterInfoWindow:prerender()
    og_ISCharacterInfoWindow_render(self)
    self.backgroundColor.a = 1
end