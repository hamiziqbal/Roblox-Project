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

    Frame.SelectedFrame.Difficulty.Text = "Difficulty: Easy"
    Frame.SelectedFrame.MapName.Text = "Forest"
    Frame.SelectedFrame.MapLevel.Text = "Lvl 0+"
    Frame.SelectedFrame.MapIcon.Image = "rbxassetid://11612788415"
    Frame.SelectedFrame.CreateParty:SetAttribute("Difficulty", "Easy")
    Frame.SelectedFrame.CreateParty:SetAttribute("Map", "Forest")

    Frame.Create.Visible = false
    Frame.Join.Visible = false
    Frame.Maps.Visible = true
    Frame.SelectedFrame.Visible = true
    Frame.StartGame.Visible = false

    debounce = false
end