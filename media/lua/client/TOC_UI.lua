-- RE DO ALL OVER THIS CRAP


local main_ui, desc_ui, confirm_ui, confirm_ui_mp


-------------------------
-- MP stuff?

local function PrerenderFuncMP()
    local toSee = confirm_ui_mp
    if confirm_ui_mp.responseReceive then
        if not confirm_ui_mp.responseCan then
            getPlayer():Say("I can't do that !")
            confirm_ui_mp.responseReceive = false
            confirm_ui_mp:close()
            return false;
        end

        -- Prerender basically hooks onto SendCommandToConfirmUI, dunno how but it does
        SendCommandToConfirmUIMP(confirm_ui_mp.responseAction, confirm_ui_mp.responseIsBitten,
            confirm_ui_mp.responseUserName, confirm_ui_mp.responsePartName);
    end
end

-----------------------
-- Getters
function GetConfirmUIMP()
    return confirm_ui_mp;
end

------------------------------
-- UI Visible stuff functions
local function GetImageName(part_name, limbs_data)
    local name = ""

    local part_data = limbs_data[part_name]

    if part_data.is_cut and part_data.is_cicatrized and part_data.is_prosthesis_equipped then -- Cut and equip
        if part_name == "Right_Hand" or part_name == "Left_Hand" then
            name = "media/ui/TOC/" .. part_name .. "/Hook.png"
        else
            name = "media/ui/TOC/" .. part_name .. "/Prothesis.png"
        end
    elseif part_data.is_cut and part_data.is_cicatrized and not part_data.is_prosthesis_equipped and
        part_data.is_amputation_shown then -- Cut and heal
        name = "media/ui/TOC/" .. part_name .. "/Cut.png"
    elseif part_data.is_cut and not part_data.is_cicatrized and part_data.is_amputation_shown and
        not part_data.is_operated then -- Cut not heal
        name = "media/ui/TOC/" .. part_name .. "/Bleed.png"
    elseif part_data.is_cut and not part_data.is_cicatrized and part_data.is_amputation_shown and part_data.is_operated then -- Cut not heal
        name = "media/ui/TOC/" .. part_name .. "/Operate.png"
    elseif part_data.is_cut and not part_data.is_amputation_shown then -- Empty (like hand if forearm cut)
        name = "media/ui/TOC/Empty.png"
    elseif not part_data.is_cut and
        -- TODO This doesn't work in MP on another player since we're trying to retrieve bodyDamage from another player
        getPlayer():getBodyDamage():getBodyPart(TocGetBodyPartFromPartName(part_name)):bitten() then -- Not cut but bitten
        name = "media/ui/TOC/" .. part_name .. "/Bite.png"
    else -- Not cut
        name = "media/ui/TOC/" .. part_name .. "/Base.png"
    end

    -- If foreaerm equip, change hand
    if part_name == "Right_Hand" and limbs_data["Right_LowerArm"].is_prosthesis_equipped then
        name = "media/ui/TOC/" .. part_name .. "/Hook.png"
    elseif part_name == "Left_Hand" and limbs_data["Left_LowerArm"].is_prosthesis_equipped then
        name = "media/ui/TOC/" .. part_name .. "/Hook.png"
    end
    return name
end

------------------------------------------
-- Check functions

local function IsProsthesisInstalled(part_data)
    return part_data.is_cut and part_data.is_cicatrized and part_data.is_prosthesis_equipped
end

local function CanProsthesisBeEquipped(part_data)

    return part_data.is_cut and part_data.is_cicatrized and not part_data.is_prosthesis_equipped and
        part_data.is_amputation_shown

end

local function IsAmputatedLimbHealed(part_data)
    return part_data.is_cut and not part_data.is_cicatrized and part_data.is_amputation_shown

end

local function IsAmputatedLimbToBeVisible(part_data)
    return part_data.is_cut and not part_data.is_amputation_shown
end

local function IsPartBitten(part_data, part_name)
    return not part_data.is_cut and
        getPlayer():getBodyDamage():getBodyPart(TocGetBodyPartFromPartName(part_name)):bitten()
end

local function FindMinMax(lv)
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


-----------------------------------------
-- Setup stuff with variables and shit

local function SetupTocMainUI(surgeon, patient, limbs_data)
    main_ui.surgeon = surgeon -- we shouldn't need an arg for this
    main_ui.patient = patient

    if limbs_data then
        
        main_ui.limbs_data = limbs_data

        main_ui["b11"]:setPath(GetImageName("Right_UpperArm", limbs_data))
        main_ui["b12"]:setPath(GetImageName("Left_UpperArm", limbs_data))

        main_ui["b21"]:setPath(GetImageName("Right_LowerArm", limbs_data))
        main_ui["b22"]:setPath(GetImageName("Left_LowerArm", limbs_data))

        main_ui["b31"]:setPath(GetImageName("Right_Hand", limbs_data))
        main_ui["b32"]:setPath(GetImageName("Left_Hand", limbs_data))

    end


end

local function SetupTocDescUI(surgeon, patient, limbs_data, part_name)
    desc_ui["textTitle"]:setText(getText("UI_ContextMenu_" .. part_name))
    desc_ui.part_name = part_name
    desc_ui.surgeon = surgeon
    desc_ui.patient = patient

    local part_data = limbs_data[part_name]

    if IsProsthesisInstalled(part_data) then
        -- Limb cut with prosthesis
        desc_ui["status"]:setText("Prosthesis equipped")
        desc_ui["status"]:setColor(1, 0, 1, 0)
        desc_ui["b1"]:setText("Unequip")
        desc_ui["b1"]:addArg("option", "Unequip")
        desc_ui["b1"]:setVisible(true)
    elseif CanProsthesisBeEquipped(part_data) then
        -- Limb cut but no prosthesis
        desc_ui["status"]:setText("Amputated and healed")
        desc_ui["status"]:setColor(1, 0, 1, 0)

        -- Another check for UpperArm
        if part_name == "Right_UpperArm" or part_name == "Left_UpperArm" then
            desc_ui["b1"]:setVisible(false)
        else
            desc_ui["b1"]:setText("Equip")
            desc_ui["b1"]:addArg("option", "Equip")
            desc_ui["b1"]:setVisible(true)
        end
        -- Limb cut but still healing
    elseif IsAmputatedLimbHealed(part_data) then
        -- Limb cut and healed, no prosthesis equipped
        if part_data.is_operated then

            desc_ui["b1"]:setVisible(false) -- no operate prompt

            if part_data.cicatrization_time > 1000 then
                desc_ui["status"]:setText("Still a long way to go")
                desc_ui["status"]:setColor(1, 0.8, 1, 0.2);
            elseif part_data.cicatrization_time > 500 then
                desc_ui["status"]:setText("Starting to get better")
                desc_ui["status"]:setColor(1, 0.8, 1, 0.2)

            elseif part_data.cicatrization_time > 100 then
                desc_ui["status"]:setText("Almost cicatrized")
                desc_ui["status"]:setColor(1, 0.8, 1, 0.2)
            end
        else
            -- Set the operate button
            desc_ui["b1"]:setText("Operate")
            desc_ui["b1"]:addArg("option", "Operate")
            desc_ui["b1"]:setVisible(true)

            if part_data.cicatrization_time > 1000 then
                desc_ui["status"]:setText("It hurts so much...")
                desc_ui["status"]:setColor(1, 1, 0, 0)
            elseif part_data.cicatrization_time > 500 then
                desc_ui["status"]:setText("It still hurts a lot")
                desc_ui["status"]:setColor(1, 0.8, 1, 0.2)
            elseif part_data.cicatrization_time > 500 then
                desc_ui["status"]:setText("I think it's almost over...")
                desc_ui["status"]:setColor(1, 0.8, 1, 0.2)
            end
        end


    elseif IsAmputatedLimbToBeVisible(part_data) then
        -- Limb cut and not visible (ex: hand after having amputated forearm)
        desc_ui["status"]:setText("Nothing here")
        desc_ui["status"]:setColor(1, 1, 1, 1)
        desc_ui["b1"]:setVisible(false)
    elseif CheckIfCanBeCut(part_name, limbs_data) then
        -- Everything else
        -- TODO add check for cuts and scratches
        desc_ui["status"]:setText("Not cut")
        desc_ui["status"]:setColor(1, 1, 1, 1)
        if TocGetSawInInventory(surgeon) and not CheckIfProsthesisAlreadyInstalled(limbs_data, part_name) then
            desc_ui["b1"]:setVisible(true)
            desc_ui["b1"]:setText("Cut")
            desc_ui["b1"]:addArg("option", "Cut")
        elseif TocGetSawInInventory(surgeon) and CheckIfProsthesisAlreadyInstalled(limbs_data, part_name) then
            desc_ui["b1"]:setVisible(true)
            desc_ui["b1"]:setText("Remove prosthesis before")
            desc_ui["b1"]:addArg("option", "Nothing")

        else
            desc_ui["b1"]:setVisible(false)
        end

    else
        desc_ui["status"]:setText("Not cut")
        desc_ui["status"]:setColor(1, 1, 1, 1)
        desc_ui["b1"]:setVisible(true)
        desc_ui["b1"]:setText("Remove prosthesis before")
        desc_ui["b1"]:addArg("option", "Nothing")

    end

    -- Prosthesis Level
    if string.find(part_name, "Right") then
        local lv = patient:getPerkLevel(Perks.Right_Hand) + 1
        desc_ui["textLV2"]:setText("Level:   " .. lv .. " / 10")

        local xp = patient:getXp():getXP(Perks.Right_Hand)
        local min, max = FindMinMax(lv)
        desc_ui["pbarNLV"]:setMinMax(min, max)
        desc_ui["pbarNLV"]:setValue(xp)
    else
        local lv = patient:getPerkLevel(Perks.Left_Hand) + 1
        desc_ui["textLV2"]:setText("Level:   " .. lv .. " / 10")

        local xp = patient:getXp():getXP(Perks.Left_Hand)
        local min, max = FindMinMax(lv)
        desc_ui["pbarNLV"]:setMinMax(min, max)
        desc_ui["pbarNLV"]:setValue(xp)
    end

end


------------------------------------------------
-- On Click Functions
local function OnClickTocMainUI(button, args)

    desc_ui:open()
    desc_ui:setPositionPixel(main_ui:getRight(), main_ui:getY())
    SetupTocDescUI(main_ui.surgeon, main_ui.patient, main_ui.limbs_data, args.part_name) -- surgeon is generic.

end

local function OnClickTocDescUI(button, args)
    
    -- Gets every arg from main
    local patient = desc_ui.patient
    local surgeon = desc_ui.surgeon

    if args.option ~= "Nothing" then
        TryTocAction(_, desc_ui.part_name, args.option, surgeon, patient)
    end
    main_ui:close()

end

local function OnClickTocConfirmUIMP(button, args)
    local player = getPlayer()
    if confirm_ui_mp.actionAct == "Cut" and args.option == "yes" then
        ISTimedActionQueue.add(ISCutLimb:new(confirm_ui_mp.patient, player, confirm_ui_mp.partNameAct))
    elseif confirm_ui_mp.actionAct == "Operate" and args.option == "yes" then
        local playerInv = player:getInventory()
        local item = playerInv:getItemFromType('TOC.Real_surgeon_kit') or playerInv:getItemFromType('TOC.Surgeon_kit') or
            playerInv:getItemFromType('TOC.Improvised_surgeon_kit')
        if item then
            ISTimedActionQueue.add(ISOperateLimb:new(confirm_ui_mp.patient, player, item, confirm_ui_mp.partNameAct,
                false))
        else
            player:Say("I need a kit")
        end

    elseif confirm_ui_mp.actionAct == "Equip" and args.option == "yes" then
        local surgeon_inventory = player:getInventory()

        local prosthesis_to_equip = surgeon_inventory:getItemFromType('TOC.MetalHand') or
            surgeon_inventory:getItemFromType('TOC.MetalHook') or
            surgeon_inventory:getItemFromType('TOC.WoodenHook')

        if prosthesis_to_equip then
            ISTimedActionQueue.add(ISInstallProsthesis:new(player, confirm_ui_mp.patient, prosthesis_to_equip,
                confirm_ui_mp.partNameAct))
        else
            player:Say("I don't have a prosthesis right now")
        end

    elseif confirm_ui_mp.actionAct == "Unequip" and args.option == "yes" then

        -- We can't check if the player has a prosthesis right now, we need to do it later

        -- TODO should check if player has a prosthesis equipped before doing it

        -- TODO Player is surgeon, but we don't have a confirm_ui_mp.surgeon... awful awful awful

        -- TODO Workaround for now, we'd need to send data from patient before doing it since we can't access his inventory from the surgeon
        if confirm_ui_mp.patient == player then
            ISTimedActionQueue.add(ISUninstallProsthesis:new(player, confirm_ui_mp.patient, confirm_ui_mp.partNameAct))

        else
            player:Say("I can't do that, they need to do it themselves")

        end



    end


    confirm_ui_mp:close()
    confirm_ui_mp.responseReceive = false

end

-----------------------------------------------

-- CREATE UI SECTION
local function CreateTocMainUI()
    main_ui = NewUI()
    main_ui:setTitle("The Only Cure Menu")
    main_ui:setWidthPercent(0.1)

    main_ui:addImageButton("b11", "", OnClickTocMainUI)
    main_ui["b11"]:addArg("part_name", "Right_UpperArm")


    main_ui:addImageButton("b12", "", OnClickTocMainUI)
    main_ui["b12"]:addArg("part_name", "Left_UpperArm")

    main_ui:nextLine()

    main_ui:addImageButton("b21", "", OnClickTocMainUI)
    main_ui["b21"]:addArg("part_name", "Right_LowerArm")


    main_ui:addImageButton("b22", "", OnClickTocMainUI)
    main_ui["b22"]:addArg("part_name", "Left_LowerArm")

    main_ui:nextLine()

    main_ui:addImageButton("b31", "", OnClickTocMainUI)
    main_ui["b31"]:addArg("part_name", "Right_Hand")

    main_ui:addImageButton("b32", "", OnClickTocMainUI)
    main_ui["b32"]:addArg("part_name", "Left_Hand")

    main_ui:saveLayout()


end

local function CreateTocDescUI()
    -- TODO most of this stuff is just temporary. We can probably wipe this off the face of the earth
    desc_ui = NewUI()
    desc_ui:setTitle("The only cure description");
    desc_ui:isSubUIOf(main_ui)
    desc_ui:setWidthPixel(250)
    desc_ui:setColumnWidthPixel(1, 100)

    desc_ui:addText("textTitle", "Right arm", "Large", "Center")
    desc_ui:nextLine()

    desc_ui:addText("textLV2", "Level 3/10", _, "Center")
    desc_ui:nextLine()

    desc_ui:addText("textLV", "Next LV:", _, "Right")
    desc_ui:addProgressBar("pbarNLV", 39, 0, 100)
    desc_ui["pbarNLV"]:setMarginPixel(10, 6)
    desc_ui:nextLine()

    desc_ui:addEmpty("border1")
    desc_ui:setLineHeightPixel(1)
    desc_ui["border1"]:setBorder(true)
    desc_ui:nextLine()

    desc_ui:addEmpty()
    desc_ui:nextLine()

    desc_ui:addText("status", "Temporary", "Medium", "Center")
    desc_ui["status"]:setColor(1, 1, 0, 0)
    desc_ui:nextLine()

    desc_ui:addEmpty()
    desc_ui:nextLine()

    desc_ui:addButton("b1", "Operate", OnClickTocDescUI) -- TODO this is just temporary

    desc_ui:saveLayout()
end

function CreateTocConfirmUIMP()
    confirm_ui_mp = NewUI()
    confirm_ui_mp.responseReceive = false

    confirm_ui_mp:addText("text1", "Are you sure?", "Title", "Center");
    confirm_ui_mp:setLineHeightPixel(getTextManager():getFontHeight(confirm_ui_mp.text1.font) + 10)
    confirm_ui_mp:nextLine();

    confirm_ui_mp:addText("text4", "", "Medium", "Center");
    confirm_ui_mp:setLineHeightPixel(getTextManager():getFontHeight(confirm_ui_mp.text4.font) + 10)
    confirm_ui_mp:nextLine();

    confirm_ui_mp:addText("text2", "", _, "Center");
    confirm_ui_mp:nextLine();

    confirm_ui_mp:addText("text3", "", _, "Center");
    confirm_ui_mp:nextLine();

    confirm_ui_mp:addEmpty();
    confirm_ui_mp:nextLine();

    confirm_ui_mp:addEmpty();
    confirm_ui_mp:addButton("b1", "Yes", OnClickTocConfirmUIMP);
    confirm_ui_mp.b1:addArg("option", "yes");
    confirm_ui_mp:addEmpty();
    confirm_ui_mp:addButton("b2", "No", OnClickTocConfirmUIMP);
    confirm_ui_mp:addEmpty();

    confirm_ui_mp:nextLine();
    confirm_ui_mp:addEmpty();

    confirm_ui_mp:saveLayout();
    confirm_ui_mp:addPrerenderFunction(PrerenderFuncMP);
    confirm_ui_mp:close();

end

-- We create everything from here
function OnCreateTheOnlyCureUI()
    CreateTocMainUI()
    CreateTocDescUI()
    CreateTocConfirmUIMP()

    if isClient() then CreateTocConfirmUIMP() end
    main_ui:close()
end


--------------------------------------------
-- MP Confirm (I should add it to client too but hey not sure how it works tbh)

function SendCommandToConfirmUIMP(action, isBitten, userName, partName)
    confirm_ui_mp:setInCenterOfScreen()
    confirm_ui_mp:bringToTop()
    confirm_ui_mp:open()


    if action ~= "Wait server" then
        confirm_ui_mp["text4"]:setText("You're gonna " ..
            action .. " the " .. getText("UI_ContextMenu_" .. partName) .. " of " .. userName)

        confirm_ui_mp["text2"]:setText("Are you sure?")
        confirm_ui_mp["text2"]:setColor(1, 0, 0, 0)
        confirm_ui_mp["b1"]:setVisible(true)
        confirm_ui_mp["b2"]:setVisible(true)
    else

        confirm_ui_mp["text4"]:setText(action)
        confirm_ui_mp["text3"]:setText("")
        confirm_ui_mp["text2"]:setText("")
        confirm_ui_mp["b1"]:setVisible(false)
        confirm_ui_mp["b2"]:setVisible(false)
    end

end

--------------------------------------------
-- Add TOC element to Health Panel
local ISHealthPanel_createChildren = ISHealthPanel.createChildren
local ISHealthPanel_render = ISHealthPanel.render
-- Add button to health panel



function ISNewHealthPanel.onClick_TOC(button)

    local surgeon = button.otherPlayer
    local patient = button.character

    TocTempTable.patient = patient
    TocTempTable.surgeon = surgeon

    -- MP Handling
    if surgeon then


        if surgeon == patient then
            Events.OnTick.Add(TocRefreshPlayerMenu)

        else
            Events.OnTick.Add(TocRefreshOtherPlayerMenu)            -- MP stuff, try to get the other player data and display it on the surgeon display
        end
    else
        -- SP Handling
        Events.OnTick.Add(TocRefreshPlayerMenu)
    end

    main_ui:toggle()
    main_ui:setInCenterOfScreen()

end




TocTempTable = {patient = nil, surgeon = nil}

function TocRefreshPlayerMenu(_)
    if main_ui:getIsVisible() == false then
        Events.OnTick.Remove(TocRefreshPlayerMenu)
        TocTempTable.patient = nil
        TocTempTable.surgeon = nil

    else

        local limbs_data = TocTempTable.patient:getModData().TOC.Limbs
        SetupTocMainUI(TocTempTable.patient, TocTempTable.patient, limbs_data)
    end

end


function TocRefreshOtherPlayerMenu(_)

    if main_ui:getIsVisible() == false then

        Events.OnTick.Remove(TocRefreshOtherPlayerMenu)
        TocTempTable.patient = nil
        TocTempTable.surgeon = nil

        else
        if ModData.get("TOC_PLAYER_DATA")[TocTempTable.patient:getUsername()] ~= nil then
            local other_player_part_data = ModData.get("TOC_PLAYER_DATA")[TocTempTable.patient:getUsername()]

            SetupTocMainUI(TocTempTable.surgeon, TocTempTable.patient, other_player_part_data[1])


        end
    end
end




function ISHealthPanel:createChildren()
    ISHealthPanel_createChildren(self)

    self.fitness:setWidth(self.fitness:getWidth() / 1.4)

    self.TOCButton = ISButton:new(self.fitness:getRight() + 10, self.healthPanel.y, 60, 20, "", self,
        ISNewHealthPanel.onClick_TOC)
    self.TOCButton:setImage(getTexture("media/ui/TOC/iconForMenu.png"))
    self.TOCButton.anchorTop = false
    self.TOCButton.anchorBottom = true
    self.TOCButton:initialise()
    self.TOCButton:instantiate()
    self:addChild(self.TOCButton)
    if getCore():getGameMode() == "Tutorial" then
        self.TOCButton:setVisible(false)
    end
end

function ISHealthPanel:render()
    ISHealthPanel_render(self);
    self.TOCButton:setY(self.fitness:getY());
end

-- EVENTS
Events.OnCreateUI.Add(OnCreateTheOnlyCureUI)
