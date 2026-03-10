local LocalPlayerController = require("TOC/Controllers/LocalPlayerController")
local DataController = require("TOC/Controllers/DataController")
local CachedDataHandler = require("TOC/Handlers/CachedDataHandler")
local CommonMethods = require("TOC/CommonMethods")
local StaticData = require("TOC/StaticData")


--* Time to perform actions overrides
local og_ISBaseTimedAction_adjustMaxTime = ISBaseTimedAction.adjustMaxTime
--- Adjust time
---@diagnostic disable-next-line: duplicate-set-field
function ISBaseTimedAction:adjustMaxTime(maxTime)
    local time = og_ISBaseTimedAction_adjustMaxTime(self, maxTime)
    --TOC_DEBUG.print("Running override for adjustMaxTime")
    -- Exceptions handling, if we find that parameter then we just use the original time

    if self.skipTOC then
        TOC_DEBUG.print("Should skip TOC stuff")
        return time
    end

    -- Action is valid, check if we have any cut limb and then modify maxTime
    local dcInst = DataController.GetInstance(self.character:getUsername())
    local amputatedLimbs = dcInst and dcInst:getIsAnyLimbCut() and CachedDataHandler.GetAmputatedLimbs(self.character:getUsername())
    if time ~= -1 and amputatedLimbs then
        --TOC_DEBUG.print("Overriding adjustMaxTime")
        for k, _ in pairs(amputatedLimbs) do
            local limbName = k
            local perkAmp = Perks["Side_" .. CommonMethods.GetSide(limbName)]
            local perkLevel = self.character:getPerkLevel(perkAmp)

            if dcInst:getIsProstEquipped(limbName) then
                local perkProst = Perks["ProstFamiliarity"]
                perkLevel = perkLevel + self.character:getPerkLevel(perkProst)
            end

            local perkLevelScaled
            if perkLevel ~= 0 then perkLevelScaled = perkLevel / 10 else perkLevelScaled = 0 end
            --TOC_DEBUG.print("Perk Level: " .. tostring(perkLevel))
            --TOC_DEBUG.print("OG time: " .. tostring(time))

            -- Modified Time shouldn't EVER be lower compared to the og one.
            local modifiedTime = time * (StaticData.LIMBS_TIME_MULTIPLIER_IND_NUM[limbName] - perkLevelScaled)

            if modifiedTime >= time then
                time = modifiedTime
            end

            --TOC_DEBUG.print("Modified time: " .. tostring(time))
        end

    end

    return time
end

--* Random bleeding during cicatrization
local og_ISBaseTimedAction_perform = ISBaseTimedAction.perform
---@diagnostic disable-next-line: duplicate-set-field
function ISBaseTimedAction:perform()
    og_ISBaseTimedAction_perform(self)

    if isServer() then return end

    local username = self.character:getUsername()
    local dcInst = DataController.GetInstance(username)
    if not dcInst or not dcInst:getIsAnyLimbCut() then return end

    local amputatedLimbs = CachedDataHandler.GetAmputatedLimbs(username)
    if not amputatedLimbs then return end

    for k, _ in pairs(amputatedLimbs) do
        local limbName = k
        if dcInst:getIsCut(limbName) and dcInst:getIsVisible(limbName) then
            if not dcInst:getIsCicatrized(limbName) and dcInst:getIsProstEquipped(limbName) then
                LocalPlayerController.TryRandomBleed(self.character, limbName)
            end
        end
    end
end
