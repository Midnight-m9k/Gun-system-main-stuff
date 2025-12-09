local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage.Shared
local Classes = Shared.Classes
local GunClasses = Classes.GunClasses

local Gun = ReplicatedStorage.Assets.Tools.Guns.M9
local GunHandle = Gun.Handle
local ReloadSound = Gun.ReloadSound

local MainGunClass = require(GunClasses.MainGunClass)

local player = game.Players.LocalPlayer
local Mouse = player:GetMouse()

local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local char = player.Character or player.CharacterAdded:Wait()
local hum = char:WaitForChild("Humanoid")
local root = char:WaitForChild("HumanoidRootPart")

local function shiftLock(active)
	if active then
		hum.CameraOffset = Vector3.new(1.75, 0, 0)
		hum.AutoRotate = false

		RunService:BindToRenderStep("ShiftLock", Enum.RenderPriority.Character.Value, function()
			UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter

			local _, y = workspace.CurrentCamera.CFrame.Rotation:ToEulerAnglesYXZ()
			root.CFrame = CFrame.new(root.Position) * CFrame.Angles(0, y, 0)
		end)
	else
		hum.AutoRotate = true
		hum.CameraOffset = Vector3.new(0, 0, 0)
		RunService:UnbindFromRenderStep("ShiftLock")
		UserInputService.MouseBehavior = Enum.MouseBehavior.Default
	end
end

Mouse.Icon = "http://www.roblox.com/asset/?id=9524023207"

Gun.Equipped:Connect(function()
	shiftLock(true)
end)

Gun.Unequipped:Connect(function()
	shiftLock(false)
end)

Gun.Activated:Connect(function()
	local mouse = game.Players.LocalPlayer:GetMouse()
	MainGunClass.Cast(GunHandle, mouse)
end)

UserInputService.InputBegan:Connect(function(input, gp)
	if gp then
		return
	end
	if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == Enum.KeyCode.R then
		MainGunClass.Reload(Gun)
		ReloadSound:Play()
	end
end)
