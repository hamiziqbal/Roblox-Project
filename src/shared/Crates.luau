local crates = {
    ["Basic Crate"] = {
        Icon = "rbxassetid://17368402884",
        Items = {
            [1] = {
                Name = "Longsword",
                Chance = 0.45,
            },
            [2] = {
                Name = "Club",
                Chance = 0.30,
            },
            [3] = {
                Name = "Spear",
                Chance = 0.20,
            },
            [4] = {
                Name = "Scythe",
                Chance = 0.05,
            },
        },
        Cost = 100,
        Rarity = "Common",
    },
}

function crates.rollRandom(crateName)
    local randomNumber = math.random(0,100)
    local Weight = 0

    for _,item in crates[crateName].Items do
        Weight+= item.Chance * 100

        if Weight >= randomNumber then
            return item.Name
        end
    end
end

return crates