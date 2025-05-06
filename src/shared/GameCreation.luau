local rp = game:GetService("ReplicatedStorage")
local shared = rp.Shared
local Packages = rp.Packages
local Spring = require(shared.spr)
local Warp = require(Packages.warp)

local debounce = false

local Remote = Warp.Server("CreateParty")

return function()
    if debounce then return end
    debounce = true


    
    debounce = false
end