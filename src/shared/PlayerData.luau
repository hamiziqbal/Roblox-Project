local ProfileTemplate = {
    Coins = 0,
    Gems = 0,
    Inventory = {
        Weapons = {},
        Armor = {},
        Items = {},
        Aura = {},
        EquippedId = 0,
    },
    LogInTimes = 0,
}

----- Services -----

local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

----- Folders -----

local Packages = ReplicatedStorage.Packages

----- Loaded Modules -----

local ProfileService = require(ServerScriptService.Server.ProfileService)
local Warp = require(Packages.warp)

----- Private Variables -----

local ProfileStore = ProfileService.GetProfileStore(
    "PlayerDataTest5",
    ProfileTemplate
)

local Profiles = {} -- [player] = profile

local Remote = Warp.Server("GiveCoins")
local Remote2 = Warp.Server("GiveItem")
local Remote3 = Warp.Server("Equip")

----- Private Functions -----

local function GiveCoins(profile, amount, player)
    -- If "Coins" was not defined in the ProfileTemplate at game launch,
    --   you will have to perform the following:
    if profile.Data.Coins == nil then
        profile.Data.Coins = 0
    end
    -- Increment the "Coins" value:
    profile.Data.Coins = profile.Data.Coins + amount
    Remote:Fire(true,player, profile.Data.Coins)
end

local function GiveItem(itemName, player, profile)
    Remote2:Fire(true, player, itemName, profile.Data.Inventory.EquippedId)
end

local function DoSomethingWithALoadedProfile(player, profile)
    if profile.Data.LogInTimes == 0 then
        table.insert(profile.Data.Inventory.Weapons, "Classic Sword")
        --GiveItem(profile.Data.Inventory.Weapons, player, profile)
    end

    profile.Data.LogInTimes = profile.Data.LogInTimes + 1

    print(player.Name .. " has logged in " .. tostring(profile.Data.LogInTimes)
        .. " time" .. ((profile.Data.LogInTimes > 1) and "s" or ""))

    Remote:Fire(true,player, profile.Data.Coins)
end

Remote:Connect(function(player)
    local profile = Profiles[player]

    GiveCoins(profile, 100, player)
end)

Remote3:Connect(function(player, id)
    if Profiles[player].Data.Inventory.EquippedId == id then
        Profiles[player].Data.Inventory.EquippedId = 0
    else
        Profiles[player].Data.Inventory.EquippedId = id
    end

    print("Yeah")

    Remote3:Fire(true, player, id)
end)

local function PlayerAdded(player)
    local profile = ProfileStore:LoadProfileAsync("Player_" .. player.UserId)
    if profile ~= nil then
        profile:AddUserId(player.UserId) -- GDPR compliance
        profile:Reconcile() -- Fill in missing variables from ProfileTemplate (optional)
        profile:ListenToRelease(function()
            Profiles[player] = nil
            -- The profile could've been loaded on another Roblox server:
            player:Kick()
        end)
        if player:IsDescendantOf(Players) == true then
            Profiles[player] = profile
            -- A profile has been successfully loaded:
            DoSomethingWithALoadedProfile(player, profile)
            GiveItem(profile.Data.Inventory.Weapons, player, profile)
        else
            -- Player left before the profile loaded:
            profile:Release()
        end
    else
        -- The profile couldn't be loaded possibly due to other
        --   Roblox servers trying to load this profile at the same time:
        player:Kick() 
    end
end

----- Initialize -----

-- In case Players have joined the server earlier than this script ran:
for _, player in ipairs(Players:GetPlayers()) do
    task.spawn(PlayerAdded, player)
end

----- Connections -----

Players.PlayerAdded:Connect(PlayerAdded)

Players.PlayerRemoving:Connect(function(player)
    local profile = Profiles[player]
    if profile ~= nil then
        profile:Release()
    end
end)

return ProfileTemplate