import lxml.etree as gfg 
  

def generate_clothing_item():
    root = gfg.Element("clothingItem")

    m_MaleModel = gfg.Element("m_MaleModel")
    m_MaleModel.text = "TEST TEXT FROM SOMETHING"
    root.append(m_MaleModel)

    m_FemaleModel = gfg.Element("m_FemaleModel")
    m_FemaleModel.text = "TEST TEXT FROM SOMETHING FEMALE"
    root.append(m_FemaleModel)

    m_GUID = gfg.Element("m_GUID")
    m_GUID.text = "get guid"
    root.append(m_GUID)

    m_Static = gfg.Element("m_Static")
    m_Static.text = "false"

    m_AllowRandomTint = gfg.Element("m_AllowRandomTint")
    m_AllowRandomTint.text = "false"

    # TODO Defined by the amount of textures that we're gonna pass
    for x in range(2):

        textureChoices = gfg.Element("textureChoices")
        textureChoices.text = "Texture path"

    tree = gfg.ElementTree(root)

    with open("Test_Name.xml", "wb") as file:
        tree.write(file, encoding='utf-8', xml_declaration=True, pretty_print=True )


def generate_recipe(recipe_name, recipe_items, result_name, time, skill_required, tooltip):
    # TODO Simple txt, so strings should be fine.
    print("Generating recipe")

    root_element = f"recipe {recipe_name}\n"
    root_element += "\t{\n"

    for item in recipe_items:
        root_element += f"\t\t{item},\n"

    root_element += f"\n\n\t\tResult: {result_name},\n"
    root_element += f"\t\tTime: {time:.2f},\n"
    root_element += "\t\tNeedToBeLearn: true,\n"
    root_element += "\t\tCanBeDoneFromFloor: false,\n"
    root_element += "\t\tOnGiveXP: NoXP_OnGiveXP,\n"
    root_element += f"\t\tSkillRequired: {skill_required[0]}={skill_required[1]},\n"
    root_element += "\t\tCategory: Surgeon,\n"
    root_element += f"\t\tTooltip: {tooltip},\n"

    root_element += "\t}"


    with open("Test_recipe.txt", "wt") as file:
        file.write(root_element)
        file.close()



def generate_item(item_name, weight, item_type, display_category, display_name, icon, tooltip, can_have_holes, clothing_item=None, body_location = None, blood_location = None):
    # TODO This is a txt, so we're gonna use simple strings I guess
    print("Generating item")

    root_element = f"item {item_name}\n"
    root_element += "\t{\n"

    root_element += f"\t\tWeight = {weight},\n"
    root_element += f"\t\tType = {item_type},\n"
    root_element += f"\t\tDisplayCategory = {display_category},\n"
    root_element += f"\t\tDisplayName = {display_name},\n"
    
    if item_type == "Clothing":
        root_element += f"\t\tClothingItem = {clothing_item},\n"
        root_element += f"\t\tBodyLocation = {body_location},\n"
        root_element += f"\t\tBloodLocation = {blood_location},\n"
    
    root_element += f"\t\tIcon = {icon},\n"
    root_element += f"\t\tTooltip = {tooltip},\n"
    root_element += f"\t\tCanHaveHoles = {can_have_holes},\n"

    root_element += "\t}"



    with open("Test_Item.txt", "wt") as file:
        file.write(root_element)
        file.close()



generate_clothing_item()


recipe_name = "Test Recipe"
recipe_items = ["Ass", "Penis", "Shit=3"]
result_name = "Cum sock"
time = 10
skill_required = ["Carpentry", "4"]
tooltip = "tooltip_test"

generate_recipe(recipe_name, recipe_items, result_name, time, skill_required, tooltip)


item_name = "Ass Ass Ass"
weight = 100
item_type = "Clothing"
display_category = "Prosthesis"
display_name = "Ass cock"
clothing_item = "ClothingItemSomethingProst"
body_location = "TOC_ArmRightProsthesis"

generate_item(item_name, weight, item_type, display_category, display_name, "test_icon", "test_tooltip", "false", clothing_item, body_location, "Hands")