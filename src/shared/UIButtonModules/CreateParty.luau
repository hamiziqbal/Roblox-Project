local rp = game:GetService("ReplicatedStorage")
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

return function()
    if debounce then return end
    debounce = true

    Remote:Fire(true, Frame.SelectedFrame.CreateParty:GetAttribute("Difficulty"),Frame.SelectedFrame.CreateParty:GetAttribute("Map"))

    Frame.Maps.Visible = false
    Frame.SelectedFrame.Visible = false
    Frame.StartGame.Visible = true

    debounce = false
end