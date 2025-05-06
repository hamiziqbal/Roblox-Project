local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Player = Players.LocalPlayer

local PlayerGUI = Player:WaitForChild("PlayerGui")

local Packages = ReplicatedStorage.Packages
local Shared = ReplicatedStorage.Shared
local UIButtonModules = Shared.UIButtonModules

local Buttons = {}

task.spawn(function()
    for _, module in UIButtonModules:GetChildren() do
        Buttons[module.Name] = require(module)
    end
end)

local Warp = require(Packages.warp)

local Spring = require(Shared.spr)
local InventoryButton = require(Shared.InventoryButton)

local Remote2 = Warp.Client("GiveItem")
local Remote0 = Warp.Client("CreateButton")
local Remote4 = Warp.Client("CreateParty")

local UI = PlayerGUI:WaitForChild("HUD")

local circle = PlayerGUI.Effects.Circle

local mouse = Player:GetMouse()

Remote2:Connect(function(items, equipped, itemId)
    InventoryButton.EquippedId = equipped

    if itemId == -1 then
        for id, itemName in items do
            InventoryButton.new(itemName, id)
        end
    else
        InventoryButton.new(items, itemId)
    end
end)

Remote0:Connect(function(id)

    for _, party in UI.GameFrame.ActiveParties:GetChildren() do
        if party:IsA("Frame") then
            if party:GetAttribute("Id") == id then
                party.PlayMap.MouseButton1Click:Connect(function()
                    Remote4:Fire(true, id)

                    UI.GameFrame.ActiveParties.Visible = false
                    UI.GameFrame.StartGame.Visible = true
                end)
            end
        end
    end
end)

for _, button in UI:GetDescendants() do
    if button:IsA("TextButton") or button:IsA("ImageButton") then
        button.AutoButtonColor = false

        button.MouseButton1Click:Connect(function()
            task.spawn(function()
                local clone = circle:Clone()
                clone.Size = UDim2.fromScale(0.005,0.011)
                clone.Position = UDim2.fromOffset(mouse.X, mouse.Y)
                clone.Parent = PlayerGUI.Effects
                clone.Visible = true
                
                Spring.target(clone, 1, 3, {Size = UDim2.fromScale(0.05,0.112), ImageTransparency = 1})
                Spring.completed(clone,function()
                    clone:Destroy()
                end)
            end)

            Buttons[button.Name]()
        end)
        
        local x,y = button.Size.X.Scale,button.Size.Y.Scale
        local hue, saturation, value = button.BackgroundColor3:ToHSV()
        local strokehue, strokesaturation, strokevalue = button.UIStroke.Color:ToHSV()

        button.MouseEnter:Connect(function()
            if button:FindFirstChild("UIScale") == nil then
                Spring.target(button, 0.3, 3, {Size = UDim2.fromScale(x*1.1,y*1.1), BackgroundColor3 = Color3.fromHSV(hue, saturation, value - 0.2)})
            else
                Spring.target(button, 0.3, 3, {BackgroundColor3 = Color3.fromHSV(hue, saturation, value - 0.2)})
                Spring.target(button.UIScale, 0.3, 3, {Scale = 1.1})
            end
            Spring.target(button.UIStroke, 0.3, 3, {Color = Color3.fromHSV(strokehue, strokesaturation, strokevalue - 0.2)})
        end)

        button.MouseLeave:Connect(function()
            if button:FindFirstChild("UIScale") == nil then
                Spring.target(button, 0.3, 3, {Size = UDim2.fromScale(x,y), BackgroundColor3 = Color3.fromHSV(hue, saturation, value)})
            else
                Spring.target(button, 0.3, 3, {BackgroundColor3 = Color3.fromHSV(hue, saturation, value)})
                Spring.target(button.UIScale, 0.3, 3, {Scale = 1})
            end
            Spring.target(button.UIStroke, 0.3, 3, {Color = Color3.fromHSV(strokehue, strokesaturation, strokevalue)})
        end)
    end
end