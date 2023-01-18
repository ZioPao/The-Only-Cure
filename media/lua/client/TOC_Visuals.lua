-- 6 skin tones or 5?

function TocSetCorrectTextureForAmputation(item, player)
    local human_visual = player:getHumanVisual()
    local texture_string = human_visual:getSkinTexture()
    local matched_index = string.match(texture_string, "%d$")
    print("TOC: Setting texture " .. matched_index)
    item:getVisual():setTextureChoice(tonumber(matched_index - 1))      -- TODO why is it correct with -1?
end