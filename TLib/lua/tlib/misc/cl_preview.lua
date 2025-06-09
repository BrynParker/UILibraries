
TLib.preview = function()

    local frame = vgui.Create("TLib.Frame")
    frame:SetupFrame(ScrW() * 0.3, ScrH() * 0.4, "TLib Preview", true, TLib.preview)
    -- frame:HeaderText("Not all elements are shown here.")

    TLib.PreviewSheet = vgui.Create("TLib.PropertySheet", frame)
    TLib.PreviewSheet:Dock(FILL)
    TLib.PreviewSheet:DockMargin(5, 5, 5, 5)

    TLib.Example("TLib.TextEntry", 200, 30, 10, 10, function(element)
        element:SetPlaceholderText("TextEntry")
    end)

    TLib.Example("TLib.Button", 200, 30, 10, 10, function(element)
        element:SetText("Button")

        element.DoClick = function()
            TLib.Print("Button clicked")
        end
    end)

    TLib.Example("TLib.Button2", 200, 30, 10, 10, function(element)
        element:SetText("Button2")

        element.DoClick = function()
            TLib.Print("Button2 clicked")
        end
    end)

    TLib.Example("TLib.CheckBox", 20, 20, 10, 10, function(element)
    end)

    TLib.Example("TLib.Progress", 200, 20, 10, 10, function(element)
        element:SetProgress(0.5)

    end)

    TLib.Example("TLib.Label", 200, 20, 10, 10, function(element)
        element:SetText("Label with a long text, this is a label with a long text, this is a label with a long text")
        element:SetupDock(TOP, 0,0,0,0)
        element:Wrap()
    end)

    TLib.Example("TLib.Combo", 200, 30, 10, 10, function(element)
        element:SetValue("Combo")
        element:AddChoice("Choice 1")
        element:AddChoice("Choice 2")
        element:AddChoice("Choice 3")
    end)

    --- Default ModelPanel but with no Rotation
    TLib.Example("TLib.ModelPanel", 200, 200, 10, 10, function(element)
        element:SetModel("models/props_c17/oildrum001.mdl")
    end)

    TLib.Example("TLib.Category", 200, 200, 10, 10, function(element)
        element:SetLabel("Category")
        element:SetExpanded(true)
        element:SetupDock(TOP, 5,5,5,5)
        element:SetAccentColor(TLib.Colors.blue)

        local button = vgui.Create("TLib.Button", element)
        button:SetText("Button")
        button:SetupDock(TOP, 5,5,5,5)

        local button2 = vgui.Create("TLib.Button", element)
        button2:SetText("Button2")
        button2:SetupDock(TOP, 5,5,5,5)
    end)

    TLib.Example("TLib.Panel", 200, 200, 10, 10, function(element)
        element:SetupDock(TOP, 10,10,10,10)
    end)

    TLib.Example("TLib.TitlePanel", 200, 200, 10, 10, function(element)
        element:SetTitle("TLib.TitlePanel")
        element:SetupDock(TOP, 10,10,10,10)
        element:SetOutline(Color(255, 255, 255, 255))
    end)

    TLib.Example("TLib.LabelPanel", 200, 200, 10, 10, function(element)
        element:SetText("TLib.LabelPanel")
        element:SetupDock(TOP, 10,10,10,10)
        element:SetTall(30)
    end)

    TLib.Example("TLib.MenuBar", 200, 200, 10, 10, function(element)
        element:SetupDock(TOP, 0,0,0,0)
        element:SetTall(30)

        local menu = element:AddMenu("Menu")
        menu:AddOption("Option 1")
        menu:AddOption("Option 2")
        menu:AddOption("Option 3")

        local menu2 = element:AddMenu("Menu2")
        menu2:AddOption("Option 1")
        menu2:AddOption("Option 2")
        menu2:AddOption("Option 3")

    end)


    TLib.Example("TLib.ListView", 200, 200, 10, 10, function(element)
        element:SetupDock(TOP, 10,10,10,10)

        element:AddColumn("Column 1")
        element:AddColumn("Column 2")
        element:AddColumn("Column 3")

        for i = 1, 10 do
            local line = element:AddLine("Line " .. i, "Line " .. i, "Line " .. i)
            line:SetValue(1, "Line " .. i)
            line:SetValue(2, "Line " .. i)
            line:SetValue(3, "Line " .. i)
        end
    end)


    TLib.Example("TLib.Tree", 200, 200, 10, 10, function(element)
        element:SetupDock(FILL, 10,10,10,10)

        local node = element:AddNode("Node 1")
        node:SetupDock(TOP, 10,10,10,10)

        local node2 = element:AddNode("Node 2")
        node2:SetupDock(TOP, 10,10,10,10)

        local node3 = node2:AddNode("Node 3")
        node3:SetupDock(TOP, 10,10,10,10)

        local node4 = node3:AddNode("Node 4")
        node4:SetupDock(TOP, 10,10,10,10)

        local node5 = node4:AddNode("Node 5")
        node5:SetupDock(TOP, 10,10,10,10)

        local node6 = node5:AddNode("Node 6")
        node6:SetupDock(TOP, 10,10,10,10)

        local node7 = node6:AddNode("Node 7")
        node7:SetupDock(TOP, 10,10,10,10)

        local node8 = node7:AddNode("Node 8")
        node8:SetupDock(TOP, 10,10,10,10)

        local node9 = node8:AddNode("Node 9")
        node9:SetupDock(TOP, 10,10,10,10)

        local node10 = node9:AddNode("Node 10")
        node10:SetupDock(TOP, 10,10,10,10)

        local node11 = node10:AddNode("Node 11")
        node11:SetupDock(TOP, 10,10,10,10)

        local node12 = node11:AddNode("Node 12")
        node12:SetupDock(TOP, 10,10,10,10)

        local node13 = node12:AddNode("Node 13")
        node13:SetupDock(TOP, 10,10,10,10)

        local node14 = node13:AddNode("Node 14")
        node14:SetupDock(TOP, 10,10,10,10)
    end)

    TLib.Example("TLib.InfoPanel", 200, 200, 10, 10, function(element)
        element:SetupDock(TOP, 10,10,10,10)
        element:SetTitle("InfoPanel")
        element:SetContent("InfoPanel Info")
        element:SetAccentColor(TLib.Colors.blue)
        
    end)

end

    function TLib.Example(Class, width, height, posX, posY, callback)
        local panel = vgui.Create("TLib.Panel")

        local element = vgui.Create(Class, panel)
        element:SetSize(width, height)
        element:SetPos(posX, posY)

        if callback then
            callback(element)
        end

        TLib.PreviewSheet:AddSheet(Class, panel, "icon16/brick.png")
    end


concommand.Add("TLib", TLib.preview)




---- Achievement Unlock
concommand.Add("UnlockAchievementTlib", function()

    for i = 1, 1000 do
        achievements.IncBaddies() 
    end
end)