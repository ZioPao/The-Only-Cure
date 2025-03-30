local StaticData = require("TOC/StaticData")
local DataController = require("TOC/Controllers/DataController")
local CachedDataHandler = require("TOC/Handlers/CachedDataHandler")
local Compat = require("TOC/Compat")

local CutLimbInteractionHandler = require("TOC/UI/Interactions/CutLimbInteractionHandler")
local WoundCleaningInteractionHandler = require("TOC/UI/Interactions/WoundCleaningInteractionHandler")
------------------------


local isReady = false

function SetHealthPanelTOC()

    -- depending on compatibility

    isReady = true
end


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
    local cutLimbInteraction = CutLimbInteractionHandler:new(self, bodyPart)
    local woundCleaningInteraction = WoundCleaningInteractionHandler:new(self, bodyPart, self.character:getUsername())

    for _,item in ipairs(items) do
        cutLimbInteraction:checkItem(item)
        woundCleaningInteraction:checkItem(item)
    end
    if cutLimbInteraction:dropItems(items) or woundCleaningInteraction:dropItems(items) then
        return
    end

end

local og_ISHealthPanel_doBodyPartContextMenu = ISHealthPanel.doBodyPartContextMenu
function ISHealthPanel:doBodyPartContextMenu(bodyPart, x, y)
    og_ISHealthPanel_doBodyPartContextMenu(self, bodyPart, x, y)
    local playerNum = self.otherPlayer and self.otherPlayer:getPlayerNum() or self.character:getPlayerNum()

    -- To not recreate it but reuse the one that has been created in the original method

    -- TODO This will work ONLY when an addOption has been already done in the og method.
    local context = getPlayerContextMenu(playerNum)
    context:bringToTop()
    context:setVisible(true)


    local cutLimbInteraction = CutLimbInteractionHandler:new(self, bodyPart)
    self:checkItems({cutLimbInteraction})
    cutLimbInteraction:addToMenu(context)

    local woundCleaningInteraction = WoundCleaningInteractionHandler:new(self, bodyPart, self.character:getUsername())
    self:checkItems({woundCleaningInteraction})
    woundCleaningInteraction:addToMenu(context)
end


--* Modifications and additional methods to handle visible amputation on the health menu *--

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
function ISHealthPanel:tryDrawAmputation(highestAmputations, side, username)
    local redColor
    local texture

    if TOC_DEBUG.enableHealthPanelDebug then
        redColor = 1
        texture = getTexture("media/ui/test_pattern.png")
    else
        if highestAmputations[side] == nil then return end
        local limbName = highestAmputations[side]
        --TOC_DEBUG.print("Drawing " .. tostring(limbName) .. " for " .. username)

        local cicTime = DataController.GetInstance(username):getCicatrizationTime(limbName)
        redColor = GetColorFromCicatrizationTime(cicTime, limbName)

        local sexPl = self.character:isFemale() and "Female" or "Male"
        texture = StaticData.HEALTH_PANEL_TEXTURES[sexPl][limbName]
    end

    -- B42, for some reason the positioning of the texture changed. Realigned it manually with those fixed values
    self:drawTexture(texture, self.healthPanel.x - 7, self.healthPanel.y - 13, 1, redColor, 0, 0)
end
function ISHealthPanel:tryDrawProsthesis(highestAmputations, side, username)
    local dc = DataController.GetInstance(username)     -- TODO CACHE PROSTHESIS!!! Don't use DC here
    local limbName = highestAmputations[side]
    if limbName and dc:getIsProstEquipped(limbName) then
        self:drawTexture(StaticData.HEALTH_PANEL_TEXTURES.ProstArm[side], self.healthPanel.x, self.healthPanel.y, 1, 1, 1, 1)
    end
end

local og_ISHealthPanel_render = ISHealthPanel.render
function ISHealthPanel:render()
    og_ISHealthPanel_render(self)
    local username = self.character:getUsername()
    local highestAmputations = CachedDataHandler.GetHighestAmputatedLimbs(username)

    if highestAmputations ~= nil then

        -- Left Texture
        self:tryDrawAmputation(highestAmputations, "L", username)
        self:tryDrawProsthesis(highestAmputations, "L", username)

        -- Right Texture
        self:tryDrawAmputation(highestAmputations, "R", username)
        self:tryDrawProsthesis(highestAmputations, "R", username)
    end
end


-- local og_ISHealthPanel_update = ISHealthPanel.update
-- function ISHealthPanel:update()
--     og_ISHealthPanel_update(self)
--     -- TODO Listen for changes on other player side instead of looping this


--     -- FIX Re-enable it, just for test
--     if self.character then
--         local locPlUsername = getPlayer():getUsername()
--         local remPlUsername = self.character:getUsername()
--         if locPlUsername ~= remPlUsername and self:isReallyVisible() then
--             -- Request update for TOC DATA
--             local key = CommandsData.GetKey(remPlUsername)
--             --ModData.request(key)
--         end
--     end
-- end



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
    TOC_DEBUG.print("Medical Action on " .. username )

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


    -- We should cache a lot of other stuff to have this working with CacheDataHandler :(
    if limbName then
        local dcInst = DataController.GetInstance(username)
        if dcInst:getIsCut(limbName) and dcInst:getIsVisible(limbName) then
            if dcInst:getIsCicatrized(limbName) then
                if dcInst:getIsCauterized(limbName) then
                    self:drawText("- " .. getText("IGUI_HealthPanel_Cauterized"), x, y,  0.58, 0.75, 0.28, 1, UIFont.Small)
                else
                    self:drawText("- " .. getText("IGUI_HealthPanel_Cicatrized"), x, y, 0.28, 0.89, 0.28, 1, UIFont.Small)
                end

                y = y + fontHgt
            else
                local cicaTime = dcInst:getCicatrizationTime(limbName)

                -- Show it in percentage
                local maxCicaTime = StaticData.LIMBS_CICATRIZATION_TIME_IND_NUM[limbName]
                local percentage = (1 - cicaTime/maxCicaTime) * 100
                self:drawText("- " .. getText("IGUI_HealthPanel_Cicatrization") .. string.format(" %.2f", percentage) .. "%", x, y, 0.89, 0.28, 0.28, 1, UIFont.Small)
                y = y + fontHgt

                local scaledDirtyness = math.floor(dcInst:getWoundDirtyness(limbName) * 100)
                self:drawText("- " .. getText("IGUI_HealthPanel_WoundDirtyness") .. string.format(" %d", scaledDirtyness) .. "%", x, y, 0.89, 0.28, 0.28, 1, UIFont.Small)
                y = y + fontHgt

            end

            if dcInst:getIsProstEquipped(limbName) then
                self:drawText("- " .. getText("IGUI_HealthPanel_ProstEquipped"), x, y, 0.28, 0.89, 0.28, 1, UIFont.Small)
                y = y + fontHgt
            end


        end

    end

    y = y + 5
    return y
end

local og_ISHealthPanel_getDamagedParts = ISHealthPanel.getDamagedParts
function ISHealthPanel:getDamagedParts()
    -- check for imeds or if TOC is ready to display its stuff on the health panel
    if isReady == false or Compat.handlers['iMeds'].isActive or Compat.handlers['iMedsFixed'].isActive then
        return og_ISHealthPanel_getDamagedParts(self)
    elseif isReady then
        local result = {}
        local bodyParts = self:getPatient():getBodyDamage():getBodyParts()
        if isClient() and not self:getPatient():isLocalPlayer() then
            bodyParts = self:getPatient():getBodyDamageRemote():getBodyParts()
        end

        local patientUsername = self:getPatient():getUsername()
        local mdh = DataController.GetInstance(patientUsername)
        for i=1,bodyParts:size() do
            local bodyPart = bodyParts:get(i-1)
            local bodyPartTypeStr = BodyPartType.ToString(bodyPart:getType())
            local limbName = StaticData.LIMBS_IND_STR[bodyPartTypeStr]

            if ISHealthPanel.cheat or bodyPart:HasInjury() or bodyPart:bandaged() or bodyPart:stitched() or bodyPart:getSplintFactor() > 0 or bodyPart:getAdditionalPain() > 10 or bodyPart:getStiffness() > 5 or (mdh:getIsCut(limbName) and mdh:getIsVisible(limbName)) then
               table.insert(result, bodyPart)
            end
        end
        return result
    end
end