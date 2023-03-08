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
        if useOven then limbsData[partName].is_cauterized = true end
        for _, depended_v in pairs(limbParameters[partName].depends_on) do
            limbsData[depended_v].isOperated = true
            limbsData[depended_v].cicatrizationTime = limbsData[depended_v].cicatrizationTime -
                (surgeonFactor * 200)
            if useOven then limbsData[depended_v].isCauterized = true end
        end

    end

    SetBodyPartsStatusAfterOperation(player, limbParameters, partName, useOven)
end
