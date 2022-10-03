AddCSLuaFile()

/*
	yourswep/shared.lua:

	SWEP.MagnifierPos
	SWEP.MagnifierAng
		- this is for zoomed magnifier
		- MANDATORY

	SWEP.WhateverYourPrimarySightsAimPosIsCalled_mag3x
	SWEP.WhateverYourPrimarySightsAimAngIsCalled_mag3x
		- "_mag3x" means that they will be used instead of default position when magnifier is attached
		- may be necessary if you want to move your primary sight using SWEP.AttachmentPosDependency
		- OPTIONAL

	SWEP.MagnifierScopeAxisAlign = {right = -0.35, up = 0, forward = 0}
		- same as ACOG axis align
		- always try these values first
		- OPTIONAL

	SWEP.primarySightCategory = 1
		- by default, first attachment category is considered Sights(primary sights for magnifier)
		- if you want to have sights in different category, specify its index here, otherwise, lulz
		- MANDATORY IF NOT 1

	currently supported primary sights
		md_microt1
		md_aimpoint
		md_eotech

		md_cod4_eotech
		md_cod4_aimpoint

		md_fas2_eotech
		md_fas2_aimpoint
*/

local att = {}
att.name = "md_magnifier_scope"
att.displayName = "Tactical 3x Magnifier Scope"
att.displayNameShort = "Eotech 3x"
att.aimPos = {"MagnifierPos", "MagnifierAng"}
att.isSecondarySight = true

att.statModifiers = {
	OverallMouseSensMult = -0.1
}

if CLIENT then
	att.displayIcon = surface.GetTextureID("entities/md_magnifier_scope")
	att.description = {
		{t = "Provides 3x magnification.", c = CustomizableWeaponry.textColors.POSITIVE},
		{t = "Allows quick toggling between 1x and 3x zoom.", c = CustomizableWeaponry.textColors.VPOSITIVE},
		{t = "^^ Double tap +use key while aiming to ^^.", c = CustomizableWeaponry.textColors.REGULAR},
	}

	att.zoomTextures = {[1] = {tex = surface.GetTextureID("cw2/reticles/reticle_chevron"), offset = {0, 1}}}

	-- local rc
	local RTMat = Material("cw2/attachments/lens/rt")

	local old, x, y, ang
	local Ini = true

	local lens = surface.GetTextureID("cw2/gui/lense")
	local cd, alpha, reticleTime = {}, 0.5, 0

	cd.x = 0
	cd.y = 0
	cd.w = 512
	cd.h = 512
	cd.fov = 6.75
	cd.drawviewmodel = false
	cd.drawhud = false
	cd.dopostprocess = false

	local fake = surface.GetTextureID("models/qq_rec/cod4_2014/fake")
	local fakeLong = surface.GetTextureID("models/qq_rec/cod4_2014/fake_long")

	function att:omgDrawRenderTarget()
		if not self.ActiveAttachments[att.name] then return end
		local currentPrimarySight = self:getActiveAttachmentInCategory(self.primarySightCategory or 1)

		local rc
		if currentPrimarySight then
			rc = self:getSightColor(currentPrimarySight)
		else
			rc = {r = 0, g = 0, b = 0, a = 0}
		end

		// hax the aimpositions when primary sight is changed
		if self.lastPrimarySight != currentPrimarySight then
			sight = CustomizableWeaponry.sights[currentPrimarySight]

			self.ActualSightPos = self.MagnifierPos
			self.ActualSightAng = self.MagnifierAng
			if sight then
				self.SightBackUpPos = self[sight.aimPos[1]]
				self.SightBackUpAng = self[sight.aimPos[2]]
			else
				self.SightBackUpPos = self.AimPos_Orig
				self.SightBackUpAng = self.AimAng_Orig
			end

			if self.magnifierWasOn then
				self.AimPos = self.ActualSightPos
				self.AimAng = self.ActualSightAng
			else
				self.AimPos = self.SightBackUpPos
				self.AimAng = self.SightBackUpAng
			end
		end
		self.lastPrimarySight = currentPrimarySight

		// something
		if self:canSeeThroughTelescopics(att.aimPos[1]) then
			alpha = math.Approach(alpha, 0, FrameTime() * 5)
			reticleTime = math.Approach(reticleTime, 1, FrameTime() * 1.8)
		else
			alpha = math.Approach(alpha, 1, FrameTime() * 5)
			reticleTime = 0
		end

		local scopeEnt = self.AttachmentModelsVM[att.name].ent
		local isScopePos = (self.AimPos == self[att.aimPos[1]] and self.AimAng == self[att.aimPos[2]])
		local isAiming = self:isAiming()
		local soundTrigger = self.magnifierWasOn

		if isScopePos then
			self.magnifierWasOn = true
		else
			self.magnifierWasOn = false
		end

		if soundTrigger != self.magnifierWasOn then
			self:EmitSound("CW_MagnifierScope_KK_Switch")
		end

		// magnifier bodygroups and bonemods
		if isScopePos then
			scopeEnt:ManipulateBoneAngles(scopeEnt:LookupBone("scope"), Angle(0, 0, 0))
			scopeEnt:ManipulateBoneAngles(scopeEnt:LookupBone("lock"), Angle(0, 0, 0))
			if isAiming then
				scopeEnt:SetBodygroup(1, 1)
			else
				scopeEnt:SetBodygroup(1, 0)
				return
			end
		elseif !isScopePos then
			scopeEnt:ManipulateBoneAngles(scopeEnt:LookupBone("scope"), Angle(self.MagnifierFoldAngle or -95, 0, 0))
			scopeEnt:ManipulateBoneAngles(scopeEnt:LookupBone("lock"), Angle(-33.204, 0, 0))
			scopeEnt:SetBodygroup(1, 0)
			return
		end

		// render target
		x, y = ScrW(), ScrH()
		old = render.GetRenderTarget()

		if self.freeAimOn then
			ang = self:getTelescopeAngles()
		else
			ang = self:getReticleAngles()
		end

		if self.ViewModelFlip then
			ang.r = -self.BlendAng.z
		else
			ang.r = self.BlendAng.z
		end

		cd.angles = ang
		cd.origin = self.Owner:GetShootPos()
		render.SetRenderTarget(CustomizableWeaponry_KK_MagnifyingRT)
		render.SetViewPort(0, 0, 512, 512)

			if alpha < 1 or Ini then
				render.RenderView(cd)
				Ini = false
			end

			ang = self.Owner:EyeAngles()
			ang.p = ang.p + self.BlendAng.x
			ang.y = ang.y + self.BlendAng.y
			ang.r = ang.r + self.BlendAng.z
			ang = -ang:Forward()

			local light = render.ComputeLighting(self.Owner:GetShootPos(), ang)

			cam.Start2D()
				local dh, dv, rx, ry

				dh = 1
				dv = 1

				if reticleTime == 1 then
					dh = math.Clamp(self:getDifferenceToAimPos(self.AimPos, self.AimAng, 0, 1, 0.3),0,2)
					dv = math.Clamp(self:getDifferenceToAimPos(self.AimPos, self.AimAng, 1, 0, 0.3),0,2)
				end

				rx = dh * 512 - 1024
				ry = dv * 512 - 1024

				if CustomizableWeaponry_KK_Magnifier_SupportedSights[currentPrimarySight] then
					CustomizableWeaponry_KK_Magnifier_SupportedSights[currentPrimarySight](self,rc)
				end

				surface.SetDrawColor(255, 255, 255, 255)
				surface.SetTexture(fakeLong)
				surface.DrawTexturedRect(rx, ry, 1536, 1536)

				surface.SetDrawColor(255, 255, 255, 255)
				surface.SetTexture(fake)
				surface.DrawTexturedRect(6, 6, 500, 500)

				surface.SetDrawColor(150 * light[1], 150 * light[2], 150 * light[3], 255 * alpha)
				surface.SetTexture(lens)
				surface.DrawTexturedRectRotated(256, 256, 512, 512, 90)
			cam.End2D()
		render.SetViewPort(0, 0, x, y)
		render.SetRenderTarget(old)

		if RTMat then
			RTMat:SetTexture("$basetexture", CustomizableWeaponry_KK_MagnifyingRT)
		end
	end
end

local function veCpy(o)
	if o and o.x and o.y and o.z then
		return Vector(o.x, o.y, o.z)
	else
		return nil
	end
end

function att:attachFunc()
	if CLIENT then
		self.KKRenderTargetFunc = att.omgDrawRenderTarget

		self.primarySightCategory = self.primarySightCategory or 1
		local psc = self.primarySightCategory

		// update all primary aimpositions where alternative is given
		for k,v in pairs(self.Attachments[psc].atts) do
			local sight = CustomizableWeaponry.sights[v]

			if sight then
				if self[sight.aimPos[1] .. "_mag3x"] then
					if (not self[sight.aimPos[1] .. "_mag3x_restore"]) then
						self[sight.aimPos[1] .. "_mag3x_restore"] = veCpy(self[sight.aimPos[1]])
						self[sight.aimPos[2] .. "_mag3x_restore"] = veCpy(self[sight.aimPos[2]])
					end

					self[sight.aimPos[1]] = self[sight.aimPos[1] .. "_mag3x"]
					self[sight.aimPos[2]] = self[sight.aimPos[2] .. "_mag3x"]
				end
			end
		end

		// update current aimpos
		local sight = CustomizableWeaponry.sights[self:getActiveAttachmentInCategory(psc)]

		self.ActualSightPos = self.MagnifierPos
		self.ActualSightAng = self.MagnifierAng
		if sight then
			self.SightBackUpPos = self[sight.aimPos[1]]
			self.SightBackUpAng = self[sight.aimPos[2]]
		else
			self.SightBackUpPos = self.AimPos_Orig
			self.SightBackUpAng = self.AimAng_Orig
		end

		if self.magnifierWasOn == nil or self.magnifierWasOn == true then
			self.magnifierWasOn = true
			self.AimPos = self.ActualSightPos
			self.AimAng = self.ActualSightAng
		else
			self.AimPos = self.SightBackUpPos
			self.AimAng = self.SightBackUpAng
		end
	end

	-- self.ZoomTextures = att.zoomTextures
	-- self.OverrideAimMouseSens = 0.25
	-- self.SimpleTelescopicsFOV = 70
	self.BlurOnAim = true
end

function att:detachFunc()
	if CLIENT then
		self.KKRenderTargetFunc = nil

		self.primarySightCategory = self.primarySightCategory or 1
		local psc = self.primarySightCategory

		local currentPrimarySight = self:getActiveAttachmentInCategory(psc)

		// restore all supported attachments aimpositions upon detaching magnifier
		for k,v in pairs(self.Attachments[psc].atts) do
			local sight = CustomizableWeaponry.sights[v]

			if sight then
				if self[sight.aimPos[1] .. "_mag3x_restore"] then
					self[sight.aimPos[1]] = self[sight.aimPos[1] .. "_mag3x_restore"]
					self[sight.aimPos[2]] = self[sight.aimPos[2] .. "_mag3x_restore"]
				end
			end
		end

		// restore current aimpos
		local sight = CustomizableWeaponry.sights[currentPrimarySight]
		if sight then
			self.AimPos = self[sight.aimPos[1]]
			self.AimAng = self[sight.aimPos[2]]
		else
			self.AimPos = self.AimPos_Orig
			self.AimAng = self.AimAng_Orig
		end

		//restore backup sight position for current sight
		if not self.BackupSights then
			self.BackupSights = {}
		end

		local backUp = self.BackupSights[self:getActiveAttachmentInCategory(self.SightCategoryIndex or 1)]
		if backUp then
			self.SightBackUpPos = backUp[1]
			self.SightBackUpAng = backUp[2]
		else
			self.SightBackUpPos = nil
			self.SightBackUpAng = nil
		end
	end

	-- self.OverrideAimMouseSens = nil
	-- self.SimpleTelescopicsFOV = nil
	self.BlurOnAim = false
end

CustomizableWeaponry:registerAttachment(att)

CustomizableWeaponry:addReloadSound("CW_MagnifierScope_KK_Switch", {
	"weapons/cw_2_fas2_kk/switch.wav",
	"weapons/cw_2_fas2_kk/switch1.wav",
	"weapons/cw_2_fas2_kk/switch2.wav",
	"weapons/cw_2_fas2_kk/switch3.wav",
	"weapons/cw_2_fas2_kk/switch4.wav",
	"weapons/cw_2_fas2_kk/switch5.wav",
	"weapons/cw_2_fas2_kk/switch6.wav",
})

if CLIENT then
	CustomizableWeaponry_KK_Magnifier_SupportedSights = {}
end

function CustomizableWeaponry_KK_Magnifier_AddPrimarySight(tab)
	if not tab then return end
	if not tab.sight or not tab.func then return end

	if CLIENT then
		CustomizableWeaponry_KK_Magnifier_SupportedSights[tab.sight] = tab.func
	end
end

for k, v in pairs(file.Find("cw/shared/attachments/md_magnifier_scope_kk/*", "LUA")) do
	loadFile("cw/shared/attachments/md_magnifier_scope_kk/" .. v)
end
