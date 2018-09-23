-- must pass in a RiftWindow
function Igor.UI.EnableDrag(window)
    local border = window:GetBorder()
    local isLeftDown = false
    local drag = { x=0, y=0 }
    function border.Event:LeftDown()
      isLeftDown = true
      local mouse = Inspect.Mouse()
      drag.x = mouse.x - self:GetLeft()
      drag.y = mouse.y - self:GetTop()
      local left, top, right, bottom = window:GetBounds()
      window:ClearAll()
      window:SetPoint("TOPLEFT", UIParent, "TOPLEFT", left, top)
      --window:SetWidth(right-left)
      --window:SetHeight(bottom-top)
    end
    function border.Event:LeftUp()
        isLeftDown = false
    end
    function border.Event:LeftUpoutside()
        isleftDown = false
    end
    function border.Event:MouseMove(x, y)
        if not isLeftDown then
            return
        end
        window:SetPoint("TOPLEFT", UIParent, "TOPLEFT", x - drag.x, y - drag.y)
    end
  end