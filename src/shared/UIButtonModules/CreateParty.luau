local rp = game:GetService("ReplicatedStorage")
local players = game:GetService("Players")
local shared = rp.Shared
local Packages = rp.Packages
local Spring = require(shared.spr)
local Warp = require(Packages.warp)

local debounce = false

local player = game:GetService("Players").LocalPlayer
local GUI = player.PlayerGui
local UI = GUI:WaitForChild("HUD")
local Frame = UI:WaitForChild("GameFrame")

local Remote = Warp.Client("CreateParty")
local Remote0 = Warp.Client("CreateButton")

function createTemplate(plr, plrLevel, owner, totalPlrs)
    local template = rp.Assets.PlayerTemplate:Clone()

    template.Username.Text = plr.Name
    template.Headshot.Image = players:GetUserThumbnailAsync(plr.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size60x60)
    template.Level.Text = "Lvl "..plrLevel
    template.Owner.Visible = owner

    template.Parent = Frame.StartGame.Players

    Frame.StartGame.Start.Title.Text = "Start Game - (" ..totalPlrs.. "/" .."4)"
end

Remote:Connect(function(plr, lvl, owner, totalPlrs)
    createTemplate(plr, lvl, owner, totalPlrs)

end)

return function()
    if debounce then return end
    debounce = true

    print("Hello")

    Remote:Fire(true, 0, Frame.SelectedFrame.CreateParty:GetAttribute("Difficulty"),Frame.SelectedFrame.CreateParty:GetAttribute("Map"))

    Frame.Maps.Visible = false
    Frame.SelectedFrame.Visible = false
    Frame.StartGame.Visible = true

    debounce = false
end