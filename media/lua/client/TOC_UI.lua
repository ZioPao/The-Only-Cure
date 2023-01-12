local mainUI, descUI, confirmUI, confirmUIMP

function GetConfirmUIMP()
    return confirmUIMP;
end

-- Usefull
    local function prerenderFuncMP()
        local toSee = confirmUIMP;
        if confirmUIMP.responseReceive then
            if not confirmUIMP.responseCan then
                getPlayer():Say("I can't do that !")
                confirmUIMP.responseReceive = false;
                confirmUIMP:close();
                return false;
            end
            SetConfirmUIMP(confirmUIMP.responseAction, confirmUIMP.responseIsBitten, confirmUIMP.responseUserName, confirmUIMP.responsePartName);
        end
    end


    -- TODO Remove this crap
    local function isPlayerHaveSaw()
        local playerInv = getPlayer():getInventory();
        local item = playerInv:getItemFromType('Saw') or playerInv:getItemFromType('GardenSaw') or playerInv:getItemFromType('Chainsaw');
        return item;
    end



    local function isPlayerHavePainkiller()
        local playerInv = getPlayer():getInventory();
        local item = playerInv:getItemFromType('Pills');
        return item;
    end

    local function isPlayerHaveBandage()
        local playerInv = getPlayer():getInventory();
        local item = playerInv:getItemFromType('AlcoholBandage') or playerInv:getItemFromType('Bandage');
        return item;
    end

    local function getImageName(partName, modData)
        local partData = modData[partName];
        local name = "";
        if partData.is_cut and partData.is_cicatrized and partData.has_prosthesis_equipped then -- Cut and equip
            if partName == "RightHand" or partName == "LeftHand" then
                name = "media/ui/TOC/" .. partName .. "/Hook.png";
            else
                name = "media/ui/TOC/" .. partName .. "/Prothesis.png";
            end
        elseif partData.is_cut and partData.is_cicatrized and not partData.has_prosthesis_equipped and partData.is_amputation_shown then -- Cut and heal
            name = "media/ui/TOC/" .. partName .. "/Cut.png";
        elseif partData.is_cut and not partData.is_cicatrized and partData.is_amputation_shown and not partData.is_operated then -- Cut not heal
            name = "media/ui/TOC/" .. partName .. "/Bleed.png";
        elseif partData.is_cut and not partData.is_cicatrized and partData.is_amputation_shown and partData.is_operated then -- Cut not heal
            name = "media/ui/TOC/" .. partName .. "/Operate.png";
        elseif partData.is_cut and not partData.is_amputation_shown then -- Empty (like hand if forearm cut)
            name = "media/ui/TOC/Empty.png";
        elseif not partData.is_cut and getPlayer():getBodyDamage():getBodyPart(TOC_getBodyPart(partName)):bitten() then -- Not cut but bitten
            name = "media/ui/TOC/" .. partName .. "/Bite.png";
        else  -- Not cut
            name = "media/ui/TOC/" .. partName .. "/Base.png";
        end

        -- If foreaerm equip, change hand
        if partName == "RightHand" and modData["RightForearm"].has_prosthesis_equipped then
            name = "media/ui/TOC/" .. partName .. "/Hook.png";
        elseif partName == "LeftHand" and modData["LeftForearm"].has_prosthesis_equipped then
            name = "media/ui/TOC/" .. partName .. "/Hook.png";
        end
        return name;
    end

    local function partNameToBodyLoc(name)
        if name == "RightHand"      then return "ArmRight_Prot" end
        if name == "RightForearm"   then return "ArmRight_Prot" end
        if name == "RightArm"       then return "ArmRight_Prot" end
        if name == "LeftHand"       then return "ArmLeft_Prot" end
        if name == "LeftForearm"    then return "ArmLeft_Prot" end
        if name == "LeftArm"        then return "ArmLeft_Prot" end
    end

    function find_itemWorn_TOC(partName)
        local wornItems = getPlayer():getWornItems();
        for i=1,wornItems:size()-1 do -- Maybe wornItems:size()-1
            local item = wornItems:get(i):getItem();
            if item:getBodyLocation() == partNameToBodyLoc(partName) then
                return item;
            end
        end
        return false;
    end

    local function findMinMax(lv)
        local min, max
        if lv == 1 then
            min = 0;
            max = 75;
        elseif lv == 2 then
            min = 75;
            max = 150 + 75;
        elseif lv == 3 then
            min = 150;
            max = 300 + 75 + 150;
        elseif lv == 4 then
            min = 300;
            max = 750 + 75 + 150 + 300;
        elseif lv == 5 then
            min = 750;
            max = 1500 + 75 + 150 + 300 + 750;
        elseif lv == 6 then
            min = 1500;
            max = 3000 + 75 + 150 + 300 + 750 + 1500;
        elseif lv == 7 then
            min = 3000;
            max = 4500 + 75 + 150 + 300 + 750 + 1500 + 3000;
        elseif lv == 8 then
            min = 4500;
            max = 6000 + 75 + 150 + 300 + 750 + 1500 + 3000 + 4500;
        elseif lv == 9 then
            min = 6000;
            max = 7500 + 75 + 150 + 300 + 750 + 1500 + 3000 + 4500 + 6000;
        elseif lv == 10 then
            min = 7500;
            max = 9000 + 75 + 150 + 300 + 750 + 1500 + 3000 + 4500 + 6000 + 7500;
        end
        return min, max;
    end
-- end Usefull

-- Function to update text/button of UIs
local function setDescUI(toc_data, partName)

    --we can easily fix this crap from here for MP compat
    -- forces sync?
    --local player_obj = getSpecificPlayer(player)
    -- TODO set correct player

    
    --local testModData = player:getModData()


    local partData = toc_data[partName]
    descUI["textTitle"]:setText(getDisplayText_TOC(partName))
    descUI.partNameAct = partName

    -- Cut and equip
    if partData.is_cut and partData.is_cicatrized and partData.has_prosthesis_equipped then 
        descUI["textEtat"]:setText("Cut and healed")
        descUI["textEtat"]:setColor(1, 0, 1, 0)
        descUI["b1"]:setText("Unequip")
        descUI["b1"]:addArg("option", "Unequip")
        descUI["b1"]:setVisible(true)

    -- Cut and healed
    elseif partData.is_cut and partData.is_cicatrized and not partData.has_prosthesis_equipped and partData.is_amputation_shown then 
        descUI["textEtat"]:setText("Cut and healed");
        descUI["textEtat"]:setColor(1, 0, 1, 0);
        if partName == "RightArm" or partName == "LeftArm" then
            descUI["b1"]:setVisible(false);
        else
            descUI["b1"]:setText("Equip");
            descUI["b1"]:addArg("option", "Equip");
            descUI["b1"]:setVisible(true);
        end

     -- Cut but not healed
    elseif partData.is_cut and not partData.is_cicatrized and partData.is_amputation_shown then
        if partData.is_operated then
            if partData.cicatrization_time > 1000 then
                descUI["textEtat"]:setText("Still a long way to go")
                descUI["textEtat"]:setColor(1, 0.8, 1, 0.2);
            elseif partData.cicatrization_time > 500 then
                descUI["textEtat"]:setText("Starting to get better")
                descUI["textEtat"]:setColor(1, 0.8, 1, 0.2)

            elseif partData.cicatrization_time > 100 then
                descUI["textEtat"]:setText("Almost cicatrized");
                descUI["textEtat"]:setColor(1, 0.8, 1, 0.2);
            end
        else
            if partData.cicatrization_time > 1000 then
                descUI["textEtat"]:setText("It hurts so much...")
                descUI["textEtat"]:setColor(1, 1, 0, 0)
            elseif partData.cicatrization_time > 500 then
                descUI["textEtat"]:setText("It still hurts a lot")
                descUI["textEtat"]:setColor(1, 0.8, 1, 0.2)
            elseif partData.cicatrization_time > 500 then
                descUI["textEtat"]:setText("I think it's almost over...")
                descUI["textEtat"]:setColor(1, 0.8, 1, 0.2)
            end
        end


        -- Set visibility
        if partData.is_operated then
            descUI["b1"]:setVisible(false);
        else
            descUI["b1"]:setText("Operate");
            descUI["b1"]:addArg("option", "Operate");
            descUI["b1"]:setVisible(true);
        end
    elseif partData.is_cut and not partData.is_amputation_shown then -- Empty (hand if forearm cut)
        descUI["textEtat"]:setText("Nothing here...");
        descUI["textEtat"]:setColor(1, 1, 1, 1);
        descUI["b1"]:setVisible(false);
    elseif not partData.is_cut and getPlayer():getBodyDamage():getBodyPart(TOC_getBodyPart(partName)):bitten() then     --TODO fix for MP
        descUI["textEtat"]:setText("Bitten...");
        descUI["textEtat"]:setColor(1, 1, 0, 0);
        if isPlayerHaveSaw() then
            descUI["b1"]:setVisible(true);
            descUI["b1"]:setText("Cut");
            descUI["b1"]:addArg("option", "Cut");
        else
            descUI["b1"]:setVisible(false);
        end
    elseif not partData.is_cut then -- Not cut
        descUI["textEtat"]:setText("Not cut");
        descUI["textEtat"]:setColor(1, 1, 1, 1);
        if isPlayerHaveSaw() then
            descUI["b1"]:setVisible(true);
            descUI["b1"]:setText("Cut");
            descUI["b1"]:addArg("option", "Cut");
        else
            descUI["b1"]:setVisible(false);
        end
    end

    -- Set text for level
    local player = getPlayer()
    if string.find(partName, "Right") then
        local lv = player:getPerkLevel(Perks.RightHand) + 1;
        descUI["textLV2"]:setText("Level:   " .. lv .. " / 10");

        local xp = player:getXp():getXP(Perks.RightHand);
        local min, max = findMinMax(lv);
        descUI["pbarNLV"]:setMinMax(min, max);
        descUI["pbarNLV"]:setValue(xp);
    else
        local lv = player:getPerkLevel(Perks.LeftHand) + 1;
        descUI["textLV2"]:setText("Level:   " .. lv .. " / 10");

        local xp = player:getXp():getXP(Perks.LeftHand);
        local min, max = findMinMax(lv);
        descUI["pbarNLV"]:setMinMax(min, max);
        descUI["pbarNLV"]:setValue(xp);
    end
end

local function setConfirmUI(action)
    confirmUI.actionAct = action;
    confirmUI:setInCenterOfScreen();
    confirmUI:bringToTop();
    confirmUI:open();
    if action == "Cut" then
        if isPlayerHaveBandage() and isPlayerHavePainkiller() then
            confirmUI["text2"]:setText("You have bandage and painkiller");
            confirmUI["text2"]:setColor(1, 0, 1, 0);
        else
            confirmUI["text2"]:setText("You miss bandage or painkiller");
            confirmUI["text2"]:setColor(1, 1, 0, 0);
        end
        if isPlayerHaveSaw() and getPlayer():getBodyDamage():getBodyPart(TOC_getBodyPart(descUI.partNameAct)):bitten() then
            confirmUI["text3"]:setText("You are well bitten and you have a saw... it's time");
            confirmUI["text3"]:setColor(1, 0, 1, 0);
        elseif isPlayerHaveSaw() and not getPlayer():getBodyDamage():getBodyPart(TOC_getBodyPart(descUI.partNameAct)):bitten() then
            confirmUI["text3"]:setText("What are you doing? You're okay !");
            confirmUI["text3"]:setColor(1, 1, 0, 0);
        else
            confirmUI["text3"]:setText("You miss a saw");
            confirmUI["text3"]:setColor(1, 1, 0, 0);
        end
    elseif action == "Operate" then
        confirmUI["text2"]:setText("");
        confirmUI["text3"]:setText("You are going to operate " .. getDisplayText_TOC(descUI.partNameAct));
        confirmUI["text3"]:setColor(1, 1, 1, 1);
    end
end

function SetConfirmUIMP(action, isBitten, userName, partName)
    confirmUIMP:setInCenterOfScreen();
    confirmUIMP:bringToTop();
    confirmUIMP:open();
    if action == "Cut" then
        confirmUIMP["text4"]:setText("You're gonna " .. action .. " the " .. getDisplayText_TOC(partName) .. " of " .. userName);
        if isPlayerHaveBandage() and isPlayerHavePainkiller() then
            confirmUIMP["text2"]:setText("You have bandage and painkiller");
            confirmUIMP["text2"]:setColor(1, 0, 1, 0);
            
        else
            confirmUIMP["text2"]:setText("You miss bandage or painkiller");
            confirmUIMP["text2"]:setColor(1, 1, 0, 0);
        end
        if isPlayerHaveSaw() and isBitten then
            confirmUIMP["text3"]:setText("You are well bitten and you have a saw... it's time");
            confirmUIMP["text3"]:setColor(1, 0, 1, 0);
            confirmUIMP["b1"]:setVisible(true);
            confirmUIMP["b2"]:setVisible(true);
        elseif isPlayerHaveSaw() and not isBitten then
            confirmUIMP["text3"]:setText("What are you doing? You're okay !");
            confirmUIMP["text3"]:setColor(1, 1, 0, 0);
            confirmUIMP["b1"]:setVisible(true);
            confirmUIMP["b2"]:setVisible(true);
        else
            confirmUIMP["text3"]:setText("You're missing a saw");
            confirmUIMP["text3"]:setColor(1, 1, 0, 0);
            confirmUIMP["b1"]:setVisible(false);
            confirmUIMP["b2"]:setVisible(true);
        end
    elseif action == "Operate" then
        confirmUIMP["text4"]:setText("You gonna " .. action .. " the " .. getDisplayText_TOC(partName) .. " of " .. userName);
        confirmUIMP["text2"]:setText("");
        confirmUIMP["text3"]:setText("");
        confirmUIMP["b1"]:setVisible(true);
        confirmUIMP["b2"]:setVisible(true);
    elseif action == "Wait server" then
        confirmUIMP["text4"]:setText(action);
        confirmUIMP["text3"]:setText("");
        confirmUIMP["text2"]:setText("");
        confirmUIMP["b1"]:setVisible(false);
        confirmUIMP["b2"]:setVisible(false);
    end
end

local function setImageMainUI(toc_data)
    mainUI["b11"]:setPath(getImageName("RightArm", toc_data));
    mainUI["b12"]:setPath(getImageName("LeftArm", toc_data));

    mainUI["b21"]:setPath(getImageName("RightForearm", toc_data));
    mainUI["b22"]:setPath(getImageName("LeftForearm", toc_data));

    mainUI["b31"]:setPath(getImageName("RightHand", toc_data));
    mainUI["b32"]:setPath(getImageName("LeftHand", toc_data));
end


-- Functions for button of UIs
local function confirmPress(button, args)
    local player = getPlayer();
    if confirmUI.actionAct == "Cut" then
        if args.option == "yes" then
            ISTimedActionQueue.add(IsCutArm:new(player, player, descUI.partNameAct));
        else
            getPlayer():Say("Never mind");
        end
    end
    if confirmUI.actionAct == "Operate" then
        if args.option == "yes" then
            local playerInv = player:getInventory();
            local item = playerInv:getItemFromType('TOC.Real_surgeon_kit') or playerInv:getItemFromType('TOC.Surgeon_kit') or playerInv:getItemFromType('TOC.Improvised_surgeon_kit');
            if item then
                ISTimedActionQueue.add(ISOperateArm:new(player, player, item, descUI.partNameAct, false));
            else
                player:Say("I need a kit");
            end
        else
            getPlayer():Say("Never mind");
        end
    end
    mainUI:close();
end

local function confirmPressMP(button, args)
    local player = getPlayer();
    if confirmUIMP.actionAct == "Cut" then
        if args.option == "yes" then
            getPlayer():Say("Hold on, I believe in you!");
            ISTimedActionQueue.add(IsCutArm:new(confirmUIMP.patient, player, confirmUIMP.partNameAct));
        else
            getPlayer():Say("Alright...");
        end
    end
    if confirmUIMP.actionAct == "Operate" then
        if args.option == "yes" then
            local playerInv = player:getInventory();
            local item = playerInv:getItemFromType('TOC.Real_surgeon_kit') or playerInv:getItemFromType('TOC.Surgeon_kit') or playerInv:getItemFromType('TOC.Improvised_surgeon_kit');
            if item then
                getPlayer():Say("Not moving ! Ok ?");
                ISTimedActionQueue.add(ISOperateArm:new(confirmUIMP.patient, player, item, confirmUIMP.partNameAct, false));
            else
                player:Say("I need a kit");
            end
        else
            getPlayer():Say("Never mind");
        end
    end
    confirmUIMP:close();
    confirmUIMP.responseReceive = false;
end

local function mainPress(button, args)
    descUI:open()
    descUI:setPositionPixel(mainUI:getRight(), mainUI:getY())
    setDescUI(args.toc_data, args.part)
end

local function descPress(button, args)
    local player = getPlayer();
    local playerInv = player:getInventory();
    if args.option == "Cut" then


        -- TODO Change to correct player
        local modData = player:getModData().TOC;
        -- Do not cut if prothesis equip
        if (string.find(descUI.partNameAct, "Right") and (modData["RightHand"].has_prosthesis_equipped or modData["RightForearm"].has_prosthesis_equipped)) 
        or (string.find(descUI.partNameAct, "Left") and (modData["LeftHand"].has_prosthesis_equipped or modData["LeftForearm"].has_prosthesis_equipped)) then
            player:Say("I need to remove my prothesis first");
            mainUI:close();
            return false;
        end
        setConfirmUI("Cut");
    elseif args.option == "Operate" then
        setConfirmUI("Operate");
    elseif args.option == "Equip" then
        local item = playerInv:getItemFromType('TOC.MetalHand') or playerInv:getItemFromType('TOC.MetalHook') or playerInv:getItemFromType('TOC.WoodenHook');
        if item then
            ISTimedActionQueue.add(ISInstallProthesis:new(player, item, player:getBodyDamage():getBodyPart(TOC_getBodyPart(descUI.partNameAct))))
        else
            player:Say("I need a prosthesis");
        end
        mainUI:close();
    elseif args.option == "Unequip" then
        ISTimedActionQueue.add(ISUninstallProthesis:new(player, find_itemWorn_TOC(descUI.partNameAct), player:getBodyDamage():getBodyPart(TOC_getBodyPart(descUI.partNameAct))));
        mainUI:close();
    end
end


-- Make the UIS

local function SetCorrectArgsMainUI(toc_data)


    -- TODO Make it less shitty
    mainUI["b11"]:addArg("toc_data", toc_data)

    mainUI["b12"]:addArg("toc_data", toc_data)

    mainUI["b21"]:addArg("toc_data", toc_data)

    mainUI["b22"]:addArg("toc_data", toc_data)

    mainUI["b31"]:addArg("toc_data", toc_data)
   
    mainUI["b32"]:addArg("toc_data", toc_data)

end



local function makeMainUI(regen)


    mainUI = NewUI()
    mainUI:setTitle("The Only Cure Menu");
    mainUI:setWidthPercent(0.1);

    mainUI:addImageButton("b11", "", mainPress)
    mainUI["b11"]:addArg("part", "RightArm")
    --mainUI["b11"]:addArg("player", character)


    mainUI:addImageButton("b12", "", mainPress);
    mainUI["b12"]:addArg("part", "LeftArm");
    --mainUI["b12"]:addArg("player", character)

    mainUI:nextLine();

    mainUI:addImageButton("b21", "", mainPress);
    mainUI["b21"]:addArg("part", "RightForearm");
    --mainUI["b21"]:addArg("player", character)


    mainUI:addImageButton("b22", "", mainPress);
    mainUI["b22"]:addArg("part", "LeftForearm");
    --mainUI["b22"]:addArg("player", character)

    mainUI:nextLine();

    mainUI:addImageButton("b31", "", mainPress);
    mainUI["b31"]:addArg("part", "RightHand");
    --mainUI["b31"]:addArg("player", character)

    mainUI:addImageButton("b32", "", mainPress);
    mainUI["b32"]:addArg("part", "LeftHand");
    --mainUI["b32"]:addArg("player", character)

    mainUI:saveLayout();
end

local function makeDescUI()
    descUI = NewUI();
    descUI:setTitle("The only cure description");
    descUI:isSubUIOf(mainUI);
    descUI:setWidthPixel(250);
    descUI:setColumnWidthPixel(1, 100);

    descUI:addText("textTitle", "Right arm", "Large", "Center");
    descUI:nextLine();

    descUI:addText("textLV2", "Level 3/10", _, "Center");
    descUI:nextLine();

    descUI:addText("textLV", "Next LV:", _, "Right");
    descUI:addProgressBar("pbarNLV", 39, 0, 100);
    descUI["pbarNLV"]:setMarginPixel(10, 6);
    descUI:nextLine();

    descUI:addEmpty("border1");
    descUI:setLineHeightPixel(1);
    descUI["border1"]:setBorder(true);
    descUI:nextLine();

    descUI:addEmpty();
    descUI:nextLine();

    descUI:addText("textEtat", "Is Cut!", "Medium", "Center");
    descUI["textEtat"]:setColor(1, 1, 0, 0);
    descUI:nextLine();

    descUI:addEmpty();
    descUI:nextLine();

    descUI:addButton("b1", "Operate", descPress);

    descUI:saveLayout();
end

local function makeConfirmUI()
    confirmUI = NewUI();
    confirmUI:isSubUIOf(descUI);

    confirmUI:addText("text1", "Are you sure ?", "Title", "Center");
    confirmUI:setLineHeightPixel(getTextManager():getFontHeight(confirmUI.text1.font) + 10)
    confirmUI:nextLine();

    confirmUI:addText("text2", "", _, "Center");
    confirmUI:nextLine();

    confirmUI:addText("text3", "", _, "Center");
    confirmUI:nextLine();

    confirmUI:addEmpty();
    confirmUI:nextLine();

    confirmUI:addEmpty();
    confirmUI:addButton("b1", "Yes", confirmPress);
    confirmUI.b1:addArg("option", "yes");
    confirmUI:addEmpty();
    confirmUI:addButton("b2", "No", confirmPress);
    confirmUI:addEmpty();
    
    confirmUI:nextLine();
    confirmUI:addEmpty();

    confirmUI:saveLayout();
end

function MakeConfirmUIMP()
    confirmUIMP = NewUI();
    confirmUIMP.responseReceive = false;

    confirmUIMP:addText("text1", "Are you sure ?", "Title", "Center");
    confirmUIMP:setLineHeightPixel(getTextManager():getFontHeight(confirmUIMP.text1.font) + 10)
    confirmUIMP:nextLine();

    confirmUIMP:addText("text4", "", "Medium", "Center");
    confirmUIMP:setLineHeightPixel(getTextManager():getFontHeight(confirmUIMP.text4.font) + 10)
    confirmUIMP:nextLine();

    confirmUIMP:addText("text2", "", _, "Center");
    confirmUIMP:nextLine();

    confirmUIMP:addText("text3", "", _, "Center");
    confirmUIMP:nextLine();

    confirmUIMP:addEmpty();
    confirmUIMP:nextLine();

    confirmUIMP:addEmpty();
    confirmUIMP:addButton("b1", "Yes", confirmPressMP);
    confirmUIMP.b1:addArg("option", "yes");
    confirmUIMP:addEmpty();
    confirmUIMP:addButton("b2", "No", confirmPressMP);
    confirmUIMP:addEmpty();
    
    confirmUIMP:nextLine();
    confirmUIMP:addEmpty();

    confirmUIMP:saveLayout();
    confirmUIMP:addPrerenderFunction(prerenderFuncMP);
    confirmUIMP:close();
end


function OnCreateTheOnlyCureUI()

    -- how do we pass the correct player here?
    --print(self.character)

    makeMainUI();
	makeDescUI();
    makeConfirmUI();

    if isClient() then MakeConfirmUIMP() end
    mainUI:close()
end


local function onCreateUI()
    makeMainUI();
	makeDescUI();
    makeConfirmUI();
    if isClient() then MakeConfirmUIMP() end
    mainUI:close();
end

Events.OnCreateUI.Add(OnCreateTheOnlyCureUI)


-- Add button to health panel
function ISNewHealthPanel.onClick_TOC(button)


    -- button.character is patient
    -- button.otherPlayer is surgeon 


    -- if MP_other_player_toc_data ~= nil then
    --     print("It works")
    --     print(MP_other_player_toc_data)
    -- else
    --     print("Nopepppp")
    -- end

    if button.otherPlayer then
            
        if button.character ~= button.otherPlayer then
            sendClientCommand(button.otherPlayer, "TOC", "GetPlayerData",  {button.otherPlayer:getOnlineID(), button.character:getOnlineID()})
            SetCorrectArgsMainUI(MP_other_player_toc_data)      --other player is the surgeon
        else
            SetCorrectArgsMainUI(getPlayer():getModData().TOC)      --myself?

        end
    else
        SetCorrectArgsMainUI(getPlayer():getModData().TOC)      --myself?

    end


    mainUI:toggle()


    mainUI:setInCenterOfScreen()


    if button.otherPlayer then

        if button.character ~= button.otherPlayer then
            sendClientCommand(button.otherPlayer, "TOC", "GetPlayerData",  {button.otherPlayer:getOnlineID(), button.character:getOnlineID()})
            setImageMainUI(MP_other_player_toc_data)
    
        else
            setImageMainUI(getPlayer():getModData().TOC)
    
        end
    else
        setImageMainUI(getPlayer():getModData().TOC)

    end

end

local ISHealthPanel_createChildren = ISHealthPanel.createChildren

function ISHealthPanel:createChildren()
    ISHealthPanel_createChildren(self);

    self.fitness:setWidth(self.fitness:getWidth()/1.5);

    --TODO make it bigger
    self.TOCButton = ISButton:new(self.fitness:getRight(), self.healthPanel.y, 20, 20, "", self, ISNewHealthPanel.onClick_TOC)
    self.TOCButton:setImage(getTexture("media/ui/TOC/iconForMenu.png"))
    self.TOCButton.anchorTop = false
    self.TOCButton.anchorBottom = true
    self.TOCButton:initialise();
    self.TOCButton:instantiate();
    self:addChild(self.TOCButton);
    if getCore():getGameMode() == "Tutorial" then
        self.TOCButton:setVisible(false);
    end
end

local ISHealthPanel_render = ISHealthPanel.render

function ISHealthPanel:render()
    ISHealthPanel_render(self);
    self.TOCButton:setY(self.fitness:getY());
end


function SendOtherPlayerData()

    local mod_data = getPlayer():getModData().TOC
    

end

function GetOtherPlayerData()
    local surgeonFact, useBandage, bandageAlcool, usePainkiller, painkillerCount = self:findArgs();

    if self.patient ~= self.surgeon and isClient() then
        SendCutArm(self.patient, self.partName, surgeonFact, useBandage, bandageAlcool, usePainkiller, painkillerCount);
    end
end