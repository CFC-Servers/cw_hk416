local att = {}
att.name = "md_cod4_reflex"
att.displayName = "Sightmark Sure Shot reflex sight"
att.displayNameShort = "Reflex"
att.aimPos = {"CoD4ReflexPos", "CoD4ReflexAng"}
att.FOVModifier = 15
att.isSight = true
att.colorType = CustomizableWeaponry.colorableParts.COLOR_TYPE_SIGHT
att.statModifiers = {OverallMouseSensMult = -0.05}

if CLIENT then
	att.displayIcon = surface.GetTextureID("entities/md_cod4_reflex")
	att.description = {
		[1] = {t = "Provides a bright reticle to ease aiming.", c = CustomizableWeaponry.textColors.POSITIVE},
		[2] = {t = "Model taken directly from Call of Duty 4.", c = CustomizableWeaponry.textColors.POSITIVE}
	}
	
	att.reticle = "qq_sprites/circledot"
	att._reticleSize = 5 // I think I didnt use this...
	
	local RTRSize = 128
	local RDSLense = Material("models/qq_rec/cod4_2014/weapon_red_dot_reflexsight")
	local reticleTime = 0
	
	function att:drawRenderTarget()
		if not self.ActiveAttachments[att.name] then return end
		
		local rc = self:getSightColor(att.name)
		local int = 255
		
		local vec = Vector(rc.r / int, rc.g / int, rc.b / int)
		local mat = Material("models/qq_rec/cod4_2014/weapon_reflex_lens_col")
		mat:SetVector("$color2", vec)
		mat:SetVector("$envmaptint", vec)
		
		local vec2 = Vector( 1 - (rc.r / int), 1 - (rc.g / int), 1 - (rc.b / int))
		local mat2 = Material("models/qq_rec/cod4_2014/weapon_reflex_lens_col_2")
		mat2:SetVector("$color2", vec2)
		
		-- if rc == Color(0,0,0,0) and (table.ToString(hook.GetTable()):find("NV_FX") or table.ToString(hook.GetTable()):find("NV_PostDrawViewModel")) then
			-- rc = Color(255,255,255,255)
		-- end
		
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
			-- reticleTime = math.Approach(reticleTime, 0, FrameTime() * 20)
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
		-- render.SetRenderTarget(Material("models/qq_rec/cod4_2014/weapon_red_dot_reflexsight"):GetTexture("$basetexture"))
		render.SetViewPort(0, 0, 512, 512)
			render.Clear(0,0,0,0,false,false)
			
			if CustomizableWeaponry_KK_ReflexSightRT_Ini then
				render.RenderView()
				render.Clear(0,0,0,0,false,false)
				CustomizableWeaponry_KK_ReflexSightRT_Ini = false
			end
			
			cam.Start2D()
				-- surface.SetDrawColor(255 - rc.r, 255 - rc.g, 255 - rc.b, 255)
				-- surface.SetTexture(surface.GetTextureID("qq_sprites/bigcircle"))
				-- surface.DrawTexturedRect(192, 192, 128, 128)	
				
				-- local dh = self:getDifferenceToAimPos(self.CoD4ReflexPos, self.CoD4ReflexAng, 0, 1, -1.65) - 1
				-- local dv = self:getDifferenceToAimPos(self.CoD4ReflexPos, self.CoD4ReflexAng, 1, 0, -2.25) - 1
				-- local center = (512 - RTRSize) / 2
				-- local rx = center + (dh * (center + RTRSize))
				-- local ry = center + (dv * (center + RTRSize))
				
				local dh, dv, rx, ry
				
				dh = math.Clamp(self:getDifferenceToAimPos(self.AimPos, self.AimAng, 0, 1, -3) + 0.5, 1, 1)
				dv = 1
				-- self.AimSwayIntensity = 0
				
				if reticleTime == 1 and not freeze then
					dh = self:getDifferenceToAimPos(self.AimPos, self.AimAng, 0, 1, -2)
					dv = self:getDifferenceToAimPos(self.AimPos, self.AimAng, 1, 0, -2.5)
					-- self.AimSwayIntensity = self.AimSwayIntensityToRestore
				end
				
				rx = ((dh * (512 - RTRSize) / 2) + self.lastRX) / 2
				ry = ((dv * (512 - RTRSize) / 2) + self.lastRY) / 2
				
				self.lastRX = rx
				self.lastRY = ry
				
				surface.SetDrawColor(rc.r, rc.g, rc.b, 255)
				surface.SetTexture(surface.GetTextureID(att.reticle))
				surface.DrawTexturedRect(rx, ry, RTRSize, RTRSize)			
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
		
		-- self.AimSwayIntensityToRestore = self.AimSwayIntensity
	end
	
	function att:detachFunc()
		-- self.AimSwayIntensity = self.AimSwayIntensityToRestore
	end
end

CustomizableWeaponry:registerAttachment(att)