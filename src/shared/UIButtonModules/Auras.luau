local player = game:GetService("Players").LocalPlayer
local GUI = player.PlayerGui
local UI = GUI:WaitForChild("HUD")

return function()
    for _, frame in UI.InventoryFrame:GetChildren() do
        if frame:IsA("ScrollingFrame") then
            frame.Visible = false
        end
    end
    UI.InventoryFrame[script.Name].Visible = true
end