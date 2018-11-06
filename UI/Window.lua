local toc, Igor = ...

local ResizeThumb = {
    Down = "chat_resize_(click).png.dds",
    Normal = "chat_resize_(normal).png.dds",
    Over = "chat_resize_(over).png.dds"
}

local function createWindow(name,context)

    local window = UI.CreateFrame("RiftWindow", name, context)

    window.EnableDrag = Igor.UI.EnableDrag

    function window:EnableClose(onclose)
        local border = self:GetBorder()
        local button = UI.CreateFrame('RiftButton','Close',self)
        button:SetPoint('TOPRIGHT',border,'TOPRIGHT',-6,17)
        button:SetSkin('close')
    
        button:EventAttach(Event.UI.Input.Mouse.Left.Click,onclose,'OnClose')
    end

    function window:SetContentSize(width,height)
        self:SetController('content')
        self:SetWidth(width)
        self:SetHeight(height)
    end

    return window
end

Igor.UI.Factory['RiftWindow'] = createWindow