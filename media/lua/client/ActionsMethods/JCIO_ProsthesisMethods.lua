------------------------------------------
-------- JUST CUT IT OFF --------
------------------------------------------
---------- PROSTHESIS FUNCTIONS ----------


---Equip a prosthesis transforming a normal item into a clothing item
---@param partName string
---@param prosthesisItem any the prosthesis item
---@param prosthesisBaseName string
function JCIO.EquipProsthesis(partName, prosthesisItem, prosthesisBaseName)

    -- TODO probably will have to move this from the TOC menu to classic equip to have dynamic durability
    -- TODO We need to pass the original item so we can get its data!

    local player = getPlayer()
    local jcioModData = player:getModData().JCIO

    local equippedProsthesis = GenerateEquippedProsthesis(prosthesisItem, player:getInventory(), "Hand")


    --print("JCIO: Test durability new item " .. added_prosthesis_mod_data.TOC.durability)

    -- TODO equippedProsthesis must have something like the ProsthesisFactor from before!!!

    if partName ~= nil then

        if equippedProsthesis ~= nil then
            jcioModData.limbs[partName].isProsthesisEquipped = true


            -- Fill equippedProsthesis with the correct stuff
            -- TODO For prosthetics we should fetch the data from a modData INSIDE them!

            -- TODO Change the value passed, it's wrong
            --jcioModData.limbs[partName].equippedProsthesis = jcioModData.Prosthesis[prosthesisBaseName][partName]

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
function JCIO.UnequipProsthesis(patient, partName, equippedProsthesis)


    -- TODO Pass the parameters generated from EquipProsthesis to the re-generated normal item

    local jcioModData = patient:getModData().JCIO
    jcioModData.limbs[partName].isProsthesisEquipped = false


    local equippedProstFullType = equippedProsthesis:getFullType()


    for _, prostValue in ipairs(GetProsthesisList()) do
        local prostName = string.match(equippedProstFullType, prostValue)
        if prostName then
            -- Get mod data from equipped prosthesis so we can get its parameters
            local equippedProstModData = equippedProsthesis:getModData()


            local baseProstItem = patient:getInventory():AddItem("JCIO." .. prostName)
            local baseProstItemModData = baseProstItem.getModData()
            baseProstItemModData.JCIO = {
                durability = equippedProstModData.JCIO.durability,
                speed = equippedProstModData.JCIO.speed
            }

            patient:setWornItem(equippedProsthesis:getBodyLocation(), nil)
            patient:getInventory():Remove(equippedProsthesis)
            jcioModData.Limbs[partName].equipped_prosthesis = nil
        end
    end
end