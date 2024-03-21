function ISObjectClickHandler.doClickCurtain(object, playerNum, playerObj)
    TOC_DEBUG.print("Opening door")

    if not object:canInteractWith(playerObj) then return false end
    object:ToggleDoor(playerObj)
    return true
end
