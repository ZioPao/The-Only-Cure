
local function AddProfession()
    local surgeon = ProfessionFactory.addProfession(
            'surgeon',
            getText("UI_prof_surgeon"),
            "profession_surgeon",
            -6,
            getText("UI_profdesc_surgeon")
    );
    surgeon:addXPBoost(Perks.Doctor, 4);
    surgeon:addXPBoost(Perks.SmallBlade, 3);
    surgeon:getFreeRecipes():add("Make metal hand");
    surgeon:getFreeRecipes():add("Make metal hook");
    surgeon:getFreeRecipes():add("Make wooden hook");
    surgeon:getFreeRecipes():add("Combine real surgeon kit");
    surgeon:getFreeRecipes():add("Combine surgeon kit");
    surgeon:getFreeRecipes():add("Combine improvised surgeon kit");

    local profList = ProfessionFactory.getProfessions()
    for i=1,profList:size() do
        local prof = profList:get(i-1)
        BaseGameCharacterDetails.SetProfessionDescription(prof)
    end
end

Events.OnGameBoot.Add(AddProfession)