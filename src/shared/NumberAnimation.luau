local TweenService = game:GetService("TweenService")
local NumAnim = {}
local Num = {}
Num.__index = Num

local DefaultInfo = TweenInfo.new(1)

function NumAnim.new(Label,Value,Data : table)
	local Info = Data.Info
	if not Info then Info = DefaultInfo end
	
	local self = setmetatable({},Num)
	
	self.Label = Label
	if not Data.Value then
		self.Value = Instance.new("IntValue")
		self.Value.Value = tonumber(Label.Text)
	end
	self.Num = Value
	self.Tween = TweenService:Create(self.Value,Info,{Value = self.Num})
	self.Prefix = nil
	
	return self
end

function Num:SetPrefix(Prefix : string)
	self.Prefix = Prefix
end

function Num:ChangeValue(amount: number)
    self.Num = amount
	self:Start()
end

function Num:Start()
	self.Tween:Play()
	
	if self.Label then
		local ChangeConnection = self.Value.Changed:Connect(function()
			local NumValue = self.Value.Value
			if self.Prefix then
				self.Label.Text = string.format("%s %d",self.Prefix,NumValue)
			else
				self.Label.Text = NumValue
			end
		end)
		local Completed
		Completed = self.Tween.Completed:Connect(function()
			ChangeConnection:Disconnect()
			Completed:Disconnect()
		end)
	end
end

return NumAnim