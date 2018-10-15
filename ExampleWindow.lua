local context = UI.CreateContext("TooltipExtraContext")
local window = UI.CreateFrame("RiftWindow", "ExampleWindow", context)
window:SetPoint("CENTER", UIParent, "CENTER")
window:SetTitle("Example Window")

local border = window:GetBorder()
local content = window:GetContent()
local controller = window:GetController()
--content:SetBackgroundColor(1.0,0.8,0.6,0.5)


function window:EnableClose(onclose)
    local button = UI.CreateFrame('RiftButton','Close',window)
    button:SetPoint('TOPRIGHT',window,'TOPRIGHT',-6,17)
    button:SetSkin('close')

    button:EventAttach(Event.UI.Input.Mouse.Left.Click,onclose,'OnClose')
end

function window:EnableDrag()
    local border = self:GetBorder()
    local isLeftDown = false
    local drag = { x=0, y=0 }

    border:EventAttach(Event.UI.Input.Mouse.Left.Down,
    function() 
        isLeftDown = true
        local mouse = Inspect.Mouse()
        drag.x = mouse.x - self:GetLeft()
        drag.y = mouse.y - self:GetTop()
        local left, top, right, bottom = window:GetBounds()
        window:ClearAll()
        window:SetPoint("TOPLEFT", UIParent, "TOPLEFT", left, top)
    end,
    "ExampleWindowLeftDown")

    border:EventAttach(Event.UI.Input.Mouse.Left.Up,
    function()
        isLeftDown = false
    end,
    "ExampleWindowLeftUp")

    border:EventAttach(Event.UI.Input.Mouse.Left.Upoutside,
    function()
        isLeftDown = false
    end,
    "ExampleWindowLeftUpoutside")

    border:EventAttach(Event.UI.Input.Mouse.Cursor.Move,
    function(wnd,event,x, y)
        if not isLeftDown then
            return
        end
        window:SetPoint("TOPLEFT", UIParent, "TOPLEFT", x - drag.x, y - drag.y)
    end,
    "ExampleWindowMouseMove")
end

window:EnableDrag()
window:EnableClose(function() 
    window:SetVisible(false)
end)
