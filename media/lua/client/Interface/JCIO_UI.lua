

if JCIO_UI == nil then
    JCIO_UI = {}
end




local mainUI, descUI, confirmUI, confirmUIMP


-------------------------
-- MP stuff

local function PrerenderFuncMP()
    local toSee = confirmUIMP
    if confirmUIMP.responseReceive then
        if not confirmUIMP.responseCan then
            getPlayer():Say("I can't do that !")
            confirmUIMP.responseReceive = false
            confirmUIMP:close()
            return false;
        end

        -- Prerender basically hooks onto SendCommandToConfirmUI, dunno how but it does
        SendCommandToConfirmUIMP(confirmUIMP.responseAction, confirmUIMP.responseIsBitten,
            confirmUIMP.responseUserName, confirmUIMP.responsePartName);
    end
end

-----------------------
-- Getters
function GetConfirmUIMP()
    return confirmUIMP;
end

------------------------------
-- UI Visible stuff functions
local function GetImageName(partName, limbsData)
    local name = ""

    local part_data = limbsData[partName]

    if part_data.isCut and part_data.isCicatrized and part_data.isProsthesisEquipped then -- Cut and equip
        if partName == "Right_Hand" or partName == "Left_Hand" then
            name = "media/ui/TOC/" .. partName .. "/Hook.png"
        else
            name = "media/ui/TOC/" .. partName .. "/Prothesis.png"
        end
    elseif part_data.isCut and part_data.isCicatrized and not part_data.isProsthesisEquipped and
        part_data.isAmputationShown then -- Cut and heal
        name = "media/ui/TOC/" .. partName .. "/Cut.png"
    elseif part_data.isCut and not part_data.isCicatrized and part_data.isAmputationShown and
        not part_data.isOperated then -- Cut not heal
        name = "media/ui/TOC/" .. partName .. "/Bleed.png"
    elseif part_data.isCut and not part_data.isCicatrized and part_data.isAmputationShown and part_data.isOperated then -- Cut not heal
        name = "media/ui/TOC/" .. partName .. "/Operate.png"
    elseif part_data.isCut and not part_data.isAmputationShown then -- Empty (like hand if forearm cut)
        name = "media/ui/TOC/Empty.png"
    elseif not part_data.isCut and
        -- FIXME This doesn't work in MP on another player since we're trying to retrieve bodyDamage from another player
        getPlayer():getBodyDamage():getBodyPart(JCIO_Common.GetBodyPartFromPartName(partName)):bitten() then -- Not cut but bitten
        name = "media/ui/TOC/" .. partName .. "/Bite.png"
    else -- Not cut
        name = "media/ui/TOC/" .. partName .. "/Base.png"
    end

    -- If foreaerm equip, change hand
    if partName == "Right_Hand" and limbsData["Right_LowerArm"].isProsthesisEquipped then
        name = "media/ui/TOC/" .. partName .. "/Hook.png"
    elseif partName == "Left_Hand" and limbsData["Left_LowerArm"].isProsthesisEquipped then
        name = "media/ui/TOC/" .. partName .. "/Hook.png"
    end
    return name
end

------------------------------------------
-- Check functions

local function IsProsthesisInstalled(partData)
    return partData.isCut and partData.isCicatrized and partData.isProsthesisEquipped
end

local function CanProsthesisBeEquipped(partData)

    return partData.isCut and partData.isCicatrized and not partData.isProsthesisEquipped and
        partData.isAmputationShown

end

local function IsAmputatedLimbHealed(partData)
    return partData.isCut and not partData.isCicatrized and partData.isAmputationShown

end

local function IsAmputatedLimbToBeVisible(partData)
    return partData.isCut and not partData.isAmputationShown
end

local function IsPartBitten(partData, partName)
    return not partData.isCut and
        getPlayer():getBodyDamage():getBodyPart(JCIO_Common.GetBodyPartFromPartName(partName)):bitten()
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

JCIO_UI.SetupMainUI = function(surgeon, patient, limbsData)
    mainUI.surgeon = surgeon -- we shouldn't need an arg for this
    mainUI.patient = patient

    if limbsData then
        
        mainUI.limbs_data = limbsData

        mainUI["b11"]:setPath(GetImageName("Right_UpperArm", limbsData))
        mainUI["b12"]:setPath(GetImageName("Left_UpperArm", limbsData))

        mainUI["b21"]:setPath(GetImageName("Right_LowerArm", limbsData))
        mainUI["b22"]:setPath(GetImageName("Left_LowerArm", limbsData))

        mainUI["b31"]:setPath(GetImageName("Right_Hand", limbsData))
        mainUI["b32"]:setPath(GetImageName("Left_Hand", limbsData))

        mainUI["b41"]:setPath(GetImageName("Right_Foot", limbsData))
        mainUI["b42"]:setPath(GetImageName("Left_Foot", limbsData))

    end


end

JCIO_UI.SetupDescUI = function(surgeon, patient, limbsData, partName)
    descUI["textTitle"]:setText(getText("UI_ContextMenu_" .. partName))
    descUI.part_name = partName
    descUI.surgeon = surgeon
    descUI.patient = patient

    local partData = limbsData[partName]

    if IsProsthesisInstalled(partData) then
        -- Limb cut with prosthesis
        descUI["status"]:setText("Prosthesis equipped")
        descUI["status"]:setColor(1, 0, 1, 0)
        descUI["b1"]:setText("Unequip")
        descUI["b1"]:addArg("option", "Unequip")
        descUI["b1"]:setVisible(true)
    elseif CanProsthesisBeEquipped(partData) then
        -- Limb cut but no prosthesis
        descUI["status"]:setText("Amputated and healed")
        descUI["status"]:setColor(1, 0, 1, 0)

        -- Another check for UpperArm
        if partName == "Right_UpperArm" or partName == "Left_UpperArm" then
            descUI["b1"]:setVisible(false)
        else
            descUI["b1"]:setText("Equip")
            descUI["b1"]:addArg("option", "Equip")
            descUI["b1"]:setVisible(true)
        end
        -- Limb cut but still healing
    elseif IsAmputatedLimbHealed(partData) then
        -- Limb cut and healed, no prosthesis equipped
        if partData.isOperated then

            descUI["b1"]:setVisible(false) -- no operate prompt

            if partData.cicatrizationTime > 1000 then
                descUI["status"]:setText("Still a long way to go")
                descUI["status"]:setColor(1, 0.8, 1, 0.2);
            elseif partData.cicatrizationTime > 500 then
                descUI["status"]:setText("Starting to get better")
                descUI["status"]:setColor(1, 0.8, 1, 0.2)

            elseif partData.cicatrizationTime > 100 then
                descUI["status"]:setText("Almost cicatrized")
                descUI["status"]:setColor(1, 0.8, 1, 0.2)
            end
        else
            -- Set the operate button
            descUI["b1"]:setText("Operate")
            descUI["b1"]:addArg("option", "Operate")
            descUI["b1"]:setVisible(true)

            if partData.cicatrizationTime > 1000 then
                descUI["status"]:setText("It hurts so much...")
                descUI["status"]:setColor(1, 1, 0, 0)
            elseif partData.cicatrizationTime > 500 then
                descUI["status"]:setText("It still hurts a lot")
                descUI["status"]:setColor(1, 0.8, 1, 0.2)
            elseif partData.cicatrizationTime > 500 then
                descUI["status"]:setText("I think it's almost over...")
                descUI["status"]:setColor(1, 0.8, 1, 0.2)
            end
        end


    elseif IsAmputatedLimbToBeVisible(partData) then
        -- Limb cut and not visible (ex: hand after having amputated forearm)
        descUI["status"]:setText("Nothing here")
        descUI["status"]:setColor(1, 1, 1, 1)
        descUI["b1"]:setVisible(false)
    elseif CheckIfCanBeCut(partName, limbsData) then
        -- Everything else
        -- TODO add check for cuts and scratches
        descUI["status"]:setText("Not cut")
        descUI["status"]:setColor(1, 1, 1, 1)
        if JCIO_Common.GetSawInInventory(surgeon) and not CheckIfProsthesisAlreadyInstalled(limbsData, partName) then
            descUI["b1"]:setVisible(true)
            descUI["b1"]:setText("Cut")
            descUI["b1"]:addArg("option", "Cut")
        elseif JCIO_Common.GetSawInInventory(surgeon) and CheckIfProsthesisAlreadyInstalled(limbsData, partName) then
            descUI["b1"]:setVisible(true)
            descUI["b1"]:setText("Remove prosthesis before")
            descUI["b1"]:addArg("option", "Nothing")

        else
            descUI["b1"]:setVisible(false)
        end

    else
        descUI["status"]:setText("Not cut")
        descUI["status"]:setColor(1, 1, 1, 1)
        descUI["b1"]:setVisible(true)
        descUI["b1"]:setText("Remove prosthesis before")
        descUI["b1"]:addArg("option", "Nothing")

    end

    -- Prosthesis Level
    if string.find(partName, "Right") then
        local lv = patient:getPerkLevel(Perks.Right_Hand) + 1
        descUI["textLV2"]:setText("Level:   " .. lv .. " / 10")

        local xp = patient:getXp():getXP(Perks.Right_Hand)
        local min, max = FindMinMax(lv)
        descUI["pbarNLV"]:setMinMax(min, max)
        descUI["pbarNLV"]:setValue(xp)
    else
        local lv = patient:getPerkLevel(Perks.Left_Hand) + 1
        descUI["textLV2"]:setText("Level:   " .. lv .. " / 10")

        local xp = patient:getXp():getXP(Perks.Left_Hand)
        local min, max = FindMinMax(lv)
        descUI["pbarNLV"]:setMinMax(min, max)
        descUI["pbarNLV"]:setValue(xp)
    end

end


------------------------------------------------
-- On Click Functions
local function OnClickTocMainUI(button, args)

    descUI:open()
    descUI:setPositionPixel(mainUI:getRight(), mainUI:getY())
    JCIO_UI.SetupDescUI(mainUI.surgeon, mainUI.patient, mainUI.limbs_data, args.part_name) -- surgeon is generic.

end

-- Generic TOC action, used in OnClickTocDescUI
local function TryTocAction(_, part_name, action, surgeon, patient)
    -- TODO at this point surgeon doesnt do anything. We'll fix this later

    -- Check if SinglePlayer
    if not isServer() and not isClient() then

        if action == "Cut" then
            TocCutLocal(_, surgeon, part_name)
        elseif action == "Operate" then
            TocOperateLocal(_, surgeon, part_name, false)
        elseif action == "Equip" then
            TocEquipProsthesisLocal(_, surgeon, part_name)
        elseif action == "Unequip" then
            TocUnequipProsthesisLocal(_, surgeon, part_name)
        end
    else
        local ui = GetConfirmUIMP()
        if not ui then
            CreateTocConfirmUIMP()
            ui = GetConfirmUIMP()
        end

        if patient == nil then
            patient = surgeon
        end


        if action == "Cut" then
            AskCanCutLimb(patient, part_name)
        elseif action == "Operate" then
            AskCanOperateLimb(patient, part_name)
        elseif action == "Equip" then
            AskCanEquipProsthesis(patient, part_name)
        elseif action == "Unequip" then
            AskCanUnequipProsthesis(patient, part_name)
        end

        ui.actionAct = action
        ui.partNameAct = part_name
        ui.patient = patient

        SendCommandToConfirmUIMP("Wait server")

    end
end


local function OnClickTocDescUI(button, args)
    
    -- Gets every arg from main
    local patient = descUI.patient
    local surgeon = descUI.surgeon

    if args.option ~= "Nothing" then
        TryTocAction(_, descUI.part_name, args.option, surgeon, patient)
    end
    mainUI:close()

end

local function OnClickTocConfirmUIMP(button, args)
    local player = getPlayer()
    if confirmUIMP.actionAct == "Cut" and args.option == "yes" then
        ISTimedActionQueue.add(JCIO_CutLimbAction:new(confirmUIMP.patient, player, confirmUIMP.partNameAct))
    elseif confirmUIMP.actionAct == "Operate" and args.option == "yes" then
        local playerInv = player:getInventory()
        local item = playerInv:getItemFromType('TOC.Real_surgeon_kit') or playerInv:getItemFromType('TOC.Surgeon_kit') or
            playerInv:getItemFromType('TOC.Improvised_surgeon_kit')
        if item then
            ISTimedActionQueue.add(JCIO_OperateLimbAction:new(confirmUIMP.patient, player, item, confirmUIMP.partNameAct,
                false))
        else
            player:Say("I need a kit")
        end

    elseif confirmUIMP.actionAct == "Equip" and args.option == "yes" then
        local surgeon_inventory = player:getInventory()

        local prosthesis_to_equip = surgeon_inventory:getItemFromType('TOC.MetalHand') or
            surgeon_inventory:getItemFromType('TOC.MetalHook') or
            surgeon_inventory:getItemFromType('TOC.WoodenHook')

        if prosthesis_to_equip then
            ISTimedActionQueue.add(JCIO_InstallProsthesisAction:new(player, confirmUIMP.patient, prosthesis_to_equip,
                confirmUIMP.partNameAct))
        else
            player:Say("I don't have a prosthesis right now")
        end

    elseif confirmUIMP.actionAct == "Unequip" and args.option == "yes" then

        -- We can't check if the player has a prosthesis right now, we need to do it later

        -- TODO should check if player has a prosthesis equipped before doing it
        -- TODO Player is surgeon, but we don't have a confirm_ui_mp.surgeon... awful awful awful
        -- TODO Workaround for now, we'd need to send data from patient before doing it since we can't access his inventory from the surgeon
        if confirmUIMP.patient == player then
            ISTimedActionQueue.add(JCIO_UninstallProsthesisAction:new(player, confirmUIMP.patient, confirmUIMP.partNameAct))

        else
            player:Say("I can't do that, they need to do it themselves")

        end



    end


    confirmUIMP:close()
    confirmUIMP.responseReceive = false

end

-----------------------------------------------

-- CREATE UI SECTION
local function CreateTocMainUI()
    mainUI = NewUI()
    mainUI:setTitle("The Only Cure Menu")
    mainUI:setWidthPercent(0.1)

    mainUI:addImageButton("b11", "", OnClickTocMainUI)
    mainUI["b11"]:addArg("part_name", "Right_UpperArm")


    mainUI:addImageButton("b12", "", OnClickTocMainUI)
    mainUI["b12"]:addArg("part_name", "Left_UpperArm")

    mainUI:nextLine()

    mainUI:addImageButton("b21", "", OnClickTocMainUI)
    mainUI["b21"]:addArg("part_name", "Right_LowerArm")


    mainUI:addImageButton("b22", "", OnClickTocMainUI)
    mainUI["b22"]:addArg("part_name", "Left_LowerArm")

    mainUI:nextLine()

    mainUI:addImageButton("b31", "", OnClickTocMainUI)
    mainUI["b31"]:addArg("part_name", "Right_Hand")

    mainUI:addImageButton("b32", "", OnClickTocMainUI)
    mainUI["b32"]:addArg("part_name", "Left_Hand")


    mainUI:nextLine()

    mainUI:addImageButton("b41", "", OnClickTocMainUI)
    mainUI["b41"]:addArg("part_name", "Right_Foot")

    mainUI:addImageButton("b42", "", OnClickTocMainUI)
    mainUI["b42"]:addArg("part_name", "Left_Foot")

    mainUI:saveLayout()


end

-- Create a temporary desc UI with fake data (for now)
local function CreateTocDescUI()
    descUI = NewUI()
    descUI:setTitle("The only cure description");
    descUI:isSubUIOf(mainUI)
    descUI:setWidthPixel(250)
    descUI:setColumnWidthPixel(1, 100)

    descUI:addText("textTitle", "Right arm", "Large", "Center")
    descUI:nextLine()

    descUI:addText("textLV2", "Level 3/10", _, "Center")
    descUI:nextLine()

    descUI:addText("textLV", "Next LV:", _, "Right")
    descUI:addProgressBar("pbarNLV", 39, 0, 100)
    descUI["pbarNLV"]:setMarginPixel(10, 6)
    descUI:nextLine()

    descUI:addEmpty("border1")
    descUI:setLineHeightPixel(1)
    descUI["border1"]:setBorder(true)
    descUI:nextLine()

    descUI:addEmpty()
    descUI:nextLine()

    descUI:addText("status", "Temporary", "Medium", "Center")
    descUI["status"]:setColor(1, 1, 0, 0)
    descUI:nextLine()

    descUI:addEmpty()
    descUI:nextLine()

    descUI:addButton("b1", "Operate", OnClickTocDescUI)

    descUI:saveLayout()
end

function CreateTocConfirmUIMP()
    confirmUIMP = NewUI()
    confirmUIMP.responseReceive = false

    confirmUIMP:addText("text1", "Are you sure?", "Title", "Center");
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
    confirmUIMP:addButton("b1", "Yes", OnClickTocConfirmUIMP);
    confirmUIMP.b1:addArg("option", "yes");
    confirmUIMP:addEmpty();
    confirmUIMP:addButton("b2", "No", OnClickTocConfirmUIMP);
    confirmUIMP:addEmpty();

    confirmUIMP:nextLine();
    confirmUIMP:addEmpty();

    confirmUIMP:saveLayout();
    confirmUIMP:addPrerenderFunction(PrerenderFuncMP);
    confirmUIMP:close();

end

-- We create everything from here

JCIO_UI.OnCreate = function()
    CreateTocMainUI()
    CreateTocDescUI()
    CreateTocConfirmUIMP()

    if isClient() then CreateTocConfirmUIMP() end
    mainUI:close()

end




--------------------------------------------
-- MP Confirm (I should add it to client too but hey not sure how it works tbh)

function SendCommandToConfirmUIMP(action, isBitten, userName, partName)
    confirmUIMP:setInCenterOfScreen()
    confirmUIMP:bringToTop()
    confirmUIMP:open()


    if action ~= "Wait server" then
        confirmUIMP["text4"]:setText("You're gonna " ..
            action .. " the " .. getText("UI_ContextMenu_" .. partName) .. " of " .. userName)

        confirmUIMP["text2"]:setText("Are you sure?")
        confirmUIMP["text2"]:setColor(1, 0, 0, 0)
        confirmUIMP["b1"]:setVisible(true)
        confirmUIMP["b2"]:setVisible(true)
    else

        confirmUIMP["text4"]:setText(action)
        confirmUIMP["text3"]:setText("")
        confirmUIMP["text2"]:setText("")
        confirmUIMP["b1"]:setVisible(false)
        confirmUIMP["b2"]:setVisible(false)
    end

end

--------------------------------------------
-- Add TOC element to Health Panel



JCIO_UI.onlineTempTable = {patient = nil, surgeon = nil}

JCIO.RefreshClientMenu = function(_)
    if mainUI:getIsVisible() == false then
        Events.OnTick.Remove(JCIO.RefreshClientMenu)
        JCIO_UI.onlineTempTable.patient = nil
        JCIO_UI.onlineTempTable.surgeon = nil

    else

        local limbs_data = JCIO_UI.onlineTempTable.patient:getModData().TOC.Limbs
        JCIO_UI.SetupMainUI(JCIO_UI.onlineTempTable.patient, JCIO_UI.onlineTempTable.patient, limbs_data)
    end

end


JCIO.RefreshOtherPlayerMenu = function(_)

    if mainUI:getIsVisible() == false then

        Events.OnTick.Remove(JCIO.RefreshOtherPlayerMenu)
        JCIO_UI.onlineTempTable.patient = nil
        JCIO_UI.onlineTempTable.surgeon = nil

        else
        if ModData.get("JCIO_PLAYER_DATA")[JCIO_UI.onlineTempTable.patient:getUsername()] ~= nil then
            local otherPlayerPartData = ModData.get("JCIO_PLAYER_DATA")[JCIO_UI.onlineTempTable.patient:getUsername()]

            JCIO_UI.SetupMainUI(JCIO_UI.onlineTempTable.surgeon, JCIO_UI.onlineTempTable.patient, otherPlayerPartData[1])


        end
    end
end





local ISHealthPanel_createChildren = ISHealthPanel.createChildren
local ISHealthPanel_render = ISHealthPanel.render
-- Add button to health panel
function ISNewHealthPanel.onClickJCIO(button)

    local surgeon = button.otherPlayer
    local patient = button.character

    JCIO_UI.onlineTempTable.patient = patient
    JCIO_UI.onlineTempTable.surgeon = surgeon

    -- MP Handling
    if surgeon then


        if surgeon == patient then
            Events.OnTick.Add(JCIO.RefreshClientMenu)

        else
            Events.OnTick.Add(JCIO.RefreshOtherPlayerMenu)            -- MP stuff, try to get the other player data and display it on the surgeon display
        end
    else
        -- SP Handling
        Events.OnTick.Add(JCIO.RefreshClientMenu)
    end


    -- Set the correct main title
    -- TODO sizes of the menu are strange in MP, they're not consistent with SP
    local separatedUsername = {}

    for v in string.gmatch(patient:getUsername(), "%u%l+") do
        table.insert(separatedUsername, v)
    end

    local main_title
    if separatedUsername[1] == nil then
        main_title = patient:getUsername() .. " - JCIO"
    else
        main_title = separatedUsername[1] .. " " .. separatedUsername[2] .. " - JCIO"
    end

    mainUI:setTitle(main_title)

    mainUI:toggle()
    mainUI:setInCenterOfScreen()

end

function ISHealthPanel:createChildren()
    ISHealthPanel_createChildren(self)

    self.fitness:setWidth(self.fitness:getWidth() / 1.4)

    self.TOCButton = ISButton:new(self.fitness:getRight() + 10, self.healthPanel.y, 60, 20, "", self,
        ISNewHealthPanel.onClickJCIO)
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
Events.OnCreateUI.Add(JCIO_UI.OnCreate)
