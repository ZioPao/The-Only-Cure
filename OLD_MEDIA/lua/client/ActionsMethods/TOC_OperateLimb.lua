------------------------------------------
-------- THE ONLY CURE --------
------------------------------------------
--------- OPERATE LIMB FUNCTIONS ---------

local function FixSingleBodyPartType(bodyPartType, useOven)
    bodyPartType:setDeepWounded(false) --Basically like stitching
    bodyPartType:setDeepWoundTime(0)
    if useOven then
        bodyPartType:AddDamage(100)
        bodyPartType:setAdditionalPain(100);
        bodyPartType:setBleeding(false)
        bodyPartType:setBleedingTime(0) -- no bleeding since it's been cauterized
    else
        -- TODO Think a little better about this, do we want to trigger bleeding or not?
        bodyPartType:setBleeding(false)

        --body_part_type:setBleedingTime(ZombRand(1, 5))   -- Reset the bleeding, maybe make it random
    end
end

local function SetBodyPartsStatusAfterOperation(player, limbParameters, partName, useOven)


    local bodyPartType = player:getBodyDamage():getBodyPart(TOC_Common.GetAdjacentBodyPartFromPartName(partName))
    FixSingleBodyPartType(bodyPartType, useOven)

    for _, v in pairs(limbParameters[partName].dependsOn) do
        local dependedBodyPartType = player:getBodyDamage():getBodyPart(TOC_Common.GetAdjacentBodyPartFromPartName(v))
        FixSingleBodyPartType(dependedBodyPartType, useOven)

    end
end

----------------------------------------------------------------------------------


---Main function to operate a limb after amputation
---@param partName any
---@param surgeonFactor any
---@param useOven boolean wheter using oven instead of a kit or not
function TOC.OperateLimb(partName, surgeonFactor, useOven)

    local player = getPlayer()


    local TOCModData = player:getModData().TOC

    local limbParameters = TOC.limbParameters
    local limbsData = TOCModData.limbs

    if useOven then
        local stats = player:getStats()
        stats:setEndurance(100)
        stats:setStress(100)
    end

    if limbsData[partName].isOperated == false and limbsData[partName].isCut == true then
        limbsData[partName].isOperated = true
        limbsData[partName].cicatrizationTime = limbsData[partName].cicatrizationTime - (surgeonFactor * 200)
        if useOven then limbsData[partName].isCauterized = true end
        for _, dependedPart in pairs(limbParameters[partName].dependsOn) do
            limbsData[dependedPart].isOperated = true
            -- TODO We should not have cicatrization time for depended parts.
            -- limbsData[dependedPart].cicatrizationTime = limbsData[dependedPart].cicatrizationTime -
            --     (surgeonFactor * 200)
            if useOven then limbsData[dependedPart].isCauterized = true end
        end

    end

    SetBodyPartsStatusAfterOperation(player, limbParameters, partName, useOven)
end
