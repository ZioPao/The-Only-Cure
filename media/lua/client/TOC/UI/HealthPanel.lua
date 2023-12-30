local StaticData = require("TOC/StaticData")
local ModDataHandler = require("TOC/Handlers/ModDataHandler")
local CachedDataHandler = require("TOC/Handlers/CachedDataHandler")
local CutLimbHandler = require("TOC/UI/CutLimbInteractions")
local WoundCleaningHandler = require("TOC/UI/WoundCleaningInteraction")
---------------------------------

-- We're overriding ISHealthPanel to add custom textures to the body panel.
-- By doing so we can show the player which limbs have been cut without having to use another menu
-- We can show prosthesis too this way
-- We also manage the drag'n drop of items on the body to let the players use the saw this way too
---@diagnostic disable: duplicate-set-field

--ISHealthBodyPartPanel = ISBodyPartPanel:derive("ISHealthBodyPartPanel")

--* Handling drag n drop of the saw *--

local og_ISHealthPanel_dropItemsOnBodyPart = ISHealthPanel.dropItemsOnBodyPart
function ISHealthPanel:dropItemsOnBodyPart(bodyPart, items)
    og_ISHealthPanel_dropItemsOnBodyPart(self, bodyPart, items)

    TOC_DEBUG.print("override to dropItemsOnBodyPart running")
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
    self:checkItems({cutLimbHandler})
    cutLimbHandler:addToMenu(context)

    local woundCleaningHandler = WoundCleaningHandler:new(self, bodyPart, self.character:getUsername())
    self:checkItems({woundCleaningHandler})
    woundCleaningHandler:addToMenu(context)
end


--* Modifications and additional methods to handle visible amputation on the health menu *--

local og_ISHealthPanel_initialise = ISHealthPanel.initialise
function ISHealthPanel:initialise()
    if self.character:isFemale() then
        self.sexPl = "Female"
    else
        self.sexPl = "Male"
    end

    local username = self.character:getUsername()
    if username ~= "Bob" then
        CachedDataHandler.CalculateHighestAmputatedLimbs(username)
        self.highestAmputations = CachedDataHandler.GetHighestAmputatedLimbs(username) 
    end

    og_ISHealthPanel_initialise(self)
end

local og_ISHealthPanel_setOtherPlayer = ISHealthPanel.setOtherPlayer
---@param playerObj IsoPlayer
function ISHealthPanel:setOtherPlayer(playerObj)
    og_ISHealthPanel_setOtherPlayer(self, playerObj)
    --CachedDataHandler.CalculateAmputatedLimbs(self.character:getUsername())
end

---Get a value between 1 and 0.1 for the cicatrization time
---@param cicTime integer
---@return integer
local function GetColorFromCicatrizationTime(cicTime, limbName)
    local defaultTime = StaticData.LIMBS_CICATRIZATION_TIME_IND_NUM[limbName]
    local delta = cicTime/defaultTime
    return math.max(0.15, math.min(delta, 1))
end

---Try to draw the highest amputation in the health panel, based on the cicatrization time
---@param side string L or R
---@param username string
function ISHealthPanel:tryDrawHighestAmputation(side, username)
    local redColor
    local texture

    if TOC_DEBUG.enableHealthPanelDebug then
        redColor = 1
        texture = getTexture("media/ui/test_pattern.png")
    else
        if self.highestAmputations[side] == nil then return end
        local limbName = self.highestAmputations[side]

        local cicTime = ModDataHandler.GetInstance(username):getCicatrizationTime(limbName)
        redColor = GetColorFromCicatrizationTime(cicTime, limbName)
        texture = StaticData.HEALTH_PANEL_TEXTURES[self.sexPl][limbName]
    end

    self:drawTexture(texture, self.healthPanel.x, self.healthPanel.y, 1, redColor, 0, 0)
end

local og_ISHealthPanel_render = ISHealthPanel.render
function ISHealthPanel:render()
    og_ISHealthPanel_render(self)
    local username = self.character:getUsername()
    self.highestAmputations = CachedDataHandler.GetHighestAmputatedLimbs(username)

    if self.highestAmputations ~= nil then
        -- Left Texture
        self:tryDrawHighestAmputation("L", username)

        -- Right Texture
        self:tryDrawHighestAmputation("R", username)
    else
        -- Request caching data
        TOC_DEBUG.print("highest amputated limbs was nil, calculating and getting it now for" .. username)
        CachedDataHandler.CalculateHighestAmputatedLimbs(username)
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
---@param title string
---@param resizable any
---@param subClass any
---@return any
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
    CachedDataHandler.CalculateAmputatedLimbs(username)
    og_ISMedicalCheckAction_perform(self)
end

local og_ISHealthBodyPartListBox_doDrawItem = ISHealthBodyPartListBox.doDrawItem
function ISHealthBodyPartListBox:doDrawItem(y, item, alt)
    y = og_ISHealthBodyPartListBox_doDrawItem(self, y, item, alt)
    y = y - 5
    local x = 15
    local fontHgt = getTextManager():getFontHeight(UIFont.Small)

    local username = self.parent.character:getUsername()
    --local amputatedLimbs = CachedDataHandler.GetIndexedAmputatedLimbs(username)

    ---@type BodyPart
    local bodyPart = item.item.bodyPart

    local bodyPartTypeStr = BodyPartType.ToString(bodyPart:getType())
    local limbName = StaticData.LIMBS_IND_STR[bodyPartTypeStr]
    if limbName then
        local modDataHandler = ModDataHandler.GetInstance(username)
        if modDataHandler:getIsCut(limbName) and modDataHandler:getIsVisible(limbName) then
            if modDataHandler:getIsCicatrized(limbName) then
                if modDataHandler:getIsCauterized(limbName) then
                    self:drawText("- " .. getText("IGUI_HealthPanel_Cauterized"), x, y,  0.58, 0.75, 0.28, 1, UIFont.Small)
                else
                    self:drawText("- " .. getText("IGUI_HealthPanel_Cicatrized"), x, y,  0.28, 0.89, 0.28, 1, UIFont.Small)
                end
            else
                local cicaTime = modDataHandler:getCicatrizationTime(limbName)

                -- Show it in percentage
                local maxCicaTime = StaticData.LIMBS_CICATRIZATION_TIME_IND_NUM[limbName]
                local percentage = (1 - cicaTime/maxCicaTime) * 100
                self:drawText("- " .. getText("IGUI_HealthPanel_Cicatrization") .. string.format(" %.2f", percentage) .. "%", x, y, 0.89, 0.28, 0.28, 1, UIFont.Small)
            end
            y = y + fontHgt

        end

    end

    y = y + 5
    return y
end

local og_ISHealthPanel_getDamagedParts = ISHealthPanel.getDamagedParts
function ISHealthPanel:getDamagedParts()

    -- TODO Overriding it is a lot easier, but ew
    -- local result = og_ISHealthPanel_getDamagedParts(self)
    -- local bodyParts = self:getPatient():getBodyDamage():getBodyParts()
    -- if isClient() and not self:getPatient():isLocalPlayer() then
    --     bodyParts = self:getPatient():getBodyDamageRemote():getBodyParts()
    -- end
    -- for i=1,bodyParts:size() do
    --     local bodyPart = bodyParts:get(i-1)
    --     table.insert(result, bodyPart)

    -- end


    -- return result
    local result = {}
    local bodyParts = self:getPatient():getBodyDamage():getBodyParts()
    if isClient() and not self:getPatient():isLocalPlayer() then
        bodyParts = self:getPatient():getBodyDamageRemote():getBodyParts()
    end
    for i=1,bodyParts:size() do
        local bodyPart = bodyParts:get(i-1)
        local bodyPartTypeStr = BodyPartType.ToString(bodyPart:getType())
        local limbName = StaticData.LIMBS_IND_STR[bodyPartTypeStr]

        local bodyPartAction = self.bodyPartAction and self.bodyPartAction[bodyPart]
        if ISHealthPanel.cheat or bodyPart:HasInjury() or bodyPart:bandaged() or bodyPart:stitched() or bodyPart:getSplintFactor() > 0 or bodyPart:getAdditionalPain() > 10 or bodyPart:getStiffness() > 5 or ModDataHandler.GetInstance(self:getPatient():getUsername()):getIsCut(limbName) then
            table.insert(result, bodyPart)
        end
    end
    return result
end