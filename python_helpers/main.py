import lxml.etree as gfg 
  
# <?xml version="1.0" encoding="utf-8"?>
# <clothingItem>
#     <m_MaleModel>Prost_Left_Hand_MetalHand_Male</m_MaleModel>
#     <m_FemaleModel>Prost_Left_Hand_MetalHand_Female</m_FemaleModel>
#     <m_GUID>2101af26-54b9-455b-abc0-7533ce37f84b</m_GUID>
#     <m_Static>false</m_Static>
#     <m_AllowRandomHue>false</m_AllowRandomHue>
#     <m_AllowRandomTint>false</m_AllowRandomTint>
#     <textureChoices>Prosthesis\metal_base</textureChoices>
# </clothingItem>



def create_single_xml():
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

create_single_xml()