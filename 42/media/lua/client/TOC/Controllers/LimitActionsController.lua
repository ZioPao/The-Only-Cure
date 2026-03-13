local LocalPlayerController = require("TOC/Controllers/LocalPlayerController")
local DataController = require("TOC/Controllers/DataController")

local CachedDataHandler = require("TOC/Handlers/CachedDataHandler")
local CommonMethods = require("TOC/CommonMethods")
local StaticData = require("TOC/StaticData")

local OverridenMethodsArchive = require("TOC/OverridenMethodsArchive")
-----------------
---@class LimitActionsController
local LimitActionsController = {}


--* DISABLE WEARING CERTAIN ITEMS WHEN NO LIMB

function LimitActionsController.CheckLimbFeasibility(limbName)
    local dcInst = DataController.GetInstance(getPlayer():getUsername())
    local isFeasible = not dcInst:getIsCut(limbName) or dcInst:getIsProstEquipped(limbName)
    --TOC_DEBUG.print("isFeasible="..tostring(isFeasible))
    return isFeasible
end

---@param obj any
---@param wrappedFunc function
---@param item InventoryItem
---@return boolean
function LimitActionsController.WrapClothingAction(obj, wrappedFunc, item)
    local isEquippable = wrappedFunc(obj)
    if not isEquippable then return isEquippable end

    local itemBodyLoc = item:getBodyLocation()

    local limbToCheck = StaticData.AFFECTED_BODYLOCS_TO_LIMBS_IND_STR[itemBodyLoc]
    if LimitActionsController.CheckLimbFeasibility(limbToCheck) then return isEquippable else return false end
end

-- We need to override when the player changes key binds manually to be sure that TOC changes are re-applied
local og_MainOptions_apply = MainOptions.apply
function MainOptions:apply(closeAfter)
    og_MainOptions_apply(self, closeAfter)
    CachedDataHandler.OverrideInteractionsKey(getPlayer():getUsername())
end

--------------------------------------------
--* TIMED ACTIONS 
--* We want to be able to modify how long actions are gonna take,
--* depending on amputation status and kind of action. Also, when the
--* player has not completely cicatrized their own wounds, and try to do any action with
--* a prosthesis on, that can trigger random bleeds.

local function CheckHandFeasibility(limbName)
    --TOC_DEBUG.print("Checking hand feasibility: " .. limbName)
    local dcInst = DataController.GetInstance(getPlayer():getUsername())

    local isFeasible = not dcInst:getIsCut(limbName) or dcInst:getIsProstEquipped(limbName)
   -- TOC_DEBUG.print("isFeasible: " .. tostring(isFeasible))
    return isFeasible
end

--* EQUIPPING ITEMS *--
-- Check wheter the player can equip items or not, for example dual wielding when you only have one
-- hand (and no prosthesis) should be disabled. Same thing for some werable items, like watches.

---@class ISEquipWeaponAction
---@field character IsoPlayer

--* Equipping items overrides *--
local og_ISEquipWeaponAction_isValid = ISEquipWeaponAction.isValid
---Add a condition to check the feasibility of having 2 handed weapons or if both arms are cut off
---@return boolean?
---@diagnostic disable-next-line: duplicate-set-field
function ISEquipWeaponAction:isValid()
    local isValid = og_ISEquipWeaponAction_isValid(self)
    if isValid then
        local username = self.character:getUsername()
        local isPrimaryHandValid = CachedDataHandler.GetHandFeasibility(StaticData.SIDES_IND_STR.R, username)
        local isSecondaryHandValid = CachedDataHandler.GetHandFeasibility(StaticData.SIDES_IND_STR.L, username)
        -- Both hands are cut off, so it's impossible to equip in any way

        --TOC_DEBUG.print("isPrimaryHandValid : " .. tostring(isPrimaryHandValid))
        --TOC_DEBUG.print("isSecondaryHandValid : " .. tostring(isSecondaryHandValid))

        if not isPrimaryHandValid and not isSecondaryHandValid then
            isValid = false
        end
    end
    return isValid
end

---A recreation of the original method, but with amputations in mind
function ISEquipWeaponAction:performWithAmputation()
    --TOC_DEBUG.print("running ISEquipWeaponAction performWithAmputation")
    local hand = nil
    local otherHand = nil
    local getMethodFirst = nil
    local setMethodFirst = nil
    local getMethodSecond = nil
    local setMethodSecond = nil

    if self.primary then
        hand = StaticData.LIMBS_IND_STR.Hand_R
        otherHand = StaticData.LIMBS_IND_STR.Hand_L
        getMethodFirst = self.character.getSecondaryHandItem
        setMethodFirst = self.character.setSecondaryHandItem
        getMethodSecond = self.character.getPrimaryHandItem
        setMethodSecond = self.character.setPrimaryHandItem
    else
        hand = StaticData.LIMBS_IND_STR.Hand_L
        otherHand = StaticData.LIMBS_IND_STR.Hand_R
        getMethodFirst = self.character.getPrimaryHandItem
        setMethodFirst = self.character.setPrimaryHandItem
        getMethodSecond = self.character.getSecondaryHandItem
        setMethodSecond = self.character.setSecondaryHandItem
    end

    local isFirstValid = CheckHandFeasibility(hand)
    local isSecondValid = CheckHandFeasibility(otherHand)


    if not self.twoHands then
        if getMethodFirst(self.character) and getMethodFirst(self.character):isRequiresEquippedBothHands() then
            setMethodFirst(self.character, nil)
            -- if this weapon is already equiped in the 2nd hand, we remove it
        elseif (getMethodFirst(self.character) == self.item or getMethodFirst(self.character) == getMethodSecond(self.character)) then
            setMethodFirst(self.character, nil)
            -- if we are equipping a handgun and there is a weapon in the secondary hand we remove it
        elseif instanceof(self.item, "HandWeapon") and self.item:getSwingAnim() and self.item:getSwingAnim() == "Handgun" then
            if getMethodFirst(self.character) and instanceof(getMethodFirst(self.character), "HandWeapon") then
                setMethodFirst(self.character, nil)
            end
        else
            setMethodSecond(self.character, nil)
            -- TODO We should use the CachedData indexable instead of dcInst

            if isFirstValid then
                setMethodSecond(self.character, self.item)
                -- Check other HAND!
            elseif isSecondValid then
                setMethodFirst(self.character, self.item)
            end
        end
    else
        setMethodFirst(self.character, nil)
        setMethodSecond(self.character, nil)

        -- TOC_DEBUG.print("First Hand: " .. tostring(hand))
        -- --TOC_DEBUG.print("Prost Group: " .. tostring(prostGroup))
        -- TOC_DEBUG.print("Other Hand: " .. tostring(otherHand))
        -- --TOC_DEBUG.print("Other Prost Group: " .. tostring(otherProstGroup))

        -- TOC_DEBUG.print("isPrimaryHandValid: " .. tostring(isFirstValid))
        -- TOC_DEBUG.print("isSecondaryHandValid: " .. tostring(isSecondValid))


        if isFirstValid then
            setMethodSecond(self.character, self.item)
        end

        if isSecondValid then
            setMethodFirst(self.character, self.item)
        end
    end
end

local og_ISEquipWeaponAction_perform = ISEquipWeaponAction.perform
---@diagnostic disable-next-line: duplicate-set-field
function ISEquipWeaponAction:perform()
    og_ISEquipWeaponAction_perform(self)


    --if self.character == getPlayer() then
    local dcInst = DataController.GetInstance(self.character:getUsername())
    -- Just check it any limb has been cut. If not, we can just return from here
    if dcInst:getIsAnyLimbCut() then
        self:performWithAmputation()
    end

    --end
end

function ISInventoryPaneContextMenu.doEquipOption(context, playerObj, isWeapon, items, player)
    -- check if hands if not heavy damaged
    if (not playerObj:isPrimaryHandItem(isWeapon) or (playerObj:isPrimaryHandItem(isWeapon) and playerObj:isSecondaryHandItem(isWeapon))) and not getSpecificPlayer(player):getBodyDamage():getBodyPart(BodyPartType.Hand_R):isDeepWounded() and (getSpecificPlayer(player):getBodyDamage():getBodyPart(BodyPartType.Hand_R):getFractureTime() == 0 or getSpecificPlayer(player):getBodyDamage():getBodyPart(BodyPartType.Hand_R):getSplintFactor() > 0) then
        -- forbid reequipping skinned items to avoid multiple problems for now
        local add = true
        if playerObj:getSecondaryHandItem() == isWeapon and isWeapon:getScriptItem():getReplaceWhenUnequip() then
            add = false
        end
        if add then
            local equipOption = context:addOption(getText("ContextMenu_Equip_Primary"), items,
                ISInventoryPaneContextMenu.OnPrimaryWeapon, player)
            equipOption.notAvailable = not CheckHandFeasibility(StaticData.LIMBS_IND_STR.Hand_R)
        end
    end
    if (not playerObj:isSecondaryHandItem(isWeapon) or (playerObj:isPrimaryHandItem(isWeapon) and playerObj:isSecondaryHandItem(isWeapon))) and not getSpecificPlayer(player):getBodyDamage():getBodyPart(BodyPartType.Hand_L):isDeepWounded() and (getSpecificPlayer(player):getBodyDamage():getBodyPart(BodyPartType.Hand_L):getFractureTime() == 0 or getSpecificPlayer(player):getBodyDamage():getBodyPart(BodyPartType.Hand_L):getSplintFactor() > 0) then
        -- forbid reequipping skinned items to avoid multiple problems for now
        local add = true
        if playerObj:getPrimaryHandItem() == isWeapon and isWeapon:getScriptItem():getReplaceWhenUnequip() then
            add = false
        end
        if add then
            local equipOption = context:addOption(getText("ContextMenu_Equip_Secondary"), items,
                ISInventoryPaneContextMenu.OnSecondWeapon, player)

            equipOption.notAvailable = not CheckHandFeasibility(StaticData.LIMBS_IND_STR.Hand_L)
        end
    end
end

local noHandsImpossibleActions = {
    getText("ContextMenu_Add_escape_rope_sheet"),
    getText("ContextMenu_Add_escape_rope"),
    getText("ContextMenu_Remove_escape_rope"),
    getText("ContextMenu_Barricade"),
    getText("ContextMenu_Unbarricade"),
    getText("ContextMenu_MetalBarricade"),
    getText("ContextMenu_MetalBarBarricade"),
    getText("ContextMenu_Open_window"),
    getText("ContextMenu_Close_window"),
    getText("ContextMenu_PickupBrokenGlass"),
    getText("ContextMenu_Open_door"),
    getText("ContextMenu_Close_door"),

}


local og_ISWorldObjectContextMenu_createMenu = ISWorldObjectContextMenu.createMenu

---@param player integer
---@param worldobjects any
---@param x any
---@param y any
---@param test any
function ISWorldObjectContextMenu.createMenu(player, worldobjects, x, y, test)
    ---@type ISContextMenu
    local ogContext = og_ISWorldObjectContextMenu_createMenu(player, worldobjects, x, y, test)

    -- goddamn it, zomboid devs. ogContext could be a boolean...
    -- TBH, I don't really care about gamepad support, but all this method can break stuff. Let's just disable thisfor gamepad users.
    if type(ogContext) == "boolean" or type(ogContext) == "string" then
        return ogContext
    end

    -- The vanilla game doesn't count an item in the off hand as "equipped" for picking up glass. Let's fix that here
    local brokenGlassOption = ogContext:getOptionFromName(getText("ContextMenu_RemoveBrokenGlass"))
    local playerObj = getSpecificPlayer(player)

    if brokenGlassOption then
        local username = playerObj:getUsername()
        if (CachedDataHandler.GetHandFeasibility(StaticData.SIDES_IND_STR.R, username) and playerObj:getPrimaryHandItem()) or
            (CachedDataHandler.GetHandFeasibility(StaticData.SIDES_IND_STR.L, username) and playerObj:getSecondaryHandItem())
        then
            brokenGlassOption.notAvailable = false
            brokenGlassOption.toolTip = nil     -- This is active only when you can't do the action.
        end
    end

    -- check if no hands, disable various interactions
    if not CachedDataHandler.GetBothHandsFeasibility(playerObj:getUsername()) then
        TOC_DEBUG.print("No hands! Disabling interactions")
        for i = 1, #noHandsImpossibleActions do
            local optionName = noHandsImpossibleActions[i]
            local option = ogContext:getOptionFromName(optionName)
            if option then
                option.notAvailable = true
            end
        end
    end
    return ogContext
end

---@diagnostic disable-next-line: duplicate-set-field
local og_ISWearClothing_isValid = ISWearClothing.isValid
function ISWearClothing:isValid()
    return LimitActionsController.WrapClothingAction(self, og_ISWearClothing_isValid, self.item)
end

local og_ISClothingExtraAction_isValid = OverridenMethodsArchive.Save("ISClothingExtraAction_isValid", ISClothingExtraAction.isValid)
---@diagnostic disable-next-line: duplicate-set-field
function ISClothingExtraAction:isValid()
    return LimitActionsController.WrapClothingAction(self, og_ISClothingExtraAction_isValid, instanceItem(self.extra))
end


--* Book exception for exp

local og_ISReadABook_perform = ISReadABook.perform
function ISReadABook:perform()
    self.noExp = true
    og_ISReadABook_perform(self)

end



return LimitActionsController