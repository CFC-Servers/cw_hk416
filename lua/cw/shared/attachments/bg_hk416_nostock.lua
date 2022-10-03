local att = {}
att.name = "bg_hk416_nostock"
att.displayName = "No stock at all"
att.displayNameShort = "No stock"
att.isBG = true

att.statModifiers = {
	RecoilMult = 0.5,
	OverallMouseSensMult = 0.5,
	DrawSpeedMult = 0.25
}

if CLIENT then
	att.displayIcon = surface.GetTextureID("entities/bg_hk416_nostock")
end

function att:attachFunc()
	self:setBodygroup(self.StockBGs.main, self.StockBGs.none)
	if self.WMEnt then
		self.WMEnt:SetBodygroup(self.StockBGs.main, self.StockBGs.none)
	end
end

function att:detachFunc()
	self:setBodygroup(self.StockBGs.main, self.StockBGs.regular)
	if self.WMEnt then
		self.WMEnt:SetBodygroup(self.StockBGs.main, self.StockBGs.regular)
	end
end

CustomizableWeaponry:registerAttachment(att)