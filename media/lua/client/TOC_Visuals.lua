-- 6 skin tones or 5?

function TocSetCorrectTextureForAmputation(item, player)

    local human_visual = player:getHumanVisual()

    local texture_string = human_visual:getSkinTexture()
    print(texture_string)


    local matched_index = string.match(texture_string, "%d$")
    print(matched_index)


    item:getVisual():setTextureChoice(tonumber(matched_index))

    


end