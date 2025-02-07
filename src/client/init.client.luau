local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Player = Players.LocalPlayer

local PlayerGUI = Player:WaitForChild("PlayerGui")

local Packages = ReplicatedStorage.Packages
local Warp = require(Packages.warp)

local Remote = Warp.Client("GiveCoins")

local UI = PlayerGUI:WaitForChild("HUD")

Remote:Connect(function(amount)
    print(amount)
    UI.Coins.Amount.Text = amount
end)

local Button = UI:WaitForChild("Get Coins")

Button.MouseButton1Click:Connect(function()
    Remote:Fire(true)
end)