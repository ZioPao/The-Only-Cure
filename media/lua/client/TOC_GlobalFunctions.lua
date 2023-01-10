
local function CheckIfStillInfected(toc_data)
    for k,v in pairs(Bodyparts) do
        if toc_data[v].is_infected == true then
            getPlayer().Say("I'm still infected...")
            return true
        end

    end

    return false

end


local function CureInfection(bodyDamage)
    bodyDamage:setInfected(false);
    bodyDamage:setInfectionMortalityDuration(-1);
    bodyDamage:setInfectionTime(-1);
    bodyDamage:setInfectionLevel(0);
    local bodyParts = bodyDamage:getBodyParts();
    for i=bodyParts:size()-1, 0, -1  do
        local bodyPart = bodyParts:get(i);
        bodyPart:SetInfected(false);
    end

    getPlayer().Say("I'm gonna be fine")

end

function CutArm(partName, surgeonFact, useBandage, bandageAlcool, usePainkiller, painkillerCount)



    local player = getPlayer();
    local toc_data = player:getModData().TOC;
    local bodyPart = player:getBodyDamage():getBodyPart(TOC_getBodyPart(partName));     -- why the fuck do we we need this

    --Set damage of body part & stress & endurance
    local stats = player:getStats();
    bodyPart:AddDamage(100 - surgeonFact);
    bodyPart:setAdditionalPain(100 - surgeonFact);
    bodyPart:setBleeding(true);
    bodyPart:setBleedingTime(100 - surgeonFact);
    bodyPart:setDeepWounded(true)
    bodyPart:setDeepWoundTime(100 - surgeonFact);
    stats:setEndurance(0 + surgeonFact);
    stats:setStress(100 - surgeonFact);

    -- Bandage
    --if useBandage and bandageAlcool then
    --    bodyPart:setBandaged(true, 10, true, bandage:getType());
    --elseif useBandage and not bandageAlcool then
    --    bodyPart:setBandaged(true, 10, false, bandage:getType());
    --end

    -- Painkiller
    --if usePainkiller then
    --    for _ = 1,painkillerCount+1 do
    --        player:getBodyDamage():JustTookPill(painkiller);
    --    end
    --    if painkillerCount < 10 then addSound(player, player:getX(), player:getY(), player:getZ(), 50-painkillerCount*5, 50-painkillerCount*5) end
    --else
    --    addSound(player, player:getX(), player:getY(), player:getZ(), 50, 50)
    --end

    -- Change modData

    local current_bodypart = bodyPart:getType()
    local body_damage = player:getBodyDamage()

    for k,v in pairs(Bodyparts) do
        
        if v == partName then
            toc_data[v].is_cut = true
            toc_data[v].is_amputation_shown = true
            toc_data[v].cicatrization_time = toc_data[v].cicatrization_base_time - surgeonFact * 50


            -- Heal the infection here
            if toc_data[v].is_infected and body_damage.getInfectionLevel() < 20 then
                toc_data[v].is_infected = false
                current_bodypart:SetBitten(false)

                -- Second check, let's see if there is any other infected limb.
                if CheckIfStillInfected(toc_data) == false then
                    CureInfection(body_damage)
                end

            end

            for depended_k, depended_v in pairs(toc_data[v].depends_on) do
                toc_data[depended_v].is_cut = true
                toc_data[depended_v].is_amputation_shown = true
                toc_data[depended_v].cicatrization_time = toc_data[v].cicatrization_base_time - surgeonFact * 50
            end
        end
    end



    --Equip cloth
    local cloth = player:getInventory():AddItem(find_clothName2_TOC(partName));
    player:setWornItem(cloth:getBodyLocation(), cloth);
    player:transmitModData();
end

function OperateArm(partName, surgeonFact, useOven)
    local player = getPlayer();
    local toc_data = player:getModData().TOC;

    if useOven then
        local stats = player:getStats();
        stats:setEndurance(0);
        stats:setStress(100);
    end


    for k,v in pairs(Bodyparts) do

        if not toc_data[v].is_operated then
            toc_data[v].is_operated = true
            toc_data[v].cicatrization_time = toc_data[v].cicatrization_time - (surgeonFact * 200)
    
            if useOven then toc_data[v].is_cauterized = true end
    
    
            for depended_k, depended_v in pairs(toc_data[v].depends_on) do
                toc_data[depended_v].is_operated = true
                toc_data[depended_v].cicatrization_time = toc_data[depended_v].cicatrization_time - (surgeonFact * 200)
                if useOven then toc_data[depended_v].is_cauterized = true end
    
            end
        end
        
    end
    SetBodyPartsStatus(player, partName, useOven)
    player:transmitModData();
end


function SetBodyPartsStatus(player, partName, useOven)

    local a_rightArm = {"RightArm", "RightForearm", "RightHand"}
    local a_rightForearm = {"RightForearm", "RightHand"}
    local a_rightHand = {"RightHand"}

    local a_leftArm = {"LeftArm", "LeftForearm", "LeftHand"}
    local a_leftForearm = {"LeftForearm", "LeftHand"}
    local a_leftHand = {"LeftHand"}

    local chosen_array = {}
    if partName == "RightArm" then
        chosen_array = a_rightArm        

    elseif partName == "RightForearm" then 
        chosen_array = a_rightForearm        

    elseif partName == "RightHand" then 
        chosen_array = a_rightHand        

    elseif partName == "LeftArm" then 
        chosen_array = a_leftArm        

    elseif partName == "LeftForearm" then 
        chosen_array = a_leftForearm        

    elseif partName == "LeftHand" then 
        chosen_array = a_leftHand        
    end


    for k,v in pairs(chosen_array) do 
        local tmpBodyPart = player:getBodyDamage():getBodyPart(TOC_getBodyPart(v));
        tmpBodyPart:setDeepWounded(false);      -- Basically like stictching
        tmpBodyPart:setDeepWoundTime(0);     
        if useOven then 
            tmpBodyPart:AddDamage(100)
            tmpBodyPart:setAdditionalPain(100);
            tmpBodyPart:setBleeding(false)
            tmpBodyPart:setBleedingTime(0)      -- no bleeding since it's been cauterized
        else 

            tmpBodyPart:setBleeding(true);
            tmpBodyPart:setBleedingTime(10);   -- Reset the bleeding   
        end

    end

end 

