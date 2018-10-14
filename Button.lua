
Igor.UI.Factory['Button'] = function(name,context)

    local button = UI.CreateFrame("RiftButton",name,context)
    function button:EnableDrag()
        local isDragging = false
        local drag = { x=0, y=0 }

        self:EventAttach(Event.UI.Input.Mouse.Left.Down,
        function() 
            isDragging = true
            local mouse = Inspect.Mouse()
            drag.x = mouse.x - self:GetLeft()
            drag.y = mouse.y - self:GetTop()
            local left, top, right, bottom = self:GetBounds()
            self:ClearAll()
            self:SetPoint("TOPLEFT", UIParent, "TOPLEFT", left, top)
        end,
        name.."LeftDown")

        self:EventAttach(Event.UI.Input.Mouse.Left.Up,
        function()
            isDragging = false
        end,
        name.."LeftUp")

        self:EventAttach(Event.UI.Input.Mouse.Left.Upoutside,
        function()
            isDragging = false
        end,
        name.."LeftUpoutside")

        self:EventAttach(Event.UI.Input.Mouse.Cursor.Move,
        function(wnd,event,x, y)
            if not isDragging then
                return
            end
            self:SetPoint("TOPLEFT", UIParent, "TOPLEFT", x - drag.x, y - drag.y)
        end,
        name.."MouseMove")
    end

    return button


end