local att = {}
att.name = "md_cod4_aimpoint_v2"
att.displayName = "Tasco Red Dot reflex scope"
att.displayNameShort = "Tasco"
att.aimPos = {"CoD4TascoPos", "CoD4TascoAng"}
att.FOVModifier = 20
att.isSight = true
att.colorType = CustomizableWeaponry.colorableParts.COLOR_TYPE_SIGHT
att.statModifiers = {OverallMouseSensMult = -0.07}

if CLIENT then
	att.displayIcon = surface.GetTextureID("entities/md_cod4_aimpoint")
	att.description = {[1] = {t = "Provides a bright reticle to ease aiming.", c = CustomizableWeaponry.textColors.POSITIVE},
	[2] = {t = "Slightly increases aim zoom.", c = CustomizableWeaponry.textColors.POSITIVE},
	[3] = {t = "Narrow scope may decrease awareness.", c = CustomizableWeaponry.textColors.NEGATIVE}}
	
	att.reticle = "qq_sprites/bigdot"
	att._reticleSize = 2
	
	local RTRSize = 96
	local RDSLense = Material("models/qq_rec/cod4_2014/weapon_red_dot_reflexsight")
	local reticleTime = 0
	local Ini = true
	
	function att:drawRenderTarget()
		if not self.ActiveAttachments[att.name] then return end
		
		local rc = self:getSightColor(att.name)
		
		local isAiming = self:isAiming()
		local freeze = GetConVarNumber("cw_kk_freeze_reticles") != 0
		local isScopePos = (self.AimPos == self[att.aimPos[1]] and self.AimAng == self[att.aimPos[2]])
		local correctMDL = self.AttachmentModelsVM[att.name].model == "models/v_cod4_aimpoint.mdl"
		
		if isAiming and isScopePos and correctMDL then
			self.AttachmentModelsVM[att.name].ent:SetBodygroup(2, 1)
		else
			self.AttachmentModelsVM[att.name].ent:SetBodygroup(2, 0)
		end
		
		-- if not self:isAiming() then 
			-- RDSLense:SetTexture("$basetexture", "models/qq_rec/cod4_2014/512")
			-- return
		-- end
		
		if isAiming and self:isReticleActive() and isScopePos then
			reticleTime = math.Approach(reticleTime, 1, FrameTime() * 1.6)
		else
			RDSLense:SetTexture("$basetexture", "models/qq_rec/cod4_2014/512")
			if not freeze then 
				reticleTime = 0
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
				
				-- local dh = self:getDifferenceToAimPos(self.AimpointPos, self.AimpointAng, 0, 1, -3)
				-- local dv = self:getDifferenceToAimPos(self.AimpointPos, self.AimpointAng, 1, 0, -4)
				-- local rx = dh * (512 - RTRSize) / 2
				-- local ry = dv * (512 - RTRSize) / 2
				
				local dh, dv, rx, ry
				
				dh = 1
				dv = 1
			
				if reticleTime == 1 and not freeze then
					dh = self:getDifferenceToAimPos(self.AimPos, self.AimAng, 0, 1, -2)
					dv = self:getDifferenceToAimPos(self.AimPos, self.AimAng, 1, 0, -2.5)
				end
				
				rx = ((dh * (512 - RTRSize) / 2) + self.lastRX) / 2
				ry = ((dv * (512 - RTRSize) / 2) + self.lastRY) / 2
			
				surface.SetDrawColor(rc.r, rc.g, rc.b, 255)
				surface.SetTexture(surface.GetTextureID(att.reticle))
				surface.DrawTexturedRect(rx, ry, RTRSize, RTRSize)			
				
				surface.SetDrawColor(255, 255, 255, 100)
				surface.SetTexture(surface.GetTextureID(att.reticle))
				surface.DrawTexturedRect(rx + RTRSize/4, ry + RTRSize/4, RTRSize/2, RTRSize/2)	
				
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