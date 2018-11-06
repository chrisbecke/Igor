local addon, lib = ...

function lib.UI:EnableDrag(onmoved)
    local content = self:GetContent()
    local border = self:GetBorder()
    local drag = nil

    -- attach a mouse event to the content to ensure the frame doesn't get
    -- any mouse events while the mouse is over content
    content:EventAttach(Event.UI.Input.Mouse.Left.Down, 
    function(self,h)
    end,
    "ContentLeftClick")        

    border:EventAttach(Event.UI.Input.Mouse.Left.Down,
    function() 
        local mouse = Inspect.Mouse()
        drag = { x = mouse.x, y=mouse.y }
    end,
    "BorderLeftDown")

    border:EventAttach(Event.UI.Input.Mouse.Left.Up,
    function()
        drag = nil
    end,
    "BorderLeftUp")

    border:EventAttach(Event.UI.Input.Mouse.Left.Upoutside,
    function()
        drag = nil
    end,
    "BorderLeftUpoutside")

    border:EventAttach(Event.UI.Input.Mouse.Cursor.Move,
    function(wnd,event,x, y)
        if not drag then return end

        local xmin, ymin, xmax, ymax = UIParent:GetBounds()    
        local width = self:GetWidth()
        local height = self:GetHeight()
        xmin = xmin + width/2
        ymin = ymin + height/2
        xmax = xmax - width/2
        ymax = ymax - height/2

        if drag.active then
            local newx = x-drag.x
            local newy = y-drag.y

            if newx < xmin then newx = xmin end
            if newy < ymin then newy = ymin end
            if newx > xmax then newx = xmax end
            if newy > ymax then newy = ymax end

            self:SetPoint("CENTER", UIParent, "TOPLEFT", newx, newy)
        else
            if math.abs(drag.x-x)>8 or math.abs(drag.y-y)>8 then
                drag.active=true
                local left, top, right, bottom = self:GetBounds()

                drag.x = x - (left+right)/2
                drag.y = y - (top+bottom)/2

                self:ClearAll()
                self:SetWidth(width)
                self:SetHeight(height)
                self:SetPoint("CENTER",UIParent,"TOPLEFT",x-drag.x,y-drag.y)
            end
        end
    end,
    "BorderMouseMove")
end
