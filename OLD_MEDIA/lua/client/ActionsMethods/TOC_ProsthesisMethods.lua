------------------------------------------
------------- THE ONLY CURE --------------
------------------------------------------
---------- PROSTHESIS FUNCTIONS ----------


---Equip a prosthesis transforming a normal item into a clothing item
---@param partName string
---@param prosthesisItem any the prosthesis item
---@param prosthesisBaseName string I don't really remember
function TOC.EquipProsthesis(partName, prosthesisItem, prosthesisBaseName)

    -- TODO probably will have to move this from the TOC menu to classic equip to have dynamic durability
    -- TODO We need to pass the original item so we can get its data!

    local player = getPlayer()
    local TOCModData = player:getModData().TOC

    local equippedProsthesis = GenerateEquippedProsthesis(prosthesisItem, player:getInventory(), partName)


    --print("TOC: Test durability new item " .. added_prosthesis_mod_data.TOC.durability)

    -- TODO equippedProsthesis must have something like the ProsthesisFactor from before!!!

    if partName ~= nil then

        if equippedProsthesis ~= nil then
            TOCModData.limbs[partName].isProsthesisEquipped = true


            -- Fill equippedProsthesis with the correct stuff
            -- TODO For prosthetics we should fetch the data from a modData INSIDE them!

            -- TODO Change the value passed, it's wrong
            --TOCModData.limbs[partName].equippedProsthesis = TOCModData.Prosthesis[prosthesisBaseName][partName]
            
            if player:isFemale() then
                equippedProsthesis:getVisual():setTextureChoice(1)
            else
                equippedProsthesis:getVisual():setTextureChoice(0)
            end
            player:setWornItem(equippedProsthesis:getBodyLocation(), equippedProsthesis)



        end
    end
end


---Unequip a prosthesis clothing item and returns it to the inventory as a normal item
---@param partName string
function TOC.UnequipProsthesis(patient, partName, equippedProsthesis)


    -- TODO Pass the parameters generated from EquipProsthesis to the re-generated normal item

    local TOCModData = patient:getModData().TOC
    TOCModData.limbs[partName].isProsthesisEquipped = false


    local equippedProstFullType = equippedProsthesis:getFullType()


    for _, prostValue in ipairs(GetProsthesisList()) do
        local prostName = string.match(equippedProstFullType, prostValue)
        if prostName then
            -- Get mod data from equipped prosthesis so we can get its parameters
            local equippedProstModData = equippedProsthesis:getModData()


            local baseProstItem = patient:getInventory():AddItem("TOC." .. prostName)
            local baseProstItemModData = baseProstItem.getModData()
            baseProstItemModData.TOC = {
                durability = equippedProstModData.TOC.durability,
                speed = equippedProstModData.TOC.speed
            }

            patient:setWornItem(equippedProsthesis:getBodyLocation(), nil)
            patient:getInventory():Remove(equippedProsthesis)
            TOCModData.limbs[partName].equippedProsthesis = nil
        end
    end
end