----- 
----- WIP
-----


local PANEL = {}

function PANEL:Init()

    self.video = vgui.Create("DHTML", self)
    self.video:Dock(FILL)
    -- self.video:SetHTML([[
    --     <video id="video" width="100%" height="100%" controls>
    --         <source src="]] .. self:GetVideo() .. [[" type="video/mp4">
    --     </video>
    -- ]])

    self.pausebutton = vgui.Create("DButton", self)
    self.pausebutton:Dock(BOTTOM)
    self.pausebutton:SetText("Pause")
    self.pausebutton.DoClick = function()
        self.video:RunJavascript("document.getElementById('video').pause();")
    end

end

function PANEL:PerformLayout(w, h)

end

function PANEL:SetVideo(url)
    self.video:SetHTML([[
        <video id="video" width="100%" height="100%" controls>
            <source src="]] .. url .. [[" type="video/mp4">
        </video>
    ]])
end

function PANEL:SetYoutubeVideo(url)
    self.video:SetHTML([[
<iframe width="560" height="315" src="https://www.youtube.com/embed/dQw4w9WgXcQ?si=WT8Px042-eq4Nfpc&amp;controls=0" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" allowfullscreen></iframe>    ]])
end

-- function PANEL:GetVideo()
--     return self.video:GetHTML()
-- end


vgui.Register("TLib.VideoPanel", PANEL, "TLib.Panel")

TLib.VideoPanelTest = function()

    local frame = vgui.Create("TLib.Frame")
    frame:SetupFrame(800,600, "Video Test", true, false)


    local video = vgui.Create("TLib.VideoPanel", frame)
    video:SetupDock(FILL)
    -- video:SetVideo("https://www.youtube.com/watch?v=dQw4w9WgXcQ")
    video:SetYoutubeVideo("https://www.youtube.com/watch?v=rS216mWn5wg&t=30s")
end

concommand.Add("tlib_video_test", TLib.VideoPanelTest)