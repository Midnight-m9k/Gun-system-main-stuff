local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = ReplicatedStorage.Remotes
local TakeDamageRemote = Remotes.TakeDamage
local ReloadRemote = Remotes.ReloadRemote
local LastFireTime = 0

local Dest_Multi = 1000

local GunClass = {}

type GunClass = typeof(GunClass) & {
	DAMAGE: number,
	AMMOCOUNT: number,
	GunHandle: MeshPart,
	HitPart: Instance,
	gun: Tool,
	FIRECOOLODWN: number,
	CanFire: BoolValue,
}

function reload(gun)
	local self = table.clone(GunClass)
	self.AMMOCOUNT = gun:GetAttribute("AMMOCOUNT")
	print("Sending request to server")
	ReloadRemote:FireServer()
	return self
end

return {
	Cast = function(GH, mouse)
		local self = table.clone(GunClass)
		self.GunHandle = GH
		self.gun = GH.Parent
		self.DAMAGE = self.GunHandle.Parent:GetAttribute("DAMAGE")
		self.FIRECOOLODWN = self.gun:GetAttribute("FIRECOOLDOWN")

		local rayOrigin = self.GunHandle

		--local rayDir = (Mouse.Hit.Position - rayOrigin.Position).Unit * Dest_Multi

		TakeDamageRemote:FireServer(rayOrigin, mouse.Hit.Position)
		print("Fired from client")
		return self
	end,

	ServerFunction = function(Player, Gun, origin, targetPos)
		local currentTime = tick()
		local self = table.clone(GunClass)

		self.GunHandle = Gun:FindFirstChild("Handle")
		self.gun = Gun
		self.DAMAGE = Gun:GetAttribute("DAMAGE")
		self.AMMOCOUNT = Gun:GetAttribute("AMMOCOUNT")
		self.FIRECOOLODWN = Gun:GetAttribute("FIRECOOLDOWN")
		self.CanFire = Gun:GetAttribute("CanFire")

		if self.CanFire == false then
			return self
		end

		if currentTime - LastFireTime < self.FIRECOOLODWN then
			print("weapon on cooldown")
			return
		end

		LastFireTime = currentTime

		if self.AMMOCOUNT <= 0 then
			return self
		end

		self.AMMOCOUNT -= 1

		Gun:SetAttribute("AMMOCOUNT", self.AMMOCOUNT)

		if not origin or not targetPos then
			return self
		end
		self.gun.FireSound:Play()

		local rayDir = (targetPos - origin.Position).Unit * Dest_Multi

		local RayParams = RaycastParams.new()
		RayParams:AddToFilter(Player.Character)
		RayParams.FilterType = Enum.RaycastFilterType.Exclude

		local RayRes = workspace:Raycast(origin.Position, rayDir, RayParams)

		if RayRes and RayRes.Instance then
			print("Found ray: ", RayRes)
			local Char = RayRes.Instance:FindFirstAncestorOfClass("Model")
			if Char then
				local hum = Char:FindFirstChildOfClass("Humanoid")
				if hum then
					hum:TakeDamage(self.DAMAGE)
					self.gun.HitSound:Play()
				end
			end
		end

		return self
	end,

	Reload = reload,
}
