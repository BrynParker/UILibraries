
local PANEL = {}

AccessorFunc( PANEL, "m_fAnimSpeed",	"AnimSpeed" )
AccessorFunc( PANEL, "Entity",			"Entity" )
AccessorFunc( PANEL, "vCamPos",			"CamPos" )
AccessorFunc( PANEL, "fFOV",			"FOV" )
AccessorFunc( PANEL, "vLookatPos",		"LookAt" )
AccessorFunc( PANEL, "aLookAngle",		"LookAng" )
AccessorFunc( PANEL, "colAmbientLight",	"AmbientLight" )
AccessorFunc( PANEL, "colColor",		"Color" )
AccessorFunc( PANEL, "bAnimated",		"Animated" )

function PANEL:Init()

	self.Entity = nil
	self.LastPaint = 0
	self.DirectionalLight = {}
	self.FarZ = 4096
	
	self:SetFOV(50)
    self:SetLookAt(Vector(0, 0, 40))
	self:SetCamPos( Vector( 50, 50, 50 ) )

	self:SetText( "" )
	self:SetAnimSpeed( 0.5 )
	self:SetAnimated( false )

	self:SetAmbientLight( Color( 50, 50, 50 ) )

	self:SetDirectionalLight( BOX_TOP, Color( 255, 255, 255 ) )
	self:SetDirectionalLight( BOX_FRONT, Color( 255, 255, 255 ) )

	self:SetColor( Color( 255, 255, 255, 255 ) )
end


function PANEL:SetupDock(pos, left, top, right, bottom)
	self:Dock(pos)
	self:DockMargin(left or 0, top or 0, right or 0, bottom or 0)
end

function PANEL:SetupTooltip(text)
	self:SetTooltip(text)
	self:SetTooltipPanelOverride("TLib.Tooltip")
end


function PANEL:SetDirectionalLight( iDirection, color )
	self.DirectionalLight[ iDirection ] = color
end

function PANEL:SetModel( strModelName )
	if ( IsValid( self.Entity ) ) then
		self.Entity:Remove()
		self.Entity = nil
	end

	if ( !ClientsideModel ) then return end

	self.Entity = ClientsideModel( strModelName, RENDERGROUP_OTHER )
	if ( !IsValid( self.Entity ) ) then return end

	self.Entity:SetNoDraw( true )
	self.Entity:SetIK( false )

	local iSeq = self.Entity:LookupSequence( "walk_all" )
	if ( iSeq <= 0 ) then iSeq = self.Entity:LookupSequence( "WalkUnarmed_all" ) end
	if ( iSeq <= 0 ) then iSeq = self.Entity:LookupSequence( "walk_all_moderate" ) end

	if ( iSeq > 0 ) then self.Entity:ResetSequence( iSeq ) end
end

function PANEL:GetModel()

	if ( !IsValid( self.Entity ) ) then return end

	return self.Entity:GetModel()
end

function PANEL:DrawModel()

	local curparent = self
	local leftx, topy = self:LocalToScreen( 0, 0 )
	local rightx, bottomy = self:LocalToScreen( self:GetWide(), self:GetTall() )
	while ( curparent:GetParent() != nil ) do
		curparent = curparent:GetParent()

		local x1, y1 = curparent:LocalToScreen( 0, 0 )
		local x2, y2 = curparent:LocalToScreen( curparent:GetWide(), curparent:GetTall() )

		leftx = math.max( leftx, x1 )
		topy = math.max( topy, y1 )
		rightx = math.min( rightx, x2 )
		bottomy = math.min( bottomy, y2 )
		previous = curparent
	end

	render.SetScissorRect( leftx, topy, rightx, bottomy, true )

	local ret = self:PreDrawModel( self.Entity )
	if ( ret != false ) then
		self.Entity:DrawModel()
		self:PostDrawModel( self.Entity )
	end

	render.SetScissorRect( 0, 0, 0, 0, false )

end

function PANEL:PreDrawModel( ent )
	return true
end

function PANEL:PostDrawModel( ent )

end

function PANEL:Paint( w, h )

	if ( !IsValid( self.Entity ) ) then return end

	local x, y = self:LocalToScreen( 0, 0 )

	-- self:LayoutEntity( self.Entity )

	local ang = self.aLookAngle
	if ( !ang ) then
		ang = ( self.vLookatPos - self.vCamPos ):Angle()
	end

	cam.Start3D( self.vCamPos, ang, self.fFOV, x, y, w, h, 5, self.FarZ )

	render.SuppressEngineLighting( true )
	render.SetLightingOrigin( self.Entity:GetPos() )
	render.ResetModelLighting( self.colAmbientLight.r / 255, self.colAmbientLight.g / 255, self.colAmbientLight.b / 255 )
	render.SetColorModulation( self.colColor.r / 255, self.colColor.g / 255, self.colColor.b / 255 )
	render.SetBlend( ( self:GetAlpha() / 255 ) * ( self.colColor.a / 255 ) ) -- * surface.GetAlphaMultiplier()

	for i = 0, 6 do
		local col = self.DirectionalLight[ i ]
		if ( col ) then
			render.SetModelLighting( i, col.r / 255, col.g / 255, col.b / 255 )
		end
	end

	self:DrawModel()

	render.SuppressEngineLighting( false )
	cam.End3D()

	self.LastPaint = RealTime()
end

function PANEL:RunAnimation()
	self.Entity:FrameAdvance( ( RealTime() - self.LastPaint ) * self.m_fAnimSpeed )
end

function PANEL:StartScene( name )

	if ( IsValid( self.Scene ) ) then
		self.Scene:Remove()
	end

	self.Scene = ClientsideScene( name, self.Entity )
end

function PANEL:OnRemove()
	if ( IsValid( self.Entity ) ) then
		self.Entity:Remove()
	end
end

function PANEL:RotateModel( speed )
	self:SetCamPos( Vector( 50, 50, 50 ) )
	self:SetLookAt( Vector( 0, 0, 40 ) )
	self:SetFOV( 50 )
	self:SetAnimated( true )
	self:SetAnimSpeed( speed or 0.5 )
end

	function PANEL:Think()
		local pX, pY = self:GetParent():GetPos()
		local thisX, thisY, thisW, thisH = self:GetBounds()
		thisX = thisX + pX
		thisY = thisY + pY
		if gui.MouseX() < thisX or gui.MouseX() > thisX + thisW or gui.MouseY() < thisY or gui.MouseY() > thisY + thisH then
			if self.Rotating and not input.IsMouseDown( MOUSE_LEFT ) then
				self.Rotating = false 
			end
			if self.Panning and not input.IsMouseDown( MOUSE_RIGHT ) then
				self.Panning = false
			end
		end
	end
	function PANEL:LayoutEntity( ent )
		if ( self.bAnimated ) then
			self:RunAnimation()
		end

		local pX, pY = self:GetParent():GetPos()
		local thisX, thisY, thisW, thisH = self:GetBounds()
		thisX = pX + thisX
		thisY = pY + thisY

		if self.Rotating then
			local angDiff = gui.MouseX() - self.InitPos
			self.CurrAng = self.CurrAng + angDiff
			if self.CurrAng >= 360 then
				self.CurrAng = self.CurrAng - 360
			end
			if self.CurrAng < 0 then
				self.CurrAng = self.CurrAng + 360
			end

			local fovDiff = gui.MouseY() - self.InitFOV
			self.CurrFOV = self.CurrFOV + fovDiff
			self.CurrFOV = math.Clamp( self.CurrFOV, 10, 120 )

			self.InitPos = gui.MouseX()
			self.InitFOV = gui.MouseY()
		end

		-- if self.Panning then
		-- 	local xDiff = gui.MouseX() - self.InitCamX
		-- 	local yDiff = gui.MouseY() - self.InitCamY

		-- 	self.CamX = math.Clamp( self.CamX + gui.MouseX() - self.InitCamX, -80, 80 )
		-- 	self.CamY = math.Clamp( self.CamY + gui.MouseY() - self.InitCamY, -120, 120 )

		-- 	self.InitCamX = gui.MouseX()
		-- 	self.InitCamY = gui.MouseY()
		-- end

		ent:SetEyeTarget( ent:EyePos() + ent:GetForward() * 500 )
		ent:SetPos( Vector( self.CamX / 2, self.CamX / -2, self.CamY / 2 ) )
		ent:SetAngles( Angle( 0, self.CurrAng, 0 ) )
		self:SetFOV( self.CurrFOV )

	end
	function PANEL:PostDrawModel( ent )
		for k,v in pairs( ent:GetBodyGroups() ) do
			ent:SetBodygroup( k - 1, LocalPlayer():GetBodygroup( k - 1 ) )
		end
	end
	function PANEL:OnMousePressed( key )
		if key == MOUSE_LEFT then
			self.Rotating = true
			self.InitPos = gui.MouseX()
			self.InitFOV = gui.MouseY()
		end
		-- if key == MOUSE_RIGHT then
		-- 	self.Panning = true
		-- 	self.InitCamX = gui.MouseX()
		-- 	self.InitCamY = gui.MouseY()
		-- end
		if key == MOUSE_WHEEL_UP then
			self.CurrFOV = 55
			self.CurrAng = 0
			self.CamX = 0
			self.CamY = 0
		end
	end
	function PANEL:OnMouseReleased( key )
		if key == MOUSE_LEFT then
			self.Rotating = false
		end
		-- if key == MOUSE_RIGHT then
		-- 	self.Panning = false
		-- end
	end
	function PANEL:Think()
		if input.IsKeyDown( KEY_R ) then
			self.CurrFOV = 40
			self.CurrAng = 70
			self.CamX = 0
			self.CamY = 0
		end
	end

vgui.Register("TLib.ModelPanel", PANEL, "DButton")