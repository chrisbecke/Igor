local toc, Igor = ...

local function createWindow(name,context)

    local window = UI.CreateFrame("RiftWindow", name, context)

    function window:EnableDrag(onmoved)
        local content = self:GetContent()
        local border = self:GetBorder()
        local drag = nil

        -- attach a mouse event to the content to ensure the frame doesn't get
        -- any mouse events while the mouse is over content
        content:EventAttach(Event.UI.Input.Mouse.Left.Down, 
        function(self,h)
        end,
        name.."ContentLeftClick")        
    
        border:EventAttach(Event.UI.Input.Mouse.Left.Down,
        function() 
            local mouse = Inspect.Mouse()
            drag = { x = mouse.x, y=mouse.y }
        end,
        name.."FrameLeftDown")
    
        border:EventAttach(Event.UI.Input.Mouse.Left.Up,
        function()
            drag = nil
        end,
        name.."FrameLeftUp")
    
        border:EventAttach(Event.UI.Input.Mouse.Left.Upoutside,
        function()
            drag = nil
        end,
        name.."FrameLeftUpoutside")
    
        border:EventAttach(Event.UI.Input.Mouse.Cursor.Move,
        function(wnd,event,x, y)
            if not drag then return end
            if drag.active then
                window:SetPoint("CENTER", UIParent, "TOPLEFT", x - drag.x, y - drag.y)
            else
                if math.abs(drag.x-x)>8 or math.abs(drag.y-y)>8 then
                    drag.active=true
                    local width = window:GetWidth()
                    local height = window:GetHeight()
                    local left, top, right, bottom = window:GetBounds()

                    drag.x = x - (left+right)/2
                    drag.y = y - (top+bottom)/2

                    window:ClearAll()
                    window:SetWidth(width)
                    window:SetHeight(height)
                    window:SetPoint("CENTER",UIParent,"TOPLEFT",x-drag.x, y-drag.y)
                end
            end
        end,
        name.."FrameMouseMove")
    end

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