import lxml.etree as gfg
import pandas as pd
import numpy as np
import openpyxl
  

def generate_clothing_item(name, part, model, texture_choices, guid = None):
    root = gfg.Element("clothingItem")

    m_MaleModel = gfg.Element("m_MaleModel")
    m_MaleModel.text = f"{model}_Male"
    root.append(m_MaleModel)

    m_FemaleModel = gfg.Element("m_FemaleModel")
    m_FemaleModel.text = f"{model}_Female"
    root.append(m_FemaleModel)

    m_GUID = gfg.Element("m_GUID")
    if guid:
        m_GUID.text = guid
    else:
        m_GUID.text = "get guid from func"

    root.append(m_GUID)

    m_Static = gfg.Element("m_Static")
    m_Static.text = "false"
    root.append(m_Static)

    m_AllowRandomTint = gfg.Element("m_AllowRandomTint")
    m_AllowRandomTint.text = "false"
    root.append(m_AllowRandomTint)

    # TODO Defined by the amount of textures that we're gonna pass
    for tex in texture_choices:
        textureChoices = gfg.Element("textureChoices")
        textureChoices.text = tex
        root.append(textureChoices)

    tree = gfg.ElementTree(root)

    path = r'output_clothing/Prost_' + part + "_" + name + ".xml"

    with open(path, "wb") as file:
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

###########################################################################################
def read_table(file_name: str, table_name: str) -> pd.DataFrame:
    wb = openpyxl.load_workbook(file_name, read_only= False, data_only = True) # openpyxl does not have table info if read_only is True; data_only means any functions will pull the last saved value instead of the formula
    for sheetname in wb.sheetnames: # pulls as strings
        sheet = wb[sheetname] # get the sheet object instead of string
        if table_name in sheet.tables: # tables are stored within sheets, not within the workbook, although table names are unique in a workbook
            tbl = sheet.tables[table_name] # get table object instead of string
            tbl_range = tbl.ref #something like 'C4:F9'
            break # we've got our table, bail from for-loop
    data = sheet[tbl_range] # returns a tuple that contains rows, where each row is a tuple containing cells
    content = [[cell.value for cell in row] for row in data] # loop through those row/cell tuples
    header = content[0] # first row is column headers
    rest = content[1:] # every row that isn't the first is data
    df = pd.DataFrame(rest, columns = header)
    wb.close()
    return df

###########################################################################################

excel_path = r'python_helpers/modules_prost.xlsx'
df_base = read_table(excel_path, "BaseTable")
df_top = read_table(excel_path, "TopTable")

for base_row in df_base.iterrows():
    for top_row in df_top.iterrows():
        base_name = base_row[1][0]
        top_name = top_row[1][0]

        current_name = base_name + "_" + top_name
        generate_clothing_item(current_name, "LowerArm", "test", {"test1", "test2"}, "123")










#generate_clothing_item()

# TODO we should get this stuff from a csv\xlsx and generate the correct values from that

recipe_name = "Test Recipe"
recipe_items = ["Ass", "Penis", "Shit=3"]
result_name = "Cum sock"
time = 10
skill_required = ["Carpentry", "4"]
tooltip = "tooltip_test"

#generate_recipe(recipe_name, recipe_items, result_name, time, skill_required, tooltip)


item_name = "Ass Ass Ass"
weight = 100
item_type = "Clothing"
display_category = "Prosthesis"
display_name = "Ass cock"
clothing_item = "ClothingItemSomethingProst"
body_location = "TOC_ArmRightProsthesis"

#generate_item(item_name, weight, item_type, display_category, display_name, "test_icon", "test_tooltip", "false", clothing_item, body_location, "Hands")