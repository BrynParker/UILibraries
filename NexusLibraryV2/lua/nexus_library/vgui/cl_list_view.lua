local PANEL = {}
function PANEL:Init()
	self:SetTextInset(5, 0)
end

function PANEL:UpdateColours(skin)
	if (self:GetParent():IsLineSelected()) then return self:SetTextStyleColor(skin.Colours.Label.Bright) end
	return self:SetTextStyleColor(skin.Colours.Label.Dark)
end

function PANEL:IsWithin(mx, my)
	local x, y, w, h = 0, 0, self:GetWide(), self:GetTall()

	if mx and my then
		mx = mx
		my = my
	else
		mx, my = input.GetCursorPos()
	end

	local lx, ly = self:LocalToScreen(0, 0)
	if mx > lx and mx < lx+w and my > ly and my < ly+h then
		return true
	end

	return false
end
vgui.Register("Nexus:ListViewLabel", PANEL, "DLabel")

local PANEL = {}
Derma_Hook(PANEL, "Paint", "Paint", "ListViewLine")
Derma_Hook(PANEL, "ApplySchemeSettings", "Scheme", "ListViewLine")
Derma_Hook(PANEL, "PerformLayout", "Layout", "ListViewLine")
AccessorFunc(PANEL, "m_iID", "ID")
AccessorFunc(PANEL, "m_pListView", "ListView")
AccessorFunc(PANEL, "m_bAlt", "AltLine")

function PANEL:Init()
	self:SetSelectable(true)
	self:SetMouseInputEnabled(true)

	self.Columns = {}
	self.Data = {}
end

function PANEL:OnSelect() end
function PANEL:OnRightClick() end

function PANEL:OnMousePressed(mcode)
	if (mcode == MOUSE_RIGHT) then
		if (!self:IsLineSelected()) then
			self:GetListView():OnClickLine(self, true)
			self:OnSelect()
		end

		self:GetListView():OnRowRightClick(self:GetID(), self)
		self:OnRightClick()

		return
	end

	self:GetListView():OnClickLine(self, true)
	self:OnSelect()
end

function PANEL:OnCursorMoved()
	if (input.IsMouseDown(MOUSE_LEFT)) then
		self:GetListView():OnClickLine(self)
	end
end

function PANEL:SetSelected(b)
	self.m_bSelected = b

	for id, column in pairs(self.Columns) do
		column:ApplySchemeSettings()
	end
end

function PANEL:IsLineSelected()
	return self.m_bSelected
end

function PANEL:SetColumnText(i, strText)
	if (type(strText ) == "Panel") then
		if (IsValid(self.Columns[i])) then self.Columns[i]:Remove() end

		strText:SetParent(self)
		self.Columns[i] = strText
		self.Columns[i].Value = strText

		return
	end

	if (!IsValid(self.Columns[i])) then
		self.Columns[i] = vgui.Create("Nexus:ListViewLabel", self)
		self.Columns[i]:SetMouseInputEnabled(false)

		self.Columns[i].Think = nil
	end

	self.Columns[i]:SetText(tostring(strText))
	self.Columns[i].Value = strText

	return self.Columns[i]
end
PANEL.SetValue = PANEL.SetColumnText

function PANEL:GetColumnText(i)
	if (!self.Columns[i]) then return "" end
	return self.Columns[i].Value
end
PANEL.GetValue = PANEL.GetColumnText

function PANEL:SetSortValue(i, data)
	self.Data[i] = data
end

function PANEL:GetSortValue(i)
	return self.Data[i]
end

function PANEL:DataLayout(ListView)
	self:ApplySchemeSettings()

	local height = self:GetTall()
	local x = 0
	for k, Column in pairs(self.Columns) do
		local w = ListView:ColumnWidth(k)
		Column:SetPos(x, 0)
		Column:SetSize(w, height)
		x = x + w
	end
end

vgui.Register("Nexus:ListView_Line", PANEL, "Panel")

local PANEL = {}
AccessorFunc(PANEL, "m_bDirty", "Dirty", FORCE_BOOL)
AccessorFunc(PANEL, "m_bSortable", "Sortable", FORCE_BOOL)
AccessorFunc(PANEL, "m_iHeaderHeight", "HeaderHeight")
AccessorFunc(PANEL, "m_iDataHeight", "DataHeight")
AccessorFunc(PANEL, "m_bMultiSelect", "MultiSelect")
AccessorFunc(PANEL, "m_bHideHeaders", "HideHeaders")

Derma_Hook(PANEL, "Paint", "Paint", "ListView")

function PANEL:Init()
    self.margin = Nexus:Scale(10)

	self:SetSortable(true)
	self:SetMouseInputEnabled(true)
	self:SetMultiSelect(true)
	self:SetHideHeaders(false)

	self:SetPaintBackground(true)
	self:SetHeaderHeight(16)
	self:SetDataHeight(17)

	self.Columns = {}
	self.Lines = {}
	self.Sorted = {}

	self:SetDirty(true)

	self.pnlCanvas = vgui.Create("Panel", self)

	local col = table.Copy(Nexus.Colors.Secondary)
	col.a = 100
	self.VBar = vgui.Create("DVScrollBar", self)
	self.VBar:SetZPos(20)
	self.VBar:SetHideButtons(true)

	self.VBar.Paint = function(s, w, h)
		draw.RoundedBox(self.margin, 0, 0, w, h, col)
	end

	self.VBar.btnGrip.Paint = function(s, w, h)
		Nexus:DrawRoundedGradient(0, 0, w, h, Nexus.Colors.Primary)
	end
end

function PANEL:DisableScrollbar()
	if (IsValid(self.VBar)) then
		self.VBar:Remove()
	end

	self.VBar = nil
end

function PANEL:GetLines()
	return self.Lines
end

function PANEL:GetInnerTall()
	return self:GetCanvas():GetTall()
end

function PANEL:GetCanvas()
	return self.pnlCanvas
end

function PANEL:AddColumn(strName, iPosition)
	if (iPosition) then
		if (iPosition <= 0) then
			ErrorNoHaltWithStack("Attempted to insert column at invalid position ", iPosition)
			return
		end

		if (IsValid(self.Columns[iPosition])) then
			ErrorNoHaltWithStack("Attempted to insert duplicate column.")
			return
		end
	end

	local pColumn = nil
	if (self.m_bSortable) then
		pColumn = vgui.Create("DListView_Column", self)
	else
		pColumn = vgui.Create("DListView_ColumnPlain", self)
	end

	pColumn:SetName(strName)
	pColumn:SetZPos(10)

	if (iPosition) then
		table.insert(self.Columns, iPosition, pColumn)

		local i = 1
		for id, pnl in pairs(self.Columns) do
			pnl:SetColumnID(i)
			i = i + 1
		end
	else
		local ID = table.insert(self.Columns, pColumn)
		pColumn:SetColumnID(ID)
	end

	self:InvalidateLayout()

	return pColumn
end

function PANEL:RemoveLine(LineID)
	local Line = self:GetLine(LineID)
	local SelectedID = self:GetSortedID(LineID)

	self.Lines[LineID] = nil
	table.remove(self.Sorted, SelectedID)

	self:SetDirty(true)
	self:InvalidateLayout()

	Line:Remove()
end

function PANEL:ColumnWidth(i)
	local ctrl = self.Columns[i]
	if (!ctrl) then return 0 end

	return ctrl:GetWide()
end

function PANEL:FixColumnsLayout()
	local NumColumns = table.Count(self.Columns)
	if (NumColumns == 0) then return end

	local AllWidth = 0
	for k, Column in pairs(self.Columns) do
		AllWidth = AllWidth + math.ceil(Column:GetWide())
	end

	local ChangeRequired = self.pnlCanvas:GetWide() - AllWidth
	local ChangePerColumn = math.floor(ChangeRequired / NumColumns)
	local Remainder = ChangeRequired - (ChangePerColumn * NumColumns)
	for k, Column in pairs(self.Columns) do
		local TargetWidth = math.ceil(Column:GetWide()) + ChangePerColumn
		Remainder = Remainder + (TargetWidth - Column:SetWidth(TargetWidth))
	end

	local TotalMaxWidth = 0
	while (Remainder != 0) do
		local PerPanel = math.floor(Remainder / NumColumns)
		for k, Column in pairs(self.Columns) do
			Remainder = math.Approach(Remainder, 0, PerPanel)

			local TargetWidth = math.ceil(Column:GetWide()) + PerPanel
			Remainder = Remainder + (TargetWidth - Column:SetWidth(TargetWidth))
			if (Remainder == 0) then break end

			TotalMaxWidth = TotalMaxWidth + math.ceil(Column:GetMaxWidth())
		end

		if (TotalMaxWidth < self.pnlCanvas:GetWide()) then break end
		Remainder = math.Approach(Remainder, 0, 1)
	end

	local x = 0
	for k, Column in pairs(self.Columns) do
		Column.x = x
		x = x + math.ceil(Column:GetWide())

		Column:SetTall(math.ceil(self:GetHeaderHeight()))
		Column:SetVisible(!self:GetHideHeaders())
	end
end

function PANEL:PerformLayout()
	local Wide = self:GetWide()
	local YPos = 0
	if (IsValid(self.VBar)) then
		self.VBar:SetPos(self:GetWide() - Nexus:Scale(12), 0)
		self.VBar:SetSize(Nexus:Scale(12), self:GetTall())
		self.VBar:SetUp(self.VBar:GetTall() - self:GetHeaderHeight(), self.pnlCanvas:GetTall())
		YPos = self.VBar:GetOffset()

		if (self.VBar.Enabled) then Wide = Wide - 16 end
	end

	if (self.m_bHideHeaders) then
		self.pnlCanvas:SetPos(0, YPos)
	else
		self.pnlCanvas:SetPos(0, YPos + self:GetHeaderHeight())
	end

	self.pnlCanvas:SetSize(Wide, self.pnlCanvas:GetTall())
	self:FixColumnsLayout()

	if (self:GetDirty()) then
		self:SetDirty(false)

		local y = self:DataLayout()
		self.pnlCanvas:SetTall(y)
		self:InvalidateLayout(true)
	end
end

function PANEL:OnScrollbarAppear()
	self:SetDirty(true)
	self:InvalidateLayout()
end

function PANEL:OnRequestResize(SizingColumn, iSize)
	local Passed = false
	local RightColumn = nil
	for k, Column in pairs(self.Columns) do

		if (Passed) then
			RightColumn = Column
			break
		end

		if (SizingColumn == Column) then Passed = true end
	end

	if (RightColumn) then
		local SizeChange = SizingColumn:GetWide() - iSize
		RightColumn:SetWide(RightColumn:GetWide() + SizeChange)
	end

	SizingColumn:SetWide(iSize)
	self:SetDirty(true)

	self:InvalidateLayout()
end

function PANEL:DataLayout()
	local y = 0
	local h = self.m_iDataHeight

	local alt = false
	for k, Line in ipairs(self.Sorted) do

		if (!Line:IsVisible()) then continue end

		Line:SetPos(1, y)
		Line:SetSize(self:GetWide() - 2, h)
		Line:DataLayout(self)

		Line:SetAltLine(alt)
		alt = !alt
		y = y + Line:GetTall()
	end

	return y
end

function PANEL:AddLine(...)
	self:SetDirty(true)
	self:InvalidateLayout()

	local Line = vgui.Create("Nexus:ListView_Line", self.pnlCanvas)
    Line.SetColumnText = function(s, i, strText)
        if (type(strText) == "Panel") then
            if (IsValid(s.Columns[i])) then s.Columns[i]:Remove() end
    
            strText:SetParent(s)
            s.Columns[i] = strText
            s.Columns[i].Value = strText
            return
        end
    
        if (!IsValid(s.Columns[i])) then
            s.Columns[i] = vgui.Create("Nexus:ListViewLabel", s)
            s.Columns[i]:SetMouseInputEnabled(false)
            s.Columns[i]:SetTextColor(Nexus.Colors.Text)
        end
    
        s.Columns[i]:SetText(tostring(strText))
        s.Columns[i].Value = strText
        return s.Columns[i]
    end

	local ID = table.insert(self.Lines, Line)

	Line:SetListView(self)
	Line:SetID(ID)

	for k, v in pairs(self.Columns) do
		Line:SetColumnText(k, "")
	end

	for k, v in pairs({...}) do
		Line:SetColumnText(k, v)
	end

	local SortID = table.insert(self.Sorted, Line)
	if (SortID % 2 == 1) then
		Line:SetAltLine(true)
	end

	return Line
end

function PANEL:OnMouseWheeled(dlta)
	if (!IsValid(self.VBar)) then return end
	return self.VBar:OnMouseWheeled(dlta)
end

function PANEL:ClearSelection(dlta)
	for k, Line in pairs(self.Lines) do
		Line:SetSelected(false)
	end
end

function PANEL:GetSelectedLine()
	for k, Line in pairs(self.Lines) do
		if (Line:IsSelected()) then return k, Line end
	end
end

function PANEL:GetLine(id)
	return self.Lines[id]
end

function PANEL:GetSortedID(line)
	for k, v in pairs(self.Sorted) do
		if (v:GetID() == line) then return k end
	end
end

function PANEL:OnClickLine(Line, bClear)
	local bMultiSelect = self:GetMultiSelect()
	if (!bMultiSelect && !bClear) then return end

	if (bMultiSelect && input.IsKeyDown(KEY_LCONTROL)) then
		bClear = false
	end

	if (bMultiSelect && input.IsKeyDown(KEY_LSHIFT)) then
		local Selected = self:GetSortedID(self:GetSelectedLine())
		if (Selected) then
			local LineID = self:GetSortedID(Line:GetID())
			local First = math.min(Selected, LineID)
			local Last = math.max(Selected, LineID)

			for id = First, Last do
				local line = self.Sorted[id]
				if (!line:IsLineSelected()) then self:OnRowSelected(line:GetID(), line) end
				line:SetSelected(true)
			end

			if (bClear) then self:ClearSelection() end
			for id = First, Last do
				local line = self.Sorted[id]
				line:SetSelected(true)
			end

			return
		end
	end

	if (Line:IsSelected() && Line.m_fClickTime && (!bMultiSelect || bClear)) then
		local fTimeDistance = SysTime() - Line.m_fClickTime
		if (fTimeDistance < 0.3) then
			self:DoDoubleClick(Line:GetID(), Line)
			return
		end
	end

	if (!bMultiSelect || bClear) then
		self:ClearSelection()
	end

	if (Line:IsSelected()) then return end

	Line:SetSelected(true)
	Line.m_fClickTime = SysTime()

	self:OnRowSelected(Line:GetID(), Line)
end

function PANEL:SortByColumns(c1, d1, c2, d2, c3, d3, c4, d4)
	table.sort(self.Sorted, function(a, b)
		if (!IsValid(a)) then return true end
		if (!IsValid(b)) then return false end

		if (c1 && a:GetColumnText(c1) != b:GetColumnText(c1)) then
			if (d1) then a, b = b, a end
			return a:GetColumnText(c1) < b:GetColumnText(c1)
		end

		if (c2 && a:GetColumnText(c2) != b:GetColumnText(c2)) then
			if (d2) then a, b = b, a end
			return a:GetColumnText(c2) < b:GetColumnText(c2)
		end

		if (c3 && a:GetColumnText(c3) != b:GetColumnText(c3)) then
			if (d3) then a, b = b, a end
			return a:GetColumnText(c3) < b:GetColumnText(c3)
		end

		if (c4 && a:GetColumnText(c4) != b:GetColumnText(c4)) then
			if (d4) then a, b = b, a end
			return a:GetColumnText(c4) < b:GetColumnText(c4)
		end

		return true
	end)

	self:SetDirty(true)
	self:InvalidateLayout()
end

function PANEL:SortByColumn(ColumnID, Desc)
	table.sort(self.Sorted, function(a, b)
		if (Desc) then
			a, b = b, a
		end

		local aval = a:GetSortValue(ColumnID) || a:GetColumnText(ColumnID)
		local bval = b:GetSortValue(ColumnID) || b:GetColumnText(ColumnID)
		if (isnumber(aval) && isnumber(bval)) then return aval < bval end

		return tostring(aval) < tostring(bval)
	end)

	self:SetDirty(true)
	self:InvalidateLayout()
end

function PANEL:SelectItem(Item)
	if (!Item) then return end

	Item:SetSelected(true)
	self:OnRowSelected(Item:GetID(), Item)
end

function PANEL:SelectFirstItem()
	self:ClearSelection()
	self:SelectItem(self.Sorted[1])
end

function PANEL:Clear()
	for k, v in pairs(self.Lines) do
		v:Remove()
	end

	self.Lines = {}
	self.Sorted = {}

	self:SetDirty(true)
end

function PANEL:GetSelected()
	local ret = {}
	for k, v in pairs(self.Lines) do
		if (v:IsLineSelected()) then
			table.insert(ret, v)
		end
	end

	return ret
end

function PANEL:SizeToContents()
	self:SetHeight(self.pnlCanvas:GetTall() + self:GetHeaderHeight())
end

function PANEL:Paint(w, h)
    draw.RoundedBox(self.margin, 0, 0, w, h, Nexus.Colors.Background)
end

function PANEL:DoDoubleClick(LineID, Line, mx, my)
	for col, panel in ipairs(Line.Columns) do
		local within = panel:IsWithin(mx, my)
		if within then
			self:DoubleClicked(LineID, Line, col)
		end
	end
end

function PANEL:DoubleClicked(LineID, Line, col) end

function PANEL:OnRowSelected(LineID, Line) end
function PANEL:OnRowRightClick(LineID, Line) end

vgui.Register("Nexus:ListView", PANEL, "DPanel")