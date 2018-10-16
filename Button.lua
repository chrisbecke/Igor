
Igor.UI.Factory['Button'] = function(name,context)

    local button = UI.CreateFrame("RiftButton",name,context)

    function button:EnableDrag(onmoved)
        local dragging = nil
        local wasEnabled = nil

        local function startDrag()
            local mouse = Inspect.Mouse()
            dragging = { x=mouse.x, y=mouse.y }
        end

        local function endDrag()
            if dragging and dragging.active and type(onmoved)=='function' then
                onmoved()
            end
            if dragging then Task.Run(
                function() 
                    local count = 100
                    while count > 0 do
                        count = count -1
                        Task.Yield()
                    end
                    self:SetEnabled(wasEnabled)
                end) 
            end
            dragging = nil
        end

        local function moveDrag(wnd,event,x, y)
            if not dragging then
                return
            end
            if dragging.active then
                self:SetPoint("CENTER", UIParent, "TOPLEFT", x, y)
            else
                if math.abs(x-dragging.x) > 8 or math.abs(y-dragging.y) > 8 then
                    local width = self:GetWidth()
                    local height = self:GetHeight()
                    wasEnabled = self:GetEnabled()
                    local left, top, right, bottom = self:GetBounds()
                    if not width then width = right - left end
                    if not height then height = bottom - top end
                    self:SetEnabled(false)
                    self:ClearAll()
                    self:SetWidth(width)
                    self:SetHeight(height)
                    self:SetPoint("CENTER", UIParent, "TOPLEFT", x, y)
                    dragging.active=true
                end
            end
        end

        self:EventAttach(Event.UI.Input.Mouse.Left.Down,startDrag,name.."LeftDown")
        self:EventAttach(Event.UI.Input.Mouse.Left.Up,endDrag,name.."LeftUp")
        self:EventAttach(Event.UI.Input.Mouse.Left.Upoutside,endDrag,name.."LeftUpoutside")
        self:EventAttach(Event.UI.Input.Mouse.Cursor.Move,moveDrag,name.."MouseMove")
    end

    return button
end