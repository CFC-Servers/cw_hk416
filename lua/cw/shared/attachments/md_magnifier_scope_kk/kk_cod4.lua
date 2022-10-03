
local tab = {}
tab.sight = "md_cod4_reflex"
tab.func = function(self,rc)
	local rcAlpha = 255 * (self.KKIRAlpha or 1)
	
	surface.SetDrawColor(rc.r, rc.g, rc.b, rcAlpha - 15)
	surface.SetTexture(surface.GetTextureID("qq_sprites/circledot"))
	surface.DrawTexturedRect(192, 192, 128, 128)
end
CustomizableWeaponry_KK_Magnifier_AddPrimarySight(tab)

local tab = {}
tab.sight = "md_cod4_eotech"
tab.func = function(self,rc)
	local rcAlpha = 255 * (self.KKIRAlpha or 1)
	
	surface.SetDrawColor(rc.r, rc.g, rc.b, rcAlpha - 55 + math.random(45))
	surface.SetTexture(surface.GetTextureID("qq_sprites/c128"))
	surface.DrawTexturedRect(160, 160, 192, 192)		
end		
CustomizableWeaponry_KK_Magnifier_AddPrimarySight(tab)

tab.sight = "md_cod4_eotech_v2"
CustomizableWeaponry_KK_Magnifier_AddPrimarySight(tab)

local tab = {}
tab.sight = "md_cod4_aimpoint"
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

tab.sight = "md_cod4_aimpoint_v2"
CustomizableWeaponry_KK_Magnifier_AddPrimarySight(tab)
