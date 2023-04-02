------------------------------------------
-------------- THE ONLY CURE -------------
------------------------------------------
------------- UPDATE EVENTS --------------


require "TOC_Init"

local function CheckIfPlayerIsInfected(player, limbsData)

    local bodyDamage = player:getBodyDamage()

    -- Check for amputable limbs
    for _, v in ipairs(TOC_Common.GetAcceptableBodyPartTypes()) do
        local partName = TOC_Common.GetPartNameFromBodyPartType(v)
        local partData = limbsData[partName]
        local bodyPart = bodyDamage:getBodyPart(v)


        if bodyPart:bitten() and partData ~= nil then
            if partData.isCut == false then
                partData.isInfected = true

            end

        end
    end

    -- Check for everything else
    for _, v in pairs(TOC_Common.GetOtherBodyPartTypes()) do
        if bodyDamage:getBodyPart(v):bitten() then
            limbsData.isOtherBodypartInfected = true -- Even one is enough, stop cycling if we find it
            break
        end
    end
end
local function ManagePhantomPain(player, TOCModData)

    local limbsData = TOCModData.limbs
    local limbParameters = TOC.limbParameters


    local body_damage = player:getBodyDamage()

    for _, partName in pairs(TOC_Common.GetPartNames()) do

        if limbsData[partName].isCut and limbsData[partName].isAmputationShown and ZombRand(1, 100) < 10 then
            local bodyPart = body_damage:getBodyPart(TOC_Common.GetBodyPartFromPartName(partName))
            local addedPain
            if limbsData[partName].isCauterized then addedPain = 60 else addedPain = 30 end
            bodyPart:setAdditionalPain(ZombRand(1, addedPain))
            for _, depended_v in pairs(limbParameters[partName].dependsOn) do
                if limbsData[depended_v].isCauterized then addedPain = 60 else addedPain = 30 end
                bodyPart:setAdditionalPain(ZombRand(1, addedPain))
            end


        end
    end

end
local function SetHealthStatusForBodyPart(partData, partName, player)


    -- In case the player gets bit in a cut area, we have to heal him...



    local bodyDamage = player:getBodyDamage()
    local bodyPart = bodyDamage:getBodyPart(TOC_Common.GetBodyPartFromPartName(partName))
    if not bodyPart then
        print("TOC ERROR: Can't update health of " .. partName)
        return false
    end

    -- Check bandages
    local isBandaged = false
    local bandageLife = 0
    local bandageType = ""

    -- TODO Bandages should have some disadvantage when not operated... Like getting drenched or something
    if bodyPart:bandaged() then
        isBandaged = true -- this is useless
        bandageLife = bodyPart:getBandageLife()
        bandageType = bodyPart:getBandageType()

    end


    -- Check for stitching
    local isStitched = false    -- TODO Implement this



    if partData[partName].isCut then
        --print("TOC: Check update for " .. part_name)
        -- if the player gets attacked and damaged in a cut area we have to reset it here since it doesn't make any sense
        -- this is using map 1:1, so it doesn't affect the wound caused by the amputation

        -- TODO if the players gets damaged in a cut part and it has a prosthesis, damage the prosthesis
 
        bodyPart:setBleeding(false)
        bodyPart:setDeepWounded(false)
        bodyPart:setBleedingTime(0)
        bodyPart:setDeepWoundTime(0)
        bodyPart:SetBitten(false)
        bodyPart:setScratched(false, false)        -- ffs it always fucks me 
        bodyPart:setCut(false)
        bodyPart:SetInfected(false)

        bodyPart:setBiteTime(0)
        partData[partName].isInfected = false

        -- Set max health for body part
        if partData[partName].isCicatrized and bodyPart:getHealth() > 80 then
            bodyPart:SetHealth(80)
        elseif bodyPart:getHealth() > 40 then
            bodyPart:SetHealth(40)
        end






        -- Cicatrization check
        if not partData[partName].isCicatrized then
            if partData[partName].cicatrizationTime < 0 then
                partData[partName].isCicatrized = true
                local playerInv = player:getInventory()
                local amputatedClothingItemName = TOC_Common.FindAmputationOrProsthesisName(partName, player, "Amputation")
                local amputatedClothingItem = playerInv:FindAndReturn(amputatedClothingItemName)

                player:removeWornItem(amputatedClothingItem)
                TOC_Visuals.SetTextureForAmputation(amputatedClothingItem, player, true)
                player:setWornItem(amputatedClothingItem:getBodyLocation(), amputatedClothingItem)
                
                if (not player:HasTrait("Brave")) and ZombRand(1, 11) > 5 then
                    player:getTraits():add("Brave")

                end

                if (not player:HasTrait("Insensitive")) and ZombRand(1, 11) > 5 then
                    player:getTraits():add("Insensitive")
                end
            end
        end
    end
end
local function UpdatePlayerHealth(player, partData)
    local bodyDamage = player:getBodyDamage()

    if player:HasTrait("Insensitive") then bodyDamage:setPainReduction(49) end

    for _, partName in pairs(TOC_Common.GetPartNames()) do
        if partData[partName].isCut then
            SetHealthStatusForBodyPart(partData, partName, player)

        end
    end
end

-------------------------------------------

-- MAIN UPDATE FUNCTIONS
TOC.UpdateOnTick = function()

    local player = getPlayer()
    if player == nil then
        return
    end

    local TOCModData = player:getModData().TOC

    if TOCModData ~= nil then
        CheckIfPlayerIsInfected(player, TOCModData.limbs)
        UpdatePlayerHealth(player, TOCModData.limbs)
    end


end
TOC.UpdateEveryTenMinutes = function()

    local player = getPlayer()

    if player == nil then
        return
    end

    local partData = player:getModData().TOC.limbs

    --Experience for prosthesis user
    for _, side in pairs(TOC.sideNames) do
        if partData[TOC_Common.ConcatPartName(side, "Hand")].isProsthesisEquipped or partData[TOC_Common.ConcatPartName(side, "LowerArm")].isProsthesisEquipped then
            player:getXp():AddXP(Perks[TOC_Common.ConcatPartName(side, "Hand")], 4)
        end

    end

    -- Updates the cicatrization time
    for _, partName in pairs(TOC_Common.GetPartNames()) do
        if partData[partName].isCut and not partData[partName].isCicatrized then

            --Wound cleanliness contributes to cicatrization
            -- TODO we reset this stuff every time we restart the game for compat reason, this is an issue
            local amputatedLimbItem = TOC_Common.GetAmputationItemInInventory(player, partName)
            local itemDirtyness = amputatedLimbItem:getDirtyness()/100
            local itemBloodyness = amputatedLimbItem:getBloodLevel()/100

            local modifier = SandboxVars.TOC.CicatrizationSpeedMultiplier - itemBloodyness - itemDirtyness

            --print("TOC: Type " .. amputated_limb_item:getFullType())
            --print("TOC: Dirtyness " .. item_dirtyness)
            --print("TOC: Bloodyness " .. item_bloodyness)


            partData[partName].cicatrizationTime = partData[partName].cicatrizationTime - modifier

            
        end
    end

end
TOC.UpdateEveryOneMinute = function()

    local player = getPlayer()
    -- To prevent errors during loading
    if player == nil then
        return
    end

    local TOCModData = player:getModData().TOC


    if SandboxVars.TOC.EnablePhantomPain then
        if TOCModData ~= nil then
            ManagePhantomPain(player, TOCModData)
        end
    end






    -- Updates TOC data in a global way, basically player:transmitModData but it works
    -- Sends only Limbs since the other stuff is mostly static
    if TOCModData ~= nil then
        -- FIXME Send little packets instead of the whole thing?
            -- TODO we shouldn't run this if we're in SP I guess?
        sendClientCommand(player, 'TOC', 'ChangePlayerState', { TOCModData.limbs } )
    end


end

