local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Classes = Shared:WaitForChild("Classes")
local GunClasses = Classes:WaitForChild("GunClasses")
local MainGunClass = require(GunClasses:WaitForChild("MainGunClass"))

local Gun = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Tools"):WaitForChild("Guns"):WaitForChild("M9")
local player = Players.LocalPlayer

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "GunUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local label = Instance.new("TextLabel")
label.Position = UDim2.new(1, -190, 1, -80)
label.BackgroundTransparency = 0.4
label.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
label.TextColor3 = Color3.new(1, 1, 1)
label.Font = Enum.Font.SourceSansBold
label.TextSize = 20
label.Text = "Ammo: --"
label.Parent = screenGui
screenGui.Enabled = false

local function updateAmmo()
	local ammo = Gun:GetAttribute("AMMOCOUNT") or 0
	local max = Gun:GetAttribute("MAX_AMMO") or Gun:GetAttribute("AMMOCOUNT") or 0
	label.Text = ("Ammo: %d / %d"):format(ammo, max)
end

Gun.Equipped:Connect(function()
	screenGui.Enabled = true
	updateAmmo()
end)
Gun.Unequipped:Connect(function()
	screenGui.Enabled = false
end)

Gun:GetAttributeChangedSignal("AMMOCOUNT"):Connect(updateAmmo)

local reloadDebounce = false
UserInputService.InputBegan:Connect(function(input, gp)
	if gp then
		return
	end
	if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == Enum.KeyCode.R then
		if reloadDebounce then
			return
		end
		reloadDebounce = true
		pcall(function()
			MainGunClass.Reload(Gun)
		end)
		task.delay(1.2, function()
			reloadDebounce = false
		end)
	end
end)
