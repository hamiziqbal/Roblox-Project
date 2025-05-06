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

local Remote = Warp.Client("StartGame")

Remote:Connect(function()
    Frame.StartGame.Start.Text = "Teleporting..."
end)

return function()
    if debounce then return end
    debounce = true

    Remote:Fire(false)

    debounce = false
end