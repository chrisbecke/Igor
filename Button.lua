
Igor.UI.Factory['Button'] = function(name,context)

    local button = UI.CreateFrame("RiftButton",name,context)

    function button:EnableDrag(onmoved)
        local isDragging = false
        local drag = { x=0, y=0 }

        self:EventAttach(Event.UI.Input.Mouse.Left.Down,
        function() 
            isDragging = true
            local mouse = Inspect.Mouse()
            local x = self:GetLeft() + self:GetWidth()/2
            local y = self:GetTop() + self:GetHeight()/2
            drag.x = mouse.x - x
            drag.y = mouse.y - y
            self:ClearAll()
            self:SetPoint("CENTER", UIParent, "TOPLEFT", x, y)
        end,
        name.."LeftDown")

        self:EventAttach(Event.UI.Input.Mouse.Left.Up,
        function()
            if isDragging == 2 and type(onmoved)=='function' then
                onmoved()
            end
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
            if isDragging == 2 then
                self:SetPoint("CENTER", UIParent, "TOPLEFT", x - drag.x, y - drag.y)
            else
                if math.abs(x-drag.x) > 8 or math.abs(y-drag.y) > 8 then
                    isDragging = 2
                end
            end
        end,
        name.."MouseMove")
    end

    return button
end