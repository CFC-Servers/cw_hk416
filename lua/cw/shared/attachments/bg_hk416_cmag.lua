local att = {}
att.name = "bg_hk416_cmag"
att.displayName = "Beta C-Mag"
att.displayNameShort = "CMAG"
att.isBG = true

att.statModifiers = {
	ReloadSpeedMult = -0.3,
	OverallMouseSensMult = -0.1
}

if CLIENT then
	att.displayIcon = surface.GetTextureID("entities/bg_hk416_cmag")
	att.description = {[1] = {t = "Increases mag size to 100 rounds.", c = CustomizableWeaponry.textColors.POSITIVE}}
end

function att:attachFunc()
	self:setBodygroup(self.MagBGs.main, self.MagBGs.round100)
	self:unloadWeapon()
	
	-- if self.ActiveAttachments.md_foregrip or self.ActiveAttachments.md_m203 then
		-- self.ForegripOverride = false
	-- else
		-- self.ForegripOverride = true
	-- end
	
	-- self.ForegripParent = "bg_hk416_cmag"
	
	self.Primary.ClipSize = 100
	self.Primary.ClipSize_Orig = 100
end

function att:detachFunc()
	self:setBodygroup(self.MagBGs.main, self.MagBGs.regular)
	self:unloadWeapon()
	self.ForegripOverride = false
	self.Primary.ClipSize = self.Primary.ClipSize_ORIG_REAL
	self.Primary.ClipSize_Orig = self.Primary.ClipSize_ORIG_REAL
end

CustomizableWeaponry:registerAttachment(att)