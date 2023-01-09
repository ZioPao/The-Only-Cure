local function healUpdatePart(partName, modData, player)
    local modData_part = modData.TOC[partName];
    local bodyDamage = player:getBodyDamage();
    local bodyPart = bodyDamage:getBodyPart(TOC_getBodyPart(partName));
    if not bodyPart then
        print("TOC ERROR : Can't update health of " .. partName);
        return fasle;
    end
    local isBand = false;
    local bandLife = 0;
    local bandType = "";
    if bodyPart:bandaged() then isBand = true; bandLife = bodyPart:getBandageLife(); bandType = bodyPart:getBandageType() end

    --Set max heal
    if modData_part.IsCicatrized and bodyPart:getHealth() > 80 then
        bodyPart:SetHealth(80);
    elseif bodyPart:getHealth() > 40 then
        bodyPart:SetHealth(40);
    end

    --Heal
    if modData_part.IsCicatrized then
        if bodyPart:deepWounded()   then bodyPart:setDeepWounded(false) end
        if bodyPart:bleeding()      then bodyPart:setBleeding(false) end
    end
    if bodyPart:bitten() then
        bodyPart:SetBitten(false);
        if not modData.TOC.OtherBody_IsInfected and not isOtherArmInfect(modData, partName) then
            bodyDamage:setInfected(false);
            bodyDamage:setInfectionMortalityDuration(-1);
            bodyDamage:setInfectionTime(-1);
            bodyDamage:setInfectionLevel(0);
            local bodyParts = bodyDamage:getBodyParts();
            for i=bodyParts:size()-1, 0, -1  do
                local bodyPart = bodyParts:get(i);
                bodyPart:SetInfected(false);
            end
        end
    end
    if bodyPart:scratched()         then bodyPart:setScratched(false, false) end
    if bodyPart:haveGlass()         then bodyPart:setHaveGlass(false)        end
    if bodyPart:haveBullet()        then bodyPart:setHaveBullet(false, 0)    end
    if bodyPart:isInfectedWound()   then bodyPart:setInfectedWound(false)    end
    if bodyPart:isBurnt()           then bodyPart:setBurnTime(0)             end
    if bodyPart:isCut()             then bodyPart:setCut(false, false)       end
    if bodyPart:getFractureTime()>0 then bodyPart:setFractureTime(0)         end

    -- During healing
    -- this will not happen every 10 sec or some shit like that.
    -- We will allow stitching. Surgery is needed only to have a faster cicatrization



    if modData_part.IsCut and not modData_part.IsCicatrized then

         if modData_part.CicaTimeLeft < 0 then 
            player:Say(getText('UI_ContextMenu_My') .. partName .. getText('UI_ContextMenu_Now_cut'))       -- dunno if this works. 
            modData_part.IsCicatrized = true;
            player:getTraits():add("Brave")
            player:getTraits():add("Insensitive")
            bodyPart:setBleeding(false);
            bodyPart:setDeepWounded(false);
            bodyPart:setBleedingTime(0);
            bodyPart:setDeepWoundTime(0);
            player:transmitModData()
         end


    end

    --Phantom pain
    if modData_part.ToDisplay then
        if ZombRand(1, 100) < 10 then
            if modData_part.IsBurn then x = 60 else x = 30 end
            bodyPart:setAdditionalPain(ZombRand(1, x));
        end
    end
    if isBand then bodyPart:setBandaged(true, bandLife, false, bandType) end
end

local function isOtherArmInfect(modData, partName)
    local names = {"RightHand", "RightForearm", "RightArm", "LeftHand", "LeftForearm", "LeftArm"}
    names[partName] = nil;

    for i,v in pairs(names) do
        if modData.TOC[v].IsInfected then return true end
    end
    return false
end

function UpdatePlayerHealth(player, modData)
    local bodyDamage = player:getBodyDamage()
    local partNames = {"RightHand", "RightForearm", "RightArm", "LeftHand", "LeftForearm", "LeftArm"}

    if player:HasTrait("Insensitive") then bodyDamage:setPainReduction(49) end

    for i,name in pairs(partNames) do
        if modData.TOC[name].IsCut then healUpdatePart(name, modData, player) end
    end
end