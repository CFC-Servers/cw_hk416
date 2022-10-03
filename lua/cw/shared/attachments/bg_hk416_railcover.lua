local att = {}
att.name = "bg_hk416_railcover"
att.displayName = "Rail Covers"
att.displayNameShort = "Covers"
att.isBG = true

att.statModifiers = {
	RecoilMult = -0.15,
	OverallMouseSensMult = -0.05
}

if CLIENT then
	att.displayIcon = surface.GetTextureID("entities/bg_hk416_railcover")
	att.description = {[1] = {t = "Add some extra weight to foregrip.", c = CustomizableWeaponry.textColors.REGULAR}}
end

function att:attachFunc()
	self:setBodygroup(self.ForegripBGs.main, self.ForegripBGs.covered)
	if self.WMEnt then
		self.WMEnt:SetBodygroup(self.ForegripBGs.main, self.ForegripBGs.covered)
	end
end

function att:detachFunc()
	self:setBodygroup(self.ForegripBGs.main, self.ForegripBGs.regular)
	if self.WMEnt then
		self.WMEnt:SetBodygroup(self.ForegripBGs.main, self.ForegripBGs.regular)
	end
end

CustomizableWeaponry:registerAttachment(att)