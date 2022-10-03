local att = {}
att.name = "bg_hk416_paint2"
att.displayName = "Salad-Green Paint"
att.displayNameShort = "Salad"
att.isBG = true

att.statModifiers = {}

if CLIENT then
	att.displayIcon = surface.GetTextureID("entities/bg_hk416_paint2")
	att.description = {[1] = {t = "Salad-green finish for your weapon.", c = CustomizableWeaponry.textColors.NEGATIVE}}
end

function att:attachFunc()
	if SERVER then
		return
	end

	if self.CW_VM then
		self.CW_VM:SetSkin(2)
	end
	if self.WMEnt then
		self.WMEnt:SetSkin(2)
	end
end

function att:detachFunc()
	if SERVER then
		return
	end

	if self.CW_VM then
		self.CW_VM:SetSkin(0)
	end
	if self.WMEnt then
		self.WMEnt:SetSkin(0)
	end
end

CustomizableWeaponry:registerAttachment(att)