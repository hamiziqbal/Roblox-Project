local rp = game:GetService("ReplicatedStorage")
local shared = rp.Shared
local Spring = require(shared.spr)

local debounce = false

local player = game:GetService("Players").LocalPlayer
local GUI = player.PlayerGui
local UI = GUI:WaitForChild("HUD")
local InventoryFrame = UI:WaitForChild("InventoryFrame")

return function()
    if debounce then return end
    debounce = true

    for _, frame in UI:GetChildren() do
        if string.find(frame.Name, "Frame") and frame ~= InventoryFrame then
            frame.Visible = false
        end
    end

    if InventoryFrame.Visible then
        InventoryFrame.Position = UDim2.fromScale(0.5,0.5)
        Spring.target(InventoryFrame, 1, 3, {Position = UDim2.fromScale(0.5,1.5)})
        Spring.completed(InventoryFrame,function()
            InventoryFrame.Visible = not InventoryFrame.Visible
            debounce = false
        end)
    else
        InventoryFrame.Position = UDim2.fromScale(0.5,1.5)
        InventoryFrame.Visible = not InventoryFrame.Visible
        Spring.target(InventoryFrame, 0.3, 3, {Position = UDim2.fromScale(0.5,0.5)})
        Spring.completed(InventoryFrame,function()
            debounce = false
        end)
    end
end