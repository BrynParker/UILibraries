function Derma_StringRequest( strTitle, strText, strDefaultText, fnEnter, fnCancel, strButtonText, strButtonCancelText )

	local Window = vgui.Create( "TLib.Frame" )
	Window:SetTitle( strTitle or "Message Title (First Parameter)" )
	Window:SetDraggable( false )
	Window:ShowCloseButton( false )
	Window:SetBackgroundBlur( true )
	Window:SetDrawOnTop( true )

	local InnerPanel = vgui.Create( "TLib.TitlePanel", Window )
    InnerPanel:SetupDock(FILL, 8,8,8,8)
    InnerPanel:SetupTitle(strText or "Message Text (Second Parameter)", true)


	local TextEntry = vgui.Create( "TLib.TextEntry", InnerPanel )
	TextEntry:SetText( strDefaultText or "" )
    TextEntry:SetupDock(FILL, 5,5,5,5)
	TextEntry.OnEnter = function() Window:Close() fnEnter( TextEntry:GetValue() ) end

	local ButtonPanel = vgui.Create( "TLib.Panel", Window )
    ButtonPanel:SetupDock(BOTTOM, 8,8,8,8)
	ButtonPanel:SetTall( 40 )

	local Button = vgui.Create( "TLib.Button", ButtonPanel )
	Button:SetText( strButtonText or "OK" )
	Button:SizeToContents()
    Button:SetupDock(LEFT, 5,5,5,5)
	Button.DoClick = function() Window:Close() fnEnter( TextEntry:GetValue() ) end

	local ButtonCancel = vgui.Create( "TLib.Button", ButtonPanel )
	ButtonCancel:SetText( strButtonCancelText or "Cancel" )
	ButtonCancel:SizeToContents()
    ButtonCancel:SetupDock(LEFT, 5,5,5,5)

	ButtonCancel.DoClick = function() Window:Close() if ( fnCancel ) then fnCancel( TextEntry:GetValue() ) end end
	ButtonCancel:MoveRightOf( Button, 5 )

	ButtonPanel:SetWide( Button:GetWide() + 5 + ButtonCancel:GetWide() + 10 )


	Window:SetSize( 400, 190)
	Window:Center()

	-- InnerPanel:StretchToParent( 5, 25, 5, 45 )
    InnerPanel:Dock(FILL)


	TextEntry:StretchToParent( 5, nil, 5, nil )
	TextEntry:AlignBottom( 5 )

	TextEntry:RequestFocus()
	TextEntry:SelectAllText( true )

	ButtonPanel:CenterHorizontal()
	ButtonPanel:AlignBottom( 8 )

	Window:MakePopup()
	Window:DoModal()

	return Window

end
