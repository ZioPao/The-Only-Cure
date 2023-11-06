local CutLimbHandler = require("TOC_UIHandler")

-- TODO Use this to replace the sprites once a limb is cut
ISHealthBodyPartPanel = ISBodyPartPanel:derive("ISHealthBodyPartPanel")

function ISHealthBodyPartPanel:onMouseUp(x, y)
    if self.selectedBp then
        local dragging = ISInventoryPane.getActualItems(ISMouseDrag.dragging)
        self.parent:dropItemsOnBodyPart(self.selectedBp.bodyPart, dragging)
    end
end

function ISHealthBodyPartPanel:prerender()
    self.nodeAlpha = 0.0
    self.selectedAlpha = 0.1
    if self.selectedBp then
        for index,item in ipairs(self.parent.listbox.items) do
            if item.item.bodyPart == self.selectedBp.bodyPart then
                self.nodeAlpha = 1.0
                self.selectedAlpha = 0.5
                break
            end
        end
    end
    ISBodyPartPanel.prerender(self)
end

function ISHealthBodyPartPanel:cbSetSelected(bp)
    if bp == nil then
        self.parent.listbox.selected = 0
        return
    end
    for index,item in ipairs(self.parent.listbox.items) do
        if item.item.bodyPart == bp.bodyPart then
            self.parent.listbox.selected = index
            break
        end
    end
end


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