local att = {}
att.name = "bg_hk416_silencer"
att.displayName = "Suppressor"
att.displayNameShort = "Silencer"
att.isSuppressor = true

att.statModifiers = {
	OverallMouseSensMult = -0.05,
	RecoilMult = -0.05,
}

if CLIENT then
	att.displayIcon = surface.GetTextureID("atts/saker")
	att.description = {[1] = {t = "Decreases firing noise.", c = CustomizableWeaponry.textColors.POSITIVE}}
end

function att:attachFunc()
	self.dt.Suppressed = true
end

function att:detachFunc()
	self.dt.Suppressed = false
end

CustomizableWeaponry:registerAttachment(att)