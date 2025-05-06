local ProfileTemplate = {
    Coins = 0,
    Gems = 0,
    Level = 0,
    Exp = 0,
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
local TeleportService = game:GetService("TeleportService")

----- Folders -----

local Packages = ReplicatedStorage.Packages

----- Loaded Modules -----

local ProfileService = require(ServerScriptService.Server.ProfileService)
local Warp = require(Packages.warp)
local Maps = require(ReplicatedStorage.Shared.Maps)

----- Private Variables -----

local ProfileStore = ProfileService.GetProfileStore(
    "PlayerDataTest9",
    ProfileTemplate
)

local Profiles = {} -- [player] = profile
local ActiveParties = {}

local Remote = Warp.Server("GiveCoins")
local Remote2 = Warp.Server("GiveItem")
local Remote3 = Warp.Server("Equip")
local Remote4 = Warp.Server("CreateParty")
local Remote5 = Warp.Server("StartGame")

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

local function GiveItem(itemName, player, profile, id)
    if type(itemName) ~= "string" then
        id = -1
    end

    Remote2:Fire(true, player, itemName, profile.Data.Inventory.EquippedId, id)
end

local function DoSomethingWithALoadedProfile(player, profile)
    if profile.Data.LogInTimes == 0 then
        table.insert(profile.Data.Inventory.Weapons, "Classic Sword")
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

Remote2:Connect(function(player, itemName, check)
    local profile = Profiles[player]

    if check ~= nil then
        if profile.Data[check.Currency] >= check.Amount then
            profile.Data[check.Currency] -= check.Amount
            Remote:Fire(true,player, profile.Data[check.Currency])
            table.insert(profile.Data.Inventory.Weapons, itemName)
            GiveItem(itemName, player, profile, #profile.Data.Inventory.Weapons) 
        else
            print("Insufficient funds")
        end
    else
        table.insert(profile.Data.Inventory.Weapons, itemName)
        GiveItem(itemName, player, profile,#profile.Data.Inventory.Weapons)
    end
end)

local equipDebounce = false

Remote3:Connect(function(player, id)
    if equipDebounce then return end
    equipDebounce = true

    if Profiles[player].Data.Inventory.EquippedId == id then
        Profiles[player].Data.Inventory.EquippedId = 0
    else
        Profiles[player].Data.Inventory.EquippedId = id
    end

    print("Equipped Id: "..Profiles[player].Data.Inventory.EquippedId)

    Remote3:Fire(true, player, Profiles[player].Data.Inventory.EquippedId)

    equipDebounce = false
end)

local function createParties(party, player)
    --task.spawn(function()
        local template = ReplicatedStorage.Assets.MapTemplate:Clone()
        template.Background.Image = Maps[party.Map].Icon 
        template.MapName.Text = Maps[party.Map].Name
        template.Difficulty.Text = party.Difficulty
        template.MapLevel.Text = "Level "..Maps[party.Map].Levels[party.Difficulty].."+"
        template.Players.Text = "("..#party.Players.."/"..party.MaxPlayers..")"
        template.Username.Text = party.Players[1].Name
        template.Headshot.Image = Players:GetUserThumbnailAsync(party.Players[1].UserId,Enum.ThumbnailType.HeadShot,Enum.ThumbnailSize.Size48x48)
        template.UserLevel.Text = "Level "..Profiles[party.Players[1]].Data.Level        
        template.Parent = player.PlayerGui.HUD.GameFrame.ActiveParties

        template:SetAttribute("Id", party.Id)
    --end)
end

local Remote0 = Warp.Server("CreateButton")

Remote4:Connect(function(player, id, difficulty, map)
    if id == 0 then

        ActiveParties[#ActiveParties+1] = {
            Id = #ActiveParties+1,
            Difficulty = difficulty,
            Map = map,
            Players = {
                [1] = player,
            },
            MaxPlayers = 4,
        }

        id = #ActiveParties
        
    else
        ActiveParties[id].Players[#ActiveParties[id].Players+1] = player
    end

    local party = ActiveParties[id]

    if ActiveParties[id].Players[1] == player then
        for _, p in Players:GetPlayers() do
            createParties(party, p)
        end

        Remote0:Fires(true, party.Id)
    end

    for _, pr in ActiveParties[id].Players do
        local owner = false

        if ActiveParties[id].Players[1] == pr then
            owner = true
        end

        Remote4:Fire(true, player, pr, Profiles[pr].Data.Level, owner, #ActiveParties[id].Players)
    end

    for _, pr in ActiveParties[id].Players do
        if pr ~= player then
            Remote4:Fire(true, pr, player, Profiles[player].Data.Level, false, #ActiveParties[id].Players)
        end
    end

    
 end)

local function searchForPlayer(player)
    for _, party in ActiveParties do
        if party.Players[1] == player then
            return party
        end
    end

    return nil
end

Remote5:Connect(function(player)
    local party = searchForPlayer(player)
    if party ~= nil then
        local server = TeleportService:ReserveServer(128808972728561)
        TeleportService:TeleportToPrivateServer(128808972728561, server, party.Players)

        for _, player in party.Players do
            Remote5:Fire(true, player)
        end
    end
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
            
            local level = profile.Data.Level
            local ui =  player.PlayerGui:FindFirstChild("HUD").Level
            local maxXP = (math.round(0.04 * (level ^ 3) + 0.8 * (level ^ 2) + 2 * level) * 20) + 15

            ui.Text = "Level "..level
            ui.EXP.Amount.Text = profile.Data.Exp.."/"..maxXP
            ui.EXP.Fill.Size = UDim2.fromScale(profile.Data.Exp/maxXP,1)

            for _, party in ActiveParties do
                createParties(party, player)
                Remote0:Fire(true, player, party.Id)        
            end


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