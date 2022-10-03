local att = {}
att.name = "md_cod4_eotech_v2"
att.displayName = "EOTech 552 holographic sight"
att.displayNameShort = "EoTech"
att.aimPos = {"EoTech552Pos", "EoTech552Ang"}
att.FOVModifier = 15
att.isSight = true
att.colorType = CustomizableWeaponry.colorableParts.COLOR_TYPE_SIGHT
att.statModifiers = {OverallMouseSensMult = -0.05}

if CLIENT then
	att.displayIcon = surface.GetTextureID("atts/eotech553")
	att.description = {
		[1] = {t = "Provides a bright reticle to ease aiming.", c = CustomizableWeaponry.textColors.POSITIVE},
		[2] = {t = "Model taken directly from Call of Duty 4.", c = CustomizableWeaponry.textColors.POSITIVE}
	}
	
	att.reticle = "qq_sprites/c128"
	att._reticleSize = 6

	local RTRSize = 192
	local RDSLense = Material("models/qq_rec/cod4_2014/weapon_red_cross_c128")
	local reticleTime = 0
		
	function att:drawRenderTarget()
		if not self.ActiveAttachments[att.name] then return end
		
		local rc = self:getSightColor(att.name)
		local mat = Material("models/qq_rec/cod4_2014/weapon_holographic_lens_glow_col")
		local vec = Vector( rc.r / 512, rc.g / 512, rc.b / 512)
		mat:SetVector("$color2", vec)
		
		local isAiming = self:isAiming()
		local freeze = GetConVarNumber("cw_kk_freeze_reticles") != 0
		local isScopePos = (self.AimPos == self[att.aimPos[1]] and self.AimAng == self[att.aimPos[2]])
		
		-- if not isAiming then 
			-- RDSLense:SetTexture("$basetexture", "models/qq_rec/cod4_2014/512")
			-- return
		-- end
		
		if isAiming and self:isReticleActive() and isScopePos then
			reticleTime = math.Approach(reticleTime, 1, FrameTime() * 2)
		else
			reticleTime = 0
			if not freeze then
				RDSLense:SetTexture("$basetexture", "models/qq_rec/cod4_2014/512")
				return
			end
		end
		
		local old, x, y
		x, y = ScrW(), ScrH()
		old = render.GetRenderTarget()
		
		render.SetRenderTarget(CustomizableWeaponry_KK_ReflexSightRT)
		render.SetViewPort(0, 0, 512, 512)
			render.Clear(0,0,0,0,false,false)
			
			if CustomizableWeaponry_KK_ReflexSightRT_Ini then
				render.RenderView()
				render.Clear(0,0,0,0,false,false)
				CustomizableWeaponry_KK_ReflexSightRT_Ini = false
			end
			
			cam.Start2D()
				-- surface.SetDrawColor(255 - rc.r, 255 - rc.g, 255 - rc.b, 255)
				-- surface.SetTexture(surface.GetTextureID(att.reticle))
				-- surface.DrawTexturedRect(192, 192, 128, 128)	
				
				-- local dh = self:getDifferenceToAimPos(self.EoTechPos, self.EoTechAng, 0, 1, -5)
				-- local dv = self:getDifferenceToAimPos(self.EoTechPos, self.EoTechAng, 1, 0, -10)
				-- local rx = dh * (512 - RTRSize) / 2
				-- local ry = dv * (512 - RTRSize) / 2
				
				local dh, dv, rx, ry
				
				dh = 1
				dv = 1
			
				if reticleTime == 1 and not freeze then
					dh = self:getDifferenceToAimPos(self.AimPos, self.AimAng, 0, 1, -3)
					dv = self:getDifferenceToAimPos(self.AimPos, self.AimAng, 1, 0, -4)
				end
				
				rx = ((dh * (512 - RTRSize) / 2) + self.lastRX) / 2
				ry = ((dv * (512 - RTRSize) / 2) + self.lastRY) / 2
			
				surface.SetDrawColor(rc.r, rc.g, rc.b, 210 + math.random(45))
				surface.SetTexture(surface.GetTextureID(att.reticle))
				surface.DrawTexturedRect(rx, ry, RTRSize, RTRSize)		
				self.lastRX = rx
				self.lastRY = ry		
			cam.End2D()
			
		render.SetViewPort(0, 0, x, y)
		render.SetRenderTarget(old)
		
		if RDSLense then
			if (isAiming and self:isReticleActive()) or freeze then 
				RDSLense:SetTexture("$basetexture", CustomizableWeaponry_KK_ReflexSightRT)
			else
				RDSLense:SetTexture("$basetexture", "models/qq_rec/cod4_2014/512")
			end
		end	
	end
	
	function att:attachFunc()
		self.lastRX = 0
		self.lastRY = 0
	end
end

CustomizableWeaponry:registerAttachment(att)