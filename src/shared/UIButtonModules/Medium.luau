local rp = game:GetService("ReplicatedStorage")
local shared = rp.Shared
local maps = require(shared.Maps)

local debounce = false

local player = game:GetService("Players").LocalPlayer
local GUI = player.PlayerGui
local UI = GUI:WaitForChild("HUD")
local Frame = UI:WaitForChild("GameFrame")

return function()
    if debounce then return end
    debounce = true

    local frame2 = Frame.SelectedFrame
    
    frame2.Difficulty.Text = "Difficulty: "..script.Name
    frame2.CreateParty:SetAttribute("Difficulty", script.Name)
    frame2.MapLevel.Text = "Lvl "..maps[frame2.CreateParty:GetAttribute("Map")].Levels[script.Name].."+"

    debounce = false
end