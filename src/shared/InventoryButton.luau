local buttons = {}
buttons.__index = buttons

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer

local Mouse = Player:GetMouse()

local PlayerGUI = Player:WaitForChild("PlayerGui")

local Shared = ReplicatedStorage.Shared
local Packages = ReplicatedStorage.Packages

local Spring = require(Shared.spr)
local Weapons = require(Shared.Weapons)
local Rarities = require(Shared.Rarities)

local Warp = require(Packages.warp)

local ItemTemplate = ReplicatedStorage.Assets.Template

local UI = PlayerGUI:WaitForChild("HUD")
local InventoryFrame = UI.InventoryFrame

local Remote3 = Warp.Client("Equip")

buttons.EquippedId = 0

function buttons.new(itemName, id)
    local self = setmetatable({}, buttons)

    local Data = Weapons[itemName]

    self.id = id
    self.Damage = Data.Damage
    self.Speed = math.floor((1/Data.Speed) * 10)/10
    self.Reach = Data.HitboxLength

    local Item = ItemTemplate:Clone()
    Item.Name = Data.Name
    Item.Icon.Image = Data.Icon
    Item.BackgroundColor3 = Rarities[Data.Rarity].BackgroundColor
    Item.UIStroke.Color = Rarities[Data.Rarity].BorderColor
    Item.ItemName.Text = Data.Name

    Item.Parent = InventoryFrame.Weapons

    local x,y = Item.Size.X.Scale,Item.Size.Y.Scale
    local hue, saturation, value = Item.BackgroundColor3:ToHSV()
    local strokehue, strokesaturation, strokevalue = Item.UIStroke.Color:ToHSV()

    if buttons.EquippedId == self.id then
        Item.Equipped.Visible = true
        Item.LayoutOrder = -1
    else
        Item.LayoutOrder = self.id
    end

    local connection

    Item.MouseEnter:Connect(function()
        PlayerGUI.Effects.HoverStats.Size = UDim2.fromScale(0.01,0.01)
        Spring.target(PlayerGUI.Effects.HoverStats, 0.5, 10, {Size = UDim2.fromScale(0.044,0.139)})

        local statss = {"Damage", "Speed", "Reach"}
        
        for _, stat in statss do
            PlayerGUI.Effects.HoverStats[stat].Stat.Text = self[stat]
        end

        connection = RunService.RenderStepped:Connect(function()

            PlayerGUI.Effects.HoverStats.Position = UDim2.fromOffset(Mouse.X, Mouse.Y)
        end)

        if Item:FindFirstChild("UIScale") == nil then
            Spring.target(Item, 0.3, 3, {Size = UDim2.fromScale(x*1.1,y*1.1), BackgroundColor3 = Color3.fromHSV(hue, saturation, value - 0.2)})
        else
            Spring.target(Item, 0.3, 3, {BackgroundColor3 = Color3.fromHSV(hue, saturation, value - 0.3)})
            Spring.target(Item.UIScale, 0.3, 3, {Scale = 1.1})
        end
        Spring.target(Item.UIStroke, 0.3, 3, {Color = Color3.fromHSV(strokehue, strokesaturation, strokevalue - 0.3)})
        
        if buttons.EquippedId == self.id then
            Item.Equip.Text = "Unequip"
            Item.Equip.TextColor3 = Color3.fromRGB(207, 113, 113)
            Item.Equipped.Visible = true
        else
            Item.Equip.Text = "Equip"
            Item.Equip.TextColor3 = Color3.fromRGB(55, 230, 6)
            Item.Equipped.Visible = false
        end
        Item.Equip.Visible = true
    end)

    Item.MouseLeave:Connect(function()
        if connection then
            connection:Disconnect()
            PlayerGUI.Effects.HoverStats.Position = UDim2.new(3,0,3,0)
        end

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
        Remote3:Fire(true, self.id)
    end)

    Remote3:Connect(function(newEquipped)
        task.wait()
    
        buttons.EquippedId = newEquipped
    
        if buttons.EquippedId == self.id then
            Item.Equip.Text = "Unequip"
            Item.Equip.TextColor3 = Color3.fromRGB(207, 113, 113)
            Item.Equipped.Visible = true
            Item.LayoutOrder = -1
        else
            Item.Equip.Text = "Equip"
            Item.Equip.TextColor3 = Color3.fromRGB(55, 230, 6)
            Item.Equipped.Visible = false
            Item.LayoutOrder = id
        end
    end)
end

return buttons