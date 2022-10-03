local att = {}
att.name = "bg_hk416_longbarrel"
att.displayName = "Long barrel"
att.displayNameShort = "Long"
att.isBG = true

att.statModifiers = {
	DamageMult = 0.1,
	AimSpreadMult = -0.1,
	RecoilMult = 0.1,
	OverallMouseSensMult = -0.1
}

if CLIENT then
	att.displayIcon = surface.GetTextureID("atts/ar15longbarrel")
	att.description = {[1] = {t = "A barrel for long range engagements.", c = CustomizableWeaponry.textColors.REGULAR}}
end

function att:attachFunc()
	self.MuzzlePosMod = self.MuzzlePosModLong
	self:updateSoundTo("CW_AR15_LONGBARREL_FIRE", CustomizableWeaponry.sounds.UNSUPPRESSED)
	self:updateSoundTo("CW_AR15_LONGBARREL_FIRE_SUPPRESSED", CustomizableWeaponry.sounds.SUPPRESSED)
end

function att:detachFunc()
	self.MuzzlePosMod = self.MuzzlePosModDef
	self:restoreSound()
end

CustomizableWeaponry:registerAttachment(att)