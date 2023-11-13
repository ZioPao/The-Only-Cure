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

    --TOC_DEBUG.print("setHighestAmputation for " .. self.tocUsername)
    
    -- character is always the patient.
    self.tocUsername = self.character:getUsername()

    if PlayerHandler.amputatedLimbs == nil or PlayerHandler.amputatedLimbs[self.tocUsername] == nil then
        TOC_DEBUG.print("PlayerHandler.amputatedLimbs is still nil or wasn't initialized for " .. self.tocUsername)
        return
    end
    local amputatedLimbs = PlayerHandler.amputatedLimbs[self.tocUsername]

    self.highestAmputations[self.tocUsername] = {}
    TOC_DEBUG.print("Searching highest amputations for " .. self.tocUsername)
    local modDataHandler = ModDataHandler.GetInstance(self.tocUsername)
    if modDataHandler == nil then
        TOC_DEBUG.print("ModDataHandler not found for " .. self.tocUsername)
        return
    end

    for i=1, #amputatedLimbs do
        local limbName = amputatedLimbs[i]
        local index = CommonMethods.GetSide(limbName)
        if modDataHandler:getIsCut(limbName) and modDataHandler:getIsVisible(limbName) then
            TOC_DEBUG.print("found high amputation " .. limbName)
            self.highestAmputations[self.tocUsername][index] = limbName
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

    self.highestAmputations = {}
    self:setHighestAmputation()

    og_ISHealthPanel_initialise(self)
end

local og_ISHealthPanel_setOtherPlayer = ISHealthPanel.setOtherPlayer


---@param playerObj IsoPlayer
function ISHealthPanel:setOtherPlayer(playerObj)
    og_ISHealthPanel_setOtherPlayer(self, playerObj)

    -- Since setOtherPlayer may be run after initialise (or always), we need to recheck it after.
    self:setHighestAmputation()

    -- TODO Request from server!
end


local og_ISHealthPanel_render = ISHealthPanel.render
function ISHealthPanel:render()
    og_ISHealthPanel_render(self)

    --print("Rendering ISHealthPanel")


    if self.highestAmputations ~= nil and self.highestAmputations[self.tocUsername] ~= nil then
        -- Left Texture
        if self.highestAmputations[self.tocUsername]["L"] then
            local textureL = StaticData.HEALTH_PANEL_TEXTURES[self.sexPl][self.highestAmputations[self.tocUsername]["L"]]
            self:drawTexture(textureL, self.healthPanel.x/2 - 2, self.healthPanel.y/2, 1, 1, 0, 0)
        end

        -- Right Texture
        if self.highestAmputations["R"] then
            local textureR = StaticData.HEALTH_PANEL_TEXTURES[self.sexPl][self.highestAmputations[self.tocUsername]["R"]]
            self:drawTexture(textureR, self.healthPanel.x/2 + 2, self.healthPanel.y/2, 1, 1, 0, 0)
        end
    else
        self:setHighestAmputation()
    end
end

-- We need to override this to force the alpha to 1
local og_ISCharacterInfoWindow_render = ISCharacterInfoWindow.prerender
function ISCharacterInfoWindow:prerender()
    og_ISCharacterInfoWindow_render(self)
    self.backgroundColor.a = 1
end

-- We need to override this to force the alpha to 1 for the Medical Check in particular
local og_ISHealthPanel_prerender = ISHealthPanel.prerender
function ISHealthPanel:prerender()
    og_ISHealthPanel_prerender(self)
    self.backgroundColor.a = 1
end


--- The medical check wrap the health panel into this. We need to override its color
local overrideBackgroundColor = true
local og_ISUIElement_wrapInCollapsableWindow = ISUIElement.wrapInCollapsableWindow
function ISUIElement:wrapInCollapsableWindow(title, resizable, subClass)
    local panel = og_ISUIElement_wrapInCollapsableWindow(self, title, resizable, subClass)

    if overrideBackgroundColor then
        TOC_DEBUG.print("Overriding color for panel - " .. title)
        self.backgroundColor.a = 1
        panel.backgroundColor.a = 1
    end

    return panel
end







-- This is run when a player is trying the Medical Check action on another player
local og_ISMedicalCheckAction_perform = ISMedicalCheckAction.perform
function ISMedicalCheckAction:perform()
    local username = self.otherPlayer:getUsername()
    TOC_DEBUG.print("creating instance for " .. username )
    ModDataHandler.GetInstance(username)

    -- We need to recalculate them here before we can create the highest amputations point
    PlayerHandler.CacheAmputatedLimbs(username)
    og_ISMedicalCheckAction_perform(self)
end