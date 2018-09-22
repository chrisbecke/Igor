local help = {}

help.context = UI.CreateContext("SampleContext")
help.window = UI.CreateFrame("RiftWindow", "SampleWindow", help.context)
help.window:SetPoint("CENTER", UIParent, "CENTER")
help.window:SetTitle("Igor")
help.window:SetVisible(false)
Igor.UI.EnableDrag(help.window)

-- Add our command to Igor.
Igor.Command['help'] = function()
    help.window:SetVisible(not help.window:GetVisible())
end


