local att = {}
att.name = "md_cod4_acog_v2"
att.displayName = "Trijicon 4x32 ACOG"
att.displayNameShort = "ACOG"
att.aimPos = {"CoD4ACOGPos", "CoD4ACOGAng"}
att.FOVModifier = 15
att.isSight = true
att.colorType = CustomizableWeaponry.colorableParts.COLOR_TYPE_SIGHT
att.statModifiers = {
	OverallMouseSensMult = -0.1
}

if CLIENT then
	att.displayIcon = surface.GetTextureID("atts/acog")
	att.description = {
		[1] = {t = "Provides 4x magnification.", c = CustomizableWeaponry.textColors.POSITIVE},
		[2] = {t = "Narrow scope reduces awareness.", c = CustomizableWeaponry.textColors.NEGATIVE},
		[3] = {t = "Can be disorienting at close range.", c = CustomizableWeaponry.textColors.NEGATIVE}
	}
	
	att.reticle = "qq_sprites/cw2_chevron_small"
	
	local old, x, y, ang
	local reticle = surface.GetTextureID("qq_sprites/cw2_chevron_colorable")
	
	att.zoomTextures = {
		[1] = {tex = reticle, offset = {0, 1}}
	}
	
	local lens = surface.GetTextureID("cw2/gui/lense")
	local lensMat = Material("cw2/gui/lense")
	local cd, alpha = {}, 0.5
	local Ini = true
	
	cd.x = 0
	cd.y = 0
	cd.w = 512
	cd.h = 512
	cd.fov = 4.5
	cd.drawviewmodel = false
	cd.drawhud = false
	cd.dopostprocess = false
	
	function att:drawRenderTarget()
		if not self.ActiveAttachments[att.name] then return end
		
		local rc = self:getSightColor(att.name)
		local vec = Vector( rc.r / 255, rc.g / 255, rc.b / 255)
		local mat = Material("models/qq_rec/cod4_2014/weapon_acog_alpha_col_glow")
		mat:SetVector("$color2", vec)
		local mat = Material("qq_sprites/cw2_chevron_colorable")
		mat:SetVector("$color2", vec)
		
		local complexTelescopics = self:canUseComplexTelescopics()
		local correctMDL = self.AttachmentModelsVM[att.name] and self.AttachmentModelsVM[att.name].model == "models/v_cod4_acog.mdl"
		local isAiming = self:isAiming()
		local freeze = GetConVarNumber("cw_kk_freeze_reticles") != 0
		
		if self:canSeeThroughTelescopics(att.aimPos[1]) then
			alpha = math.Approach(alpha, 0, FrameTime() * 5)
		else
			alpha = math.Approach(alpha, 1, FrameTime() * 5)
		end
		
		if freeze then
			alpha = 0
		end
		
		if correctMDL then
			if (isAiming /*or freeze*/) and correctMDL then
				self.AttachmentModelsVM[att.name].ent:SetBodygroup(2, 1)
			else
				self.AttachmentModelsVM[att.name].ent:SetBodygroup(2, 0)
			end
		end
		
		if not complexTelescopics then
			self.TSGlass:SetTexture("$basetexture", lensMat:GetTexture("$basetexture"))
			if correctMDL then self.AttachmentModelsVM[att.name].ent:SetBodygroup(2, 0) end
			return
		end
		
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
		
		x, y = ScrW(), ScrH()
		old = render.GetRenderTarget()
	
		cd.angles = ang
		cd.origin = self.Owner:GetShootPos()
		render.SetRenderTarget(CustomizableWeaponry_KK_MagnifyingRT)
		render.SetViewPort(0, 0, 512, 512)
			
			if alpha < 1 then
				render.RenderView(cd)
			end
			
			ang = self.Owner:EyeAngles()
			ang.p = ang.p + self.BlendAng.x
			ang.y = ang.y + self.BlendAng.y
			ang.r = ang.r + self.BlendAng.z
			ang = -ang:Forward()
			
			-- render.Clear(255, 255, 255, 1, true, true)
			-- local c = {r = 255, g = 255, b = 255, a = 0}
			-- render.ClearRenderTarget( CustomizableWeaponry_KK_MagnifyingRT, c)
			-- render.RenderHUD(0,0,-100,0)
			-- render.SetMaterial( Material("models/qq_rec/cod4_2014/fake") )
			-- render.MaterialOverride( Material("models/qq_rec/cod4_2014/fake") )
			-- render.ClearStencil( )
			-- render.ClearDepth( )
			-- surface.SetDrawColor(255, 255, 255, 0)
			-- render.SetBlend( 0 )
						
			local light = render.ComputeLighting(self.Owner:GetShootPos(), ang)
			
			cam.Start2D()
				surface.SetDrawColor(255, 255, 255, 255)
				surface.SetTexture(reticle)
				surface.DrawTexturedRect(0, 0, 512, 512)
				
				surface.SetDrawColor(150 * light[1], 150 * light[2], 150 * light[3], 255 * alpha)
				surface.SetTexture(lens)
				surface.DrawTexturedRectRotated(256, 256, 512, 512, 90)
			cam.End2D()
		render.SetViewPort(0, 0, x, y)
		render.SetRenderTarget(old)
		
		if self.TSGlass then
			self.TSGlass:SetTexture("$basetexture", CustomizableWeaponry_KK_MagnifyingRT)
		end
	end
end

function att:attachFunc()
	self.OverrideAimMouseSens = 0.25
	self.SimpleTelescopicsFOV = 70
	self.BlurOnAim = true
	self.ZoomTextures = att.zoomTextures
end

function att:detachFunc()
	self.OverrideAimMouseSens = nil
	self.SimpleTelescopicsFOV = nil
	self.BlurOnAim = false
end

CustomizableWeaponry:registerAttachment(att)