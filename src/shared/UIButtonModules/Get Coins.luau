local rp = game:GetService("ReplicatedStorage")
local shared = rp.Shared
local packages = rp.Packages

local Warp = require(packages.warp)
local NumberAnimation = require(shared.NumberAnimation)

local Remote = Warp.Client("GiveCoins")

local player = game:GetService("Players").LocalPlayer
local GUI = player.PlayerGui
local UI = GUI:WaitForChild("HUD")

Remote:Connect(function(amount)
    local coinsNumberAnimation = NumberAnimation.new(UI.Coins.Amount, amount, {
        Style = "Tween",
        Time = 1,
        EasingStyle = "Quad",
        EasingDirection = "InOut",
        Abbreviate = true
    })
    
    coinsNumberAnimation:Start()
end)

return function()
    Remote:Fire(true)
end