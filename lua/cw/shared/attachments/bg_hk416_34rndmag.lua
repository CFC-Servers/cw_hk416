local att = {}
att.name = "bg_hk416_34rndmag"
att.displayName = "Cool looking mag"
att.displayNameShort = "PMAG"
att.isBG = true

att.statModifiers = {
	ReloadSpeedMult = -0.05,
	OverallMouseSensMult = -0.01
}

if CLIENT then
	att.displayIcon = surface.GetTextureID("entities/bg_hk416_34rndmag")
	att.description = {[1] = {t = "Increases mag size to 34 rounds.", c = CustomizableWeaponry.textColors.POSITIVE}}
end

function att:attachFunc()
	self:setBodygroup(self.MagBGs.main, self.MagBGs.round34)
	self:unloadWeapon()
	self.Primary.ClipSize = 34
	self.Primary.ClipSize_Orig = 34
end

function att:detachFunc()
	self:setBodygroup(self.MagBGs.main, self.MagBGs.regular)
	self:unloadWeapon()
	self.Primary.ClipSize = self.Primary.ClipSize_ORIG_REAL
	self.Primary.ClipSize_Orig = self.Primary.ClipSize_ORIG_REAL
end

CustomizableWeaponry:registerAttachment(att)