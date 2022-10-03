
local tab = {}
tab.sight = "md_fas2_holo"
tab.func = function(self,rc)
	local rcAlpha = 255 * (self.KKIRAlpha or 1)
	
	surface.SetDrawColor(rc.r, rc.g, rc.b, rcAlpha)
	surface.SetTexture(surface.GetTextureID("models/qq_rec/scifi/holo_bg1"))
	surface.DrawTexturedRect(-256, -256, 1024, 1024)
	surface.SetDrawColor(255, 255, 255, rcAlpha)
	surface.SetTexture(surface.GetTextureID("models/qq_rec/scifi/holo_fg2_white_3x"))
	surface.DrawTexturedRect(0, 0, 512, 512)
	
	local hp = self.Owner:Health()
	local hpp = math.Clamp((hp / 100), 0, 1)
		
	surface.SetFont( "CW_HUD36" )
	surface.SetTextPos(100, 110)
	surface.SetTextColor(rc.r,rc.g,rc.b,rcAlpha)
	surface.DrawText(hpp*100)
	
	surface.SetTextPos(100, 110)
	surface.SetTextColor(255,255,255,rcAlpha-(rcAlpha*hpp))
	surface.DrawText(hpp*100)
	
	local clipSize = self.Primary.ClipSize
	local clip = self:Clip1()
	local clipp = math.Clamp((clip/clipSize), 0, 1)
	
	surface.SetFont( "CW_HUD36" )
	surface.SetTextPos(410 - surface.GetTextSize(clip), 110) 
	surface.SetTextColor(rc.r,rc.g,rc.b,rcAlpha)
	surface.DrawText(clip)
	
	surface.SetTextPos(410 - surface.GetTextSize(clip), 110) 
	surface.SetTextColor(255,255,255,rcAlpha-(rcAlpha*clipp))
	surface.DrawText(clip)
					
	local txt
	surface.SetFont( "CW_HUD28" )
	surface.SetTextColor(rc.r,rc.g,rc.b,rcAlpha)
				
	if self.dt.M203Active and self.M203Chamber and self:isAiming() then
		txt = "SINGLE M203"
	else
		txt = self.FireModeDisplay
	end
	surface.SetTextPos(256 - (surface.GetTextSize(txt) / 2), 420) 
	surface.DrawText(txt)
	
	if self.md_fas2_holo_target then
		surface.SetDrawColor(rc.r, rc.g, rc.b, rcAlpha)
		surface.SetTexture(surface.GetTextureID("models/qq_rec/scifi/holo_mg"))
		surface.DrawTexturedRect(128, 128, 256, 256)
		surface.SetTexture(surface.GetTextureID("models/qq_rec/scifi/holo_mg2"))
		surface.DrawTexturedRect(128, 128, 256, 256)
		surface.SetTexture(surface.GetTextureID("models/qq_rec/scifi/holo_mg3"))
		surface.DrawTexturedRect(128, 128, 256, 256)
		
		surface.SetTextColor(255,255,255,rcAlpha)
	else
		surface.SetTextColor(rc.r,rc.g,rc.b,rcAlpha)
	end
	
	if not self.md_fas2_holo_dist then
		txt = "RANGEFINDER ERROR"
	else
		txt = self.md_fas2_holo_dist .. "m"
	end
	surface.SetTextPos(256 - (surface.GetTextSize(txt) / 2), 364) 
	surface.DrawText(txt)
end		
CustomizableWeaponry_KK_Magnifier_AddPrimarySight(tab)
