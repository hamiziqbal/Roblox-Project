local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Player = Players.LocalPlayer

local PlayerGUI = Player:WaitForChild("PlayerGui")

local Packages = ReplicatedStorage.Packages
local Shared = ReplicatedStorage.Shared

local Warp = require(Packages.warp)

local Spring = require(Shared.spr)
local NumberAnimation = require(Shared.NumberAnimation)
local Weapons = require(Shared.Weapons)
local Rarities = require(Shared.Rarities)

local Remote = Warp.Client("GiveCoins")
local Remote2 = Warp.Client("GiveItem")
local Remote3 = Warp.Client("Equip")

local ItemTemplate = ReplicatedStorage.Assets.Template

local UI = PlayerGUI:WaitForChild("HUD")
local InventoryFrame = UI.InventoryFrame

local circle = PlayerGUI.Effects.Circle

local mouse = Player:GetMouse()

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

local equipDebounce = false
local equipped

Remote2:Connect(function(items, equipped1)
    equipped = equipped

    for id, itemName in items do
        local Data = Weapons[itemName]

        local Item = ItemTemplate:Clone()
        Item.Name = Data.Name
        Item.Icon.Image = Data.Icon
        Item.BackgroundColor3 = Rarities[Data.Rarity].BackgroundColor
        Item.UIStroke.Color = Rarities[Data.Rarity].BorderColor

        Item.Parent = InventoryFrame.Loot

        local x,y = Item.Size.X.Scale,Item.Size.Y.Scale
        local hue, saturation, value = Item.BackgroundColor3:ToHSV()
        local strokehue, strokesaturation, strokevalue = Item.UIStroke.Color:ToHSV()

        Item.MouseEnter:Connect(function()
            if Item:FindFirstChild("UIScale") == nil then
                Spring.target(Item, 0.3, 3, {Size = UDim2.fromScale(x*1.1,y*1.1), BackgroundColor3 = Color3.fromHSV(hue, saturation, value - 0.2)})
            else
                Spring.target(Item, 0.3, 3, {BackgroundColor3 = Color3.fromHSV(hue, saturation, value - 0.2)})
                Spring.target(Item.UIScale, 0.3, 3, {Scale = 1.1})
            end
            Spring.target(Item.UIStroke, 0.3, 3, {Color = Color3.fromHSV(strokehue, strokesaturation, strokevalue - 0.2)})
            
            if equipped == id then
                Item.Equip.Text = "Unequip"
                Item.Equip.TextColor3 = Color3.fromRGB(207, 113, 113)
            else
                Item.Equip.Text = "Equip"
                Item.Equip.TextColor3 = Color3.fromRGB(55, 230, 6)
            end
            Item.Equip.Visible = true
        end)

        Item.MouseLeave:Connect(function()
            if Item:FindFirstChild("UIScale") == nil then
                Spring.target(Item, 0.3, 3, {Size = UDim2.fromScale(x,y), BackgroundColor3 = Color3.fromHSV(hue, saturation, value)})
            else
                Spring.target(Item, 0.3, 3, {BackgroundColor3 = Color3.fromHSV(hue, saturation, value)})
                Spring.target(Item.UIScale, 0.3, 3, {Scale = 1})
            end
            Spring.target(Item.UIStroke, 0.3, 3, {Color = Color3.fromHSV(strokehue, strokesaturation, strokevalue)})

            Item.Equip.Visible = false
        end)

        Item.MouseButton1Click:Connect(function()
            if equipDebounce then return end
            equipDebounce = true
            
            print("p")
            Remote3:Fire(true, id)
            print("no")
            Remote3:Once(function(plr, newEquipped)
                print("hey")
                equipped = newEquipped

                if equipped == id then
                    Item.Equip.Text = "Unequip"
                    Item.Equip.TextColor3 = Color3.fromRGB(207, 113, 113)
                else
                    Item.Equip.Text = "Equip"
                    Item.Equip.TextColor3 = Color3.fromRGB(55, 230, 6)
                end
    
                equipDebounce = false
            end)
        end)
    end
end)

local Button = UI:WaitForChild("Get Coins")
local InventoryButton = UI:WaitForChild("Inventory")

Button.MouseButton1Click:Connect(function()
    Remote:Fire(true)
end)


local debounce = false

InventoryButton.MouseButton1Click:Connect(function()
    if debounce then return end
    debounce = true
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