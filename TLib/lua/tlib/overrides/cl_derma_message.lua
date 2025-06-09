TLib.Font("DermaMessage", 18)

function Derma_Message( strText, strTitle, strButtonText )

	local Window = vgui.Create( "TLib.Frame" )
	Window:SetTitle( strTitle or "Message" )
	Window:SetDraggable( false )
	Window:ShowCloseButton( false )
	Window:SetBackgroundBlur( true )
	Window:SetDrawOnTop( true )

	local InnerPanel = vgui.Create( "TLib.Panel", Window )
    InnerPanel:SetupDock(FILL, 8,8,8,8)

    local Text = vgui.Create("RichText", InnerPanel)
    Text:Dock(FILL)
    Text:AppendText( strText or "Message Text" )
    Text:SetFontInternal("TLib.Font.DermaMessage")
    Text:SetVerticalScrollbarEnabled(false)
    Text:SetWrap(true)
    Text.PerformLayout = function(self)
        self:SetFontInternal("TLib.Font.DermaMessage")
    end

	local ButtonPanel = vgui.Create( "TLib.Panel", Window )
    ButtonPanel:SetupDock(BOTTOM, 8,8,8,8)
	ButtonPanel:SetTall( 30 )

	local Button = vgui.Create( "TLib.Button", ButtonPanel )
	Button:SetText( strButtonText or "OK" )
	Button:SizeToContents()
    Button:SetupDock(FILL, 5,5,5,5)
	Button.DoClick = function() Window:Close() end

	ButtonPanel:SetWide( Button:GetWide() + 10 )

	local w, h = Text:GetSize()

	Window:SetSize( 350, 190 )
	Window:Center()

	Text:StretchToParent( 5, 5, 5, 5 )

	ButtonPanel:CenterHorizontal()
	ButtonPanel:AlignBottom( 8 )

	Window:MakePopup()
	Window:DoModal()
	return Window

end