
-- Threegrid made by Threebow

local sc = VoidUI.Scale

local PANEL = {}

AccessorFunc(PANEL, "horizontalMargin", "HorizontalMargin", FORCE_NUMBER)
AccessorFunc(PANEL, "verticalMargin", "VerticalMargin", FORCE_NUMBER)
AccessorFunc(PANEL, "columns", "Columns", FORCE_NUMBER)

AccessorFunc(PANEL, "maxHeight", "MaxHeight", FORCE_NUMBER)

function PANEL:Init()
	self:SetHorizontalMargin(10)
	self:SetVerticalMargin(10)

	self.Rows = {}
	self.Cells = {}

end


function PANEL:AddCell(pnl, fixedWidth, fixedHeight)
	local cols = self:GetColumns()
	local idx = math.floor(#self.Cells/cols)+1
	self.Rows[idx] = self.Rows[idx] || self:CreateRow()

	local margin = sc(self:GetHorizontalMargin())
	
	pnl:SetParent(self.Rows[idx])
	pnl:Dock(LEFT)
	pnl:DockMargin(0, 0, #self.Rows[idx].Items+1 < cols && sc(self:GetHorizontalMargin()) || 0, 0)
	if (!fixedWidth) then
		local sub = fixedHeight and 0 or 10
		pnl:SetWide((self:GetWide()-margin*(cols-1))/cols - sub)

		pnl.PerformLayout = function ()
			pnl:SetWide((self:GetWide()-margin*(cols-1))/cols - sub)
		end
	end

	table.insert(self.Rows[idx].Items, pnl)
	table.insert(self.Cells, pnl)
	self:CalculateRowHeight(self.Rows[idx], fixedHeight)
end

function PANEL:CalculateRows()
	for k, v in pairs(self.Rows) do
		self:CalculateRowHeight(v)
	end
end

function PANEL:AutoSize()
	
	local totalHeight = 0

	for _, row in pairs(self.Rows) do
		local height = 0
		local bottomMargin = 0
		for k, v in pairs(row.Items) do
			local left, top, right, bottom = v:GetDockMargin()

			height = math.max(height, v:GetTall())
			bottomMargin = sc(self:GetVerticalMargin())
		end

		totalHeight = totalHeight + height + bottomMargin
	end

	totalHeight = math.max(0, totalHeight - sc(self:GetVerticalMargin()))
	if (self:GetMaxHeight() and self:GetMaxHeight() != 0) then
		totalHeight = math.min(totalHeight, sc(self:GetMaxHeight()))
	end

	self:SetTall(totalHeight)

	if (self:GetParent():GetName() == "VoidUI.PanelContent") then
		self:GetParent():SetTall(totalHeight + self:GetTopMargin())
	end

	return totalHeight

end

function PANEL:CreateRow()
	local row = self:Add("DPanel")
	row:Dock(TOP)
	row:DockMargin(0, 0, 0, sc(self:GetVerticalMargin()))
	row.Paint = nil
	row.Items = {}
	return row
end

function PANEL:CalculateRowHeight(row)
	local height = 0

	for k, v in pairs(row.Items) do
		height = math.max(height, v:GetTall())
	end

	row:SetTall(height)
end

function PANEL:Skip()
	local cell = vgui.Create("DPanel")
	cell.Paint = nil
	self:AddCell(cell)
end

function PANEL:Clear()
	for _, row in pairs(self.Rows) do
		for _, cell in pairs(row.Items) do
			cell:Remove()
		end
		row:Remove()
	end

	self.Cells, self.Rows = {}, {}
end

PANEL.OnRemove = PANEL.Clear

vgui.Register("VoidUI.Grid", PANEL, "VoidUI.ScrollPanel")
