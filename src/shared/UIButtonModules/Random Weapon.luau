local rp = game:GetService("ReplicatedStorage")
local shared = rp.Shared
local packages = rp.Packages

local crates = require(shared.Crates)

local Warp = require(packages.warp)

local Remote = Warp.Client("GiveItem")

local player = game:GetService("Players").LocalPlayer
local GUI = player.PlayerGui
local UI = GUI:WaitForChild("HUD")

return function()
    Remote:Fire(true, crates.rollRandom("Basic Crate"),{Currency = "Coins", Amount = 100})
end