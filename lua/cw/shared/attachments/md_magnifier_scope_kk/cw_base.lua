
local tab = {}
tab.sight = "md_eotech"
tab.func = function(self,rc)
	local rcAlpha = 255 * (self.KKIRAlpha or 1)
	
	surface.SetDrawColor(rc.r, rc.g, rc.b, rcAlpha - 55 + math.random(45))
	surface.SetTexture(surface.GetTextureID("models/qq_rec/fas2_2015/eotech_reticle"))
	surface.DrawTexturedRect(184, 184, 144, 144)
end
CustomizableWeaponry_KK_Magnifier_AddPrimarySight(tab)

local tab = {}
tab.sight = "md_microt1"
tab.func = function(self,rc)
	local rcAlpha = 255 * (self.KKIRAlpha or 1)
	
	surface.SetDrawColor(rc.r, rc.g, rc.b, rcAlpha - 15)
	surface.SetTexture(surface.GetTextureID("qq_sprites/bigdot"))
	surface.DrawTexturedRect(208, 208, 96, 96)
	surface.SetDrawColor(255, 255, 255, rcAlpha - 105)
	surface.SetTexture(surface.GetTextureID("qq_sprites/bigdot"))
	surface.DrawTexturedRect(232, 232, 48, 48)
end
CustomizableWeaponry_KK_Magnifier_AddPrimarySight(tab)

local tab = {}
tab.sight = "md_aimpoint"
tab.func = function(self,rc)
	local rcAlpha = 255 * (self.KKIRAlpha or 1)
	
	surface.SetDrawColor(rc.r, rc.g, rc.b, rcAlpha - 15)
	surface.SetTexture(surface.GetTextureID("qq_sprites/bigdot"))
	surface.DrawTexturedRect(208, 208, 96, 96)
	surface.SetDrawColor(255, 255, 255, rcAlpha - 105)
	surface.SetTexture(surface.GetTextureID("qq_sprites/bigdot"))
	surface.DrawTexturedRect(232, 232, 48, 48)	
end		
CustomizableWeaponry_KK_Magnifier_AddPrimarySight(tab)
