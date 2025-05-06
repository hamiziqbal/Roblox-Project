local rp = game:GetService("ReplicatedStorage")
local shared = rp.Shared
local Spring = require(shared.spr)

local debounce = false

local player = game:GetService("Players").LocalPlayer
local GUI = player.PlayerGui
local UI = GUI:WaitForChild("HUD")
local Frame = UI:WaitForChild("GameFrame")

return function()
    if debounce then return end
    debounce = true

    for _, frame in UI:GetChildren() do
        if string.find(frame.Name, "Frame") and frame ~= Frame then
            frame.Visible = false
        end
    end

    if Frame.Visible then
        Frame.Position = UDim2.fromScale(0.5,0.5)
        Spring.target(Frame, 1, 3, {Position = UDim2.fromScale(0.5,1.5)})
        Spring.completed(Frame,function()
            Frame.Visible = not Frame.Visible
            debounce = false
        end)
    else
        Frame.Position = UDim2.fromScale(0.5,1.5)
        Frame.Visible = not Frame.Visible

        Frame.Create.Visible = true
        Frame.Join.Visible = true
        Frame.Maps.Visible = false
        Frame.SelectedFrame.Visible = false
        Frame.StartGame.Visible = false

        Spring.target(Frame, 0.3, 3, {Position = UDim2.fromScale(0.5,0.5)})
        Spring.completed(Frame,function()
            debounce = false
        end)
    end
end