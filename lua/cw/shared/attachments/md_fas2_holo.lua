local att = {}
att.name = "md_fas2_holo"
att.displayName = "Hologram of sight"
att.displayNameShort = "Holosight"
att.aimPos = {"HoloPos", "HoloAng"}
att.FOVModifier = 15
att.isSight = true
att.colorType = CustomizableWeaponry.colorableParts.COLOR_TYPE_SIGHT
att.statModifiers = {OverallMouseSensMult = -0.03}

if CLIENT then
	-- att.displayIcon = surface.GetTextureID("VGUI/entities/scifi_holosight")
	att.displayIcon = surface.GetTextureID("entities/md_fas2_holo")
	att.description = {
		{t = "Provides a futuristic reticle to make taking down targets more pleasurable.", c = CustomizableWeaponry.textColors.VPOSITIVE},
		{t = "Fancy sight with bunch of moving parts might slightly reduce awareness.", c = CustomizableWeaponry.textColors.NEGATIVE},
	}
	
	att.reticle = "cw2/reticles/aim_reticule"
	
	local StatusDisplay = Material("models/qq_rec/scifi/rt_ammo")
	local Ini = true
	
	function att:drawRenderTarget()
		if not self.ActiveAttachments[att.name] then return end
	
		local function showRings(doIt)
			if self.AttachmentModelsVM.md_fas2_holo_aim then
				self.AttachmentModelsVM.md_fas2_holo_aim.active = doIt
				-- self.AttachmentModelsVM.md_fas2_holo_aim.ent:SetRenderFX(kRenderFxHologram)
				self.AttachmentModelsVM.md_fas2_holo_aim.pos = self.AttachmentModelsVM.md_fas2_holo.pos
				self.AttachmentModelsVM.md_fas2_holo_aim.ang = self.AttachmentModelsVM.md_fas2_holo.ang
			end
		end
		
		local clipSize = self.Primary.ClipSize
		local clip = self:Clip1()
		local clipp = math.Clamp((clip/clipSize), 0, 1)
		
		-- local hp = LocalPlayer():Health()
		local hp = self.Owner:Health()
		local hpp = math.Clamp((hp / 100), 0, 1)
		
		local ammoVec = Vector((1 - (clipp)) * (-0.895), 0, 0)
		local healthVec = Vector((1 - (hpp)) * (-0.895), 0, 0)
		
		local holoEnt = self.AttachmentModelsVM.md_fas2_holo.ent
		holoEnt:ManipulateBonePosition(holoEnt:LookupBone("holo_ammo"), ammoVec)
		holoEnt:ManipulateBonePosition(holoEnt:LookupBone("holo_heat"), healthVec)
		
		local rc = self:getSightColor(att.name)
		local vec = Vector(rc.r / 255,rc.g / 255,rc.b / 255)
		
		Material("models/qq_rec/scifi/holo_bg1"):SetVector("$color2", vec)
		Material("models/qq_rec/scifi/holo_fg1"):SetVector("$color2", vec)
		Material("models/qq_rec/scifi/holo_fg2"):SetVector("$color2", vec)
		Material("models/qq_rec/scifi/holo_mg"):SetVector("$color2", vec)
		Material("models/qq_rec/scifi/holo_mg2"):SetVector("$color2", vec)
		Material("models/qq_rec/scifi/holo_mg3"):SetVector("$color2", vec)
	
		local freeze = GetConVarNumber("cw_kk_freeze_reticles") != 0
		local isAiming = self:isAiming() 
		local isScopePos = (self.AimPos == self[att.aimPos[1]] and self.AimAng == self[att.aimPos[2]])
			
		local trace = {}
		trace.start = self.Owner:GetShootPos()
		trace.endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector()*60000
		trace.filter = self.Owner
		local tr = util.TraceLine(trace)
		local dist = self.Owner:GetShootPos():Distance(tr.HitPos)/39.37

		local target
		target = tr.Entity
		target = IsValid(target) and (target:IsNPC() or target:IsPlayer())
		target = target and not ((self.IsReloading and self.CW_VM:GetCycle() < 0.98) or self.NearWall or self.dt.State == CW_CUSTOMIZE)
		
		if (target) then
			dist = math.Round(dist, 1)
			showRings(true)
		else
			dist = math.Round(dist)
			showRings(false)
		end	

		self.md_fas2_holo_target = target
		self.md_fas2_holo_dist = dist
		
		if (isAiming and isScopePos) or freeze then
			Material("models/qq_rec/scifi/holo_fg2_white"):SetTexture("$basetexture", "models/qq_rec/scifi/holo_fg2_white")
		else
			Material("models/qq_rec/scifi/holo_fg2_white"):SetTexture("$basetexture", "models/qq_rec/cod4_2014/512")
		end
		
		if not isScopePos and self.ActiveAttachments.md_magnifier_scope then
			holoEnt:SetBodygroup(1,2)
			showRings(false)
			return 
		else
			holoEnt:SetBodygroup(1,0)
		end
		
		local old, x, y
		x, y = ScrW(), ScrH()
		old = render.GetRenderTarget()
		
		render.SetRenderTarget(CustomizableWeaponry_KK_HoloSightRT)
		render.SetViewPort(0, 0, 512, 512)
			render.Clear(0,0,0,0,false,false)
			
			if CustomizableWeaponry_KK_HoloSightRT_Ini then
				render.RenderView(cd)
				CustomizableWeaponry_KK_HoloSightRT_Ini = false
			end
			
			cam.Start2D()
				//HP
				surface.SetFont( "CW_HUD48" )
				surface.SetTextPos(60, 95)
				surface.SetTextColor(rc.r,rc.g,rc.b,255)
				surface.DrawText(hpp*100)
				
				surface.SetTextPos(60, 95) 
				surface.SetTextColor(255,255,255,255-(255*hpp))
				surface.DrawText(hpp*100)
				
				//MAG
				surface.SetFont( "CW_HUD48" )
				surface.SetTextPos(450 - surface.GetTextSize(clip), 95) 
				surface.SetTextColor(rc.r,rc.g,rc.b,255)
				surface.DrawText(clip)
				
				surface.SetTextPos(450 - surface.GetTextSize(clip), 95) 
				surface.SetTextColor(255,255,255,255-(255*clipp))
				surface.DrawText(clip)
				
				//MISC
				Material("models/qq_rec/scifi/holo_fg1"):SetTexture("$basetexture", "models/qq_rec/scifi/holo_fg1_notext")
				
				surface.SetTextColor(rc.r,rc.g,rc.b,255)
				
				local txt

				surface.SetFont( "CW_HUD28" )
				
				if self.dt.M203Active and self.M203Chamber and isAiming then
					txt = "SINGLE M203"
				else
					txt = self.FireModeDisplay
				end
				surface.SetTextPos(256 - (surface.GetTextSize(txt) / 2), 335) 
				surface.DrawText(txt)
				
				if self.FireMode == "safe" or self:isRunning() or !self:isReticleActive() then
					showRings(false)
				else
					if (target) then
						surface.SetTextColor(255,255,255,255)
					else
						surface.SetTextColor(rc.r,rc.g,rc.b,255)
					end	

					txt = dist .. "m"
					surface.SetTextPos(256 - (surface.GetTextSize(txt) / 2), 364) 
					surface.DrawText(txt)
				end
			cam.End2D()
			
		render.SetViewPort(0, 0, x, y)
		render.SetRenderTarget(old)
		
		if StatusDisplay then
			StatusDisplay:SetTexture("$basetexture", CustomizableWeaponry_KK_HoloSightRT)
		end	
	end
	
	function att:elementRender() // render fork-around
		if not self.ActiveAttachments[att.name] then return end
		if not self.AttachmentModelsVM[att.name] then return end
		self.AttachmentModelsVM[att.name].ent:DrawModel()
		
		if not self.AttachmentModelsVM.md_fas2_holo_aim then return end
		if not self.AttachmentModelsVM.md_fas2_holo_aim.active then return end
		self.AttachmentModelsVM.md_fas2_holo_aim.ent:DrawModel()
	end
	
	function att:attachFunc()
		-- local holoElement = self.AttachmentModelsVM.md_fas2_holo
		
		-- if holoElement.size then
			-- holoElement.matrix = Matrix()
			
			-- holoElement.matrix:Scale(Vector(- holoElement.size.x,- holoElement.size.y, holoElement.size.z))
			-- holoElement.ent:EnableMatrix("RenderMultiply", holoElement.matrix)
		-- end
			
		
		-- self.AttachmentModelsVM.md_fas2_holo.ent:SetRenderMode(RENDERMODE_GLOW)
		-- self.AttachmentModelsVM.md_fas2_holo.ent:SetRenderFX(kRenderFxHologram)
		
		-- local v = self.AttachmentModelsVM.md_fas2_holo
		-- v.ent = ClientsideModel(v.model, RENDERGROUP_BOTH)
		-- v.matrix = Matrix()
		-- v.matrix:Scale(v.size)
		-- v.ent:EnableMatrix("RenderMultiply", v.matrix)
	end
end

CustomizableWeaponry:registerAttachment(att)