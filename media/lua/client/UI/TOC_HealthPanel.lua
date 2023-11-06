local CutLimbHandler = require("UI/TOC_CutLimbHandler")

-- TODO Use this to replace the sprites once a limb is cut
ISHealthBodyPartPanel = ISBodyPartPanel:derive("ISHealthBodyPartPanel")


--ISBodyPartPanel

-- function ISHealthBodyPartPanel:onMouseUp(x, y)
--     if self.selectedBp then
--         local dragging = ISInventoryPane.getActualItems(ISMouseDrag.dragging)
--         self.parent:dropItemsOnBodyPart(self.selectedBp.bodyPart, dragging)
--     end
-- end

-- function ISHealthBodyPartPanel:prerender()
--     self.nodeAlpha = 0.0
--     self.selectedAlpha = 0.1
--     if self.selectedBp then
--         for index,item in ipairs(self.parent.listbox.items) do
--             if item.item.bodyPart == self.selectedBp.bodyPart then
--                 self.nodeAlpha = 1.0
--                 self.selectedAlpha = 0.5
--                 break
--             end
--         end
--     end
--     ISBodyPartPanel.prerender(self)
-- end

-- function ISHealthBodyPartPanel:cbSetSelected(bp)
--     if bp == nil then
--         self.parent.listbox.selected = 0
--         return
--     end
--     for index,item in ipairs(self.parent.listbox.items) do
--         if item.item.bodyPart == bp.bodyPart then
--             self.parent.listbox.selected = index
--             break
--         end
--     end
-- end


local og_ISHealthPanel_dropItemsOnBodyPart = ISHealthPanel.dropItemsOnBodyPart

function ISHealthPanel:dropItemsOnBodyPart(bodyPart, items)
    og_ISHealthPanel_dropItemsOnBodyPart(self, bodyPart, items)
    local cutLimbHandler = CutLimbHandler:new(self, bodyPart)

    for _,item in ipairs(items) do
        cutLimbHandler:checkItem(item)
    end

    if cutLimbHandler:dropItems(items) then
        return
    end

end

local og_ISHealthPanel_doBodyPartContextMenu = ISHealthPanel.doBodyPartContextMenu

function ISHealthPanel:doBodyPartContextMenu(bodyPart, x, y)
    og_ISHealthPanel_doBodyPartContextMenu(self, bodyPart, x, y)
    local playerNum = self.otherPlayer and self.otherPlayer:getPlayerNum() or self.character:getPlayerNum()
    local context = getPlayerContextMenu(playerNum)     -- To not recreate it but reuse the one that has been created in the original method
    local cutLimbHandler = CutLimbHandler:new(self, bodyPart)
    cutLimbHandler:addToMenu(context)
end
















---------------------------------------------------------
local og_ISHealthPanel_render = ISHealthPanel.render

function ISHealthPanel:render()

    og_ISHealthPanel_render(self)
    
    -- Left Texture
    local handL = getTexture("media/ui/Hand_L.png")
    local forearmL = getTexture("media/ui/ForeArm_L.png")
    local upperarmL = getTexture("media/ui/UpperArm_L.png")

    self:drawTextureScaled(forearmL, self.healthPanel.x/2 - 2, self.healthPanel.y/2, 123, 302, 1, 1, 0, 0)

    -- Right Texture





end


function ISCharacterInfoWindow:render()
	ISCollapsableWindow.render(self)

    self.backgroundColor.a = 1
	if JoypadState.players[self.playerNum+1] then
		for _,view in pairs(self.panel.viewList) do
			if JoypadState.players[self.playerNum+1].focus == view.view then
				self:drawRectBorder(0, 0, self:getWidth(), self:getHeight(), 0.4, 0.2, 1.0, 1.0);
				self:drawRectBorder(1, 1, self:getWidth()-2, self:getHeight()-2, 0.4, 0.2, 1.0, 1.0);
				break
			end
		end
	end
end
-- function ISHealthPanel:createChildren()
--     self.healthPanel = ISNewHealthPanel:new(0, 8, self.character)
--     self.healthPanel:initialise()
--     self.healthPanel:instantiate()
--     self.healthPanel:setVisible(true)
--     self:addChild(self.healthPanel)
    
--     self.listbox = ISHealthBodyPartListBox:new(180 - 15, 59, self.width - (180 - 15), self.height);
--     self.listbox:initialise();
--     self.listbox:instantiate();
--     self.listbox:setAnchorLeft(true);
--     self.listbox:setAnchorRight(true);
--     self.listbox:setAnchorTop(true);
--     self.listbox:setAnchorBottom(false);
--     self.listbox.itemheight = 128;
--     self.listbox.drawBorder = false
--     self.listbox.backgroundColor.a = 0
--     self.listbox.drawText = ISHealthPanel.drawText;
--     self:addChild(self.listbox)

--     self.bodyPartPanel = ISHealthBodyPartPanel:new(self.character, 0, 8);
--     self.bodyPartPanel:initialise();
--     self.bodyPartPanel:setAlphas(0.0, 1.0, 0.5, 0.0, 0.0)
-- --    self.bodyPartPanel:setEnableSelectLines( true, self.bpAnchorX, self.bpAnchorY );
--     self.bodyPartPanel:enableNodes( "media/ui/Client_Icon_On.png", "media/ui/Client_Icon_On.png" )
--     self.bodyPartPanel:overrideNodeTexture( BodyPartType.Torso_Upper, "media/ui/BodyParts/bps_node_big", "media/ui/BodyParts/bps_node_big_outline" );
-- --    self.bodyPartPanel:setColorScheme(self.colorScheme);
--     self:addChild(self.bodyPartPanel);
    
--     self.fitness = ISButton:new(self.healthPanel.x + 165, self.healthPanel.y, 100, 20, getText("ContextMenu_Fitness"), self, ISNewHealthPanel.onClick);
--     self.fitness.internal = "FITNESS";
--     self.fitness.anchorTop = false
--     self.fitness.anchorBottom = true
--     self.fitness:initialise();
--     self.fitness:instantiate();
-- --    self.fitness.borderColor = self.buttonBorderColor;
--     self:addChild(self.fitness);
--     if getCore():getGameMode() == "Tutorial" then
--         self.fitness:setVisible(false);
--     end
--     self.blockingAlpha = 0.0;
-- --    print "instant";

-- end