local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage.Shared
local Classes = Shared.Classes
local GunClasses = Classes.GunClasses

local MainGunClass = require(GunClasses.MainGunClass)

local Gun = ReplicatedStorage.Assets.Tools.Guns.M9

local Remotes = ReplicatedStorage.Remotes
local TakeDamageRemote = Remotes.TakeDamage
local ReloadRemote = Remotes.ReloadRemote

TakeDamageRemote.OnServerEvent:Connect(function(player, origin, targetPos)
	MainGunClass.ServerFunction(player, Gun, origin, targetPos)
end)

ReloadRemote.OnServerEvent:Connect(function()
	Gun:SetAttribute("CanFire", false)

	Gun:SetAttribute("AMMOCOUNT", 8)
	print("Recieved reload request from client, your ammo: ", Gun:GetAttribute("AMMOCOUNT"))

	task.wait(2)

	Gun:SetAttribute("CanFire", true)
end)

game.Players.PlayerAdded:Connect(function(plr)
	task.wait(4)
	Gun.Parent = plr.Backpack
end)
