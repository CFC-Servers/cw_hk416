local att = {}
att.name = "md_backup_reflex"
att.displayName = "Burris® FastFire™ reflex sight"
att.displayNameShort = "Backup"
att.aimPos = {"BackupReflexPos", "BackupReflexAng"}
-- att.aimPos = {"AimPos", "AimAng"}
-- att.FOVModifier = 15
-- att.isSight = true
att.colorType = CustomizableWeaponry.colorableParts.COLOR_TYPE_SIGHT
-- att.statModifiers = {}

if CLIENT then
	att.displayIcon = surface.GetTextureID("entities/md_small_reflex")
	att.description = {
		{t = "Provides a bright reticle to ease aiming.", c = CustomizableWeaponry.textColors.POSITIVE},
		{t = "Also provides great CQB solution for scopes with zoom.", c = CustomizableWeaponry.textColors.POSITIVE},
		-- {t = "Can be very useful if your iron sights get broken.", c = CustomizableWeaponry.textColors.VPOSITIVE},
		{t = "Double tap +use key while aiming to use.", c = CustomizableWeaponry.textColors.REGULAR},
	}

	att.reticle = "qq_sprites/bigdot"
	att._reticleSize = 3
	
	local glassMat = Material("models/qq_rec/burris/glass")
	local glassCol = Vector(0,0,0)
	
	local isAiming, freeze, rc, attachmEnt, isScopePos, EA, retPos, retNorm, retAng
	
	function att:elementRender()
		if not self.ActiveAttachments[att.name] then return end
		
		local currentPrimarySight = self:getActiveAttachmentInCategory(self.primarySightCategory or 1)
		if self.lastPrimarySight != currentPrimarySight then
			self.SightBackUpPos = self[att.aimPos[1]]
			self.SightBackUpAng = self[att.aimPos[2]]
			
			if not CustomizableWeaponry.sights[currentPrimarySight] then
				self.ActualSightPos = self.AimPos_Orig
				self.ActualSightAng = self.AimAng_Orig
			end
		end
		self.lastPrimarySight = currentPrimarySight
		
		isAiming = self:isAiming()
		freeze = GetConVarNumber("cw_kk_freeze_reticles") != 0
		
		rc = self:getSightColor(att.name)
		glassCol.x = 1 - (rc.r / 255)
		glassCol.y = 1 - (rc.g / 255)
		glassCol.z = 1 - (rc.b / 255)
		
		glassMat:SetVector("$color2", glassCol)
		glassMat:SetVector("$envmaptint", glassCol)
		
		attachmEnt = self.AttachmentModelsVM[att.name].ent
		isScopePos = (self.AimPos == self[att.aimPos[1]] and self.AimAng == self[att.aimPos[2]])
		
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
		
		attachmEnt:SetModel("models/c_docter_stencil.mdl")
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
				render.DrawQuadEasy(retPos, retNorm, att._reticleSize, att._reticleSize, rc, retAng)
			render.CullMode(MATERIAL_CULLMODE_CCW)
		cam.IgnoreZ(false)
		
		attachmEnt:SetModel("models/c_docter.mdl")
		attachmEnt:SetBodygroup(1,1)
		
		render.SetStencilEnable(false)
	end
	
	function att:attachFunc()
		if self.AttachmentModelsVM.md_backup_reflex_rail then
			self.AttachmentModelsVM.md_backup_reflex_rail.active = true
		end		
		
		self.SightBackUpPos = self[att.aimPos[1]]
		self.SightBackUpAng = self[att.aimPos[2]]	
		
		local sight = CustomizableWeaponry.sights[self:getActiveAttachmentInCategory(self.primarySightCategory or 1)]
		if sight then
			self.ActualSightPos = self[sight.aimPos[1]]
			self.ActualSightAng = self[sight.aimPos[2]]
		else
			self.ActualSightPos = self.AimPos_Orig
			self.ActualSightAng = self.AimAng_Orig
		end
	end
	
	function att:detachFunc()
		if self.AttachmentModelsVM.md_backup_reflex_rail then
			self.AttachmentModelsVM.md_backup_reflex_rail.active = false
		end
		
		if not self.BackupSights then
			self.BackupSights = {}
		end
		
		self.primarySightCategory = self.primarySightCategory or 1
		local psc = self.primarySightCategory
		
		local currentPrimarySight = self:getActiveAttachmentInCategory(psc)
		
		// restore current aimpos
		local sight = CustomizableWeaponry.sights[currentPrimarySight]
		if sight then
			self.AimPos = self[sight.aimPos[1]]
			self.AimAng = self[sight.aimPos[2]]
		else
			self.AimPos = self.AimPos_Orig
			self.AimAng = self.AimAng_Orig
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
end

CustomizableWeaponry:registerAttachment(att)