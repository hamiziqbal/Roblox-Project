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

    if not Frame.Maps[string.sub(script.Name,7)].Locked.Visible then

        Frame.SelectedFrame.CreateParty:SetAttribute("Map", string.sub(script.Name,7))
        Frame.SelectedFrame.CreateParty:SetAttribute("Difficulty", "Easy")
        Frame.SelectedFrame.MapIcon.Image = maps[string.sub(script.Name,7)].Icon
        Frame.SelectedFrame.MapName.Text = string.sub(script.Name,7)
        Frame.SelectedFrame.Difficulty.Text = "Difficulty: Easy"
        Frame.SelectedFrame.MapLevel.Text = "Lvl "..maps[string.sub(script.Name,7)].Levels.Easy.."+"

        debounce = false
    end
end