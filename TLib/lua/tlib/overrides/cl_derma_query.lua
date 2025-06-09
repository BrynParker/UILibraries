TLib.Font("Derma_Query", 18)
TLib.Font("Derma_Query_Button", 14)


function Derma_Query( strText, strTitle, ... )

	local Window = vgui.Create( "TLib.Frame" )
	Window:SetTitle( strTitle or "Message Title (First Parameter)" )
	Window:SetDraggable( false )
	Window:ShowCloseButton( false )
	Window:SetBackgroundBlur( true )
	Window:SetDrawOnTop( true )
	Window:ShowReloadButton( false )

	local InnerPanel = vgui.Create( "TLib.Panel", Window )
    InnerPanel:Dock(FILL)
    InnerPanel:RoundCorners(true,true,false,false)
	-- InnerPanel:SetPaintBackground( false )

    local Text = vgui.Create("RichText", InnerPanel)
    Text:Dock(FILL)
    Text:DockMargin(5,5,5,5)
    Text:InsertColorChange( 255, 255, 255, 255 )
    Text:AppendText( strText or "Message Text (Second Parameter)" )
    Text:SetVerticalScrollbarEnabled( false )
    Text.PerformLayout = function(self)
        self:SetFontInternal( "TLib.Font.Derma_Query" )
    end

	local ButtonPanel = vgui.Create( "TLib.Panel", Window )
	ButtonPanel:SetTall( 30 )
    ButtonPanel:RoundCorners(false,false,true,true)

	-- Loop through all the options and create buttons for them.
	local NumOptions = 0
	local x = 5

	for k=1, 8, 2 do

		local Text = select( k, ... )
		if Text == nil then break end

		local Func = select( k+1, ... ) or function() end

		local Button = vgui.Create( "TLib.Button", ButtonPanel )
		Button:SetText( Text )
        Button:Dock(LEFT)
        Button:DockMargin(5,5,5,5)
        Button:SetFont("TLib.Font.Derma_Query_Button")
		-- Button:SetWide( Button:GetWide() + 20 )
		Button.DoClick = function() Window:Close() Func() end

		x = x + Button:GetWide() + 5

		NumOptions = NumOptions + 1

        Button:SetWide(120)

	end

	local w, h = Text:GetSize()

	w = math.max( w, ButtonPanel:GetWide() )

	Window:SetSize( w + 300, h + 200)
	Window:Center()

	InnerPanel:StretchToParent( 5, 25, 5, 45 )

	Text:StretchToParent( 5, 5, 5, 5 )

    ButtonPanel:Dock(BOTTOM)

	Window:MakePopup()
	Window:DoModal()


	if ( NumOptions == 0 ) then

		Window:Close()
		Error( "Derma_Query: Created Query with no Options!?" )
		return nil

	end

	return Window

end