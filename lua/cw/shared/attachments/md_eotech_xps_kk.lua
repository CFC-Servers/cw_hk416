local att = {}
att.name = "md_eotech_xps_kk"
att.displayName = "EOTech XPS holographic sight"
att.displayNameShort = "XPS"
att.aimPos = {"EoTechXPSPos", "EoTechXPSAng"}
att.FOVModifier = 10
att.isSight = true
att.colorType = CustomizableWeaponry.colorableParts.COLOR_TYPE_SIGHT
att.statModifiers = {}

if CLIENT then
	att.displayIcon = surface.GetTextureID("entities/md_eotech_xps_kk")
	att.description = {
		[1] = {t = "Provides true EOTech aiming experience", c = CustomizableWeaponry.textColors.POSITIVE},
		[2] = {t = "while maintaining low profile and compact package.", c = CustomizableWeaponry.textColors.POSITIVE}
	}
	
	att.reticle = "models/qq_rec/fas2_2015/eotech_reticle"
	att._reticleSize = 4

	local rc, isAiming, freeze, isScopePos, attachmEnt, EA, retPos, retNorm, retAng
	
	function att:elementRender()
		if not self.ActiveAttachments[att.name] then return end
		if not self.AttachmentModelsVM[att.name] then return end
		
		rc = self:getSightColor(att.name)
		isAiming = self:isAiming()
		freeze = GetConVarNumber("cw_kk_freeze_reticles") != 0
		isScopePos = (self.AimPos == self[att.aimPos[1]] and self.AimAng == self[att.aimPos[2]])
		attachmEnt = self.AttachmentModelsVM[att.name].ent
		
		if not isScopePos then
			return
		end
		
		if isAiming or self.dt.BipodDeployed then
			self._stencilTimeChck = CurTime() + 0.1
		end
		
		if self._stencilTimeChck and self._stencilTimeChck < CurTime() then return end
		
		render.ClearStencil()
		render.SetStencilEnable(true)
		render.SetStencilWriteMask(1)
		render.SetStencilTestMask(1)
		render.SetStencilReferenceValue(1)
		render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_ALWAYS)
		render.SetStencilPassOperation(STENCILOPERATION_REPLACE)
		render.SetStencilFailOperation(STENCILOPERATION_KEEP)
		render.SetStencilZFailOperation(STENCILOPERATION_KEEP)
		
		attachmEnt:SetModel("models/c_ins2_eotech_xps_stencil.mdl")
		attachmEnt:DrawModel()
		
		render.SetStencilWriteMask(2)
		render.SetStencilTestMask(2)
		render.SetStencilReferenceValue(2)
		render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_EQUAL)
		render.SetStencilPassOperation(STENCILOPERATION_REPLACE)
		render.SetStencilWriteMask(1)
		render.SetStencilTestMask(1)
		render.SetStencilReferenceValue(1)
		
		render.SetMaterial(att._reticle)
		
		EA = self:getReticleAngles()
		retPos = EyePos() + EA:Forward() * 12 *(attachmEnt:GetPos():Distance(EyePos()))
		retNorm = attachmEnt:GetAngles():Forward()
		retAng = 180 + attachmEnt:GetAngles().z
		
		cam.IgnoreZ(true)
			render.CullMode(MATERIAL_CULLMODE_CW)
				render.DrawQuadEasy(retPos, retNorm, att._reticleSize, att._reticleSize, Color(rc.r,rc.g,rc.b,150 + math.random(50)), retAng)
				render.DrawQuadEasy(retPos, retNorm, att._reticleSize, att._reticleSize, Color(rc.r,rc.g,rc.b,150 + math.random(50)), retAng)
			render.CullMode(MATERIAL_CULLMODE_CCW)
		cam.IgnoreZ(false)
		
		attachmEnt:SetModel("models/c_ins2_eotech_xps.mdl")
		
		render.SetStencilEnable(false)
	end
end

CustomizableWeaponry:registerAttachment(att)
