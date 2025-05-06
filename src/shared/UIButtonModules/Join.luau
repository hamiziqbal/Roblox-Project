local rp = game:GetService("ReplicatedStorage")
local shared = rp.Shared
local Spring = require(shared.spr)

local debounce = false

local player = game:GetService("Players").LocalPlayer
local GUI = player.PlayerGui
local UI = GUI:WaitForChild("HUD")
local Frame = UI:WaitForChild("GameFrame")

return function()
    if debounce then return end
    debounce = true

    Frame.Create.Visible = false
    Frame.Join.Visible = false
    Frame.Maps.Visible = false
    Frame.SelectedFrame.Visible = false
    Frame.StartGame.Visible = false
    Frame.ActiveParties.Visible = true

    debounce = false
end