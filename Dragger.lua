-- Creates a UI.Frame object that is not shown.
--  intercepts mouse down / up events on this frame
--  and uses that to move the corresponding target frame.



local function MouseDown(dragFrame)
	local mouse = Inspect.Mouse()
	dragFrame.x = dragFrame.frame:GetLeft()
	dragFrame.y = dragFrame.frame:GetTop()
	dragFrame.xOffset = dragFrame.x - mouse.x
	dragFrame.yOffset = dragFrame.y - mouse.y
	dragFrame.dragging = true
end

local function MouseMove(dragFrame, x, y)
	if dragFrame.dragging == true and dragFrame.enabled == true then
		dragFrame.x = x + dragFrame.xOffset
		dragFrame.y = y + dragFrame.yOffset
		if dragFrame.changedCallback then
			dragFrame.changedCallback(dragFrame)
		end
	end
end

local function MouseUp(dragFrame)
	dragFrame.dragging = false
end

function Igor.UI.CreateDragger(parentFrame, changedCallback)
	local dragFrame = {}
	
	dragFrame.dragging = false
	dragFrame.enabled = true
	dragFrame.frame = UI.CreateFrame("Frame", "IgorDragFrame", parentFrame)
	dragFrame.frame:SetPoint("TOPLEFT", parentFrame, "TOPLEFT")
	dragFrame.frame:SetPoint("BOTTOMRIGHT", parentFrame, "TOPLEFT", parentFrame:GetWidth(), parentFrame:GetHeight())
	dragFrame.width = parentFrame:GetWidth()
	dragFrame.height = parentFrame:GetHeight()
	dragFrame.changedCallback = changedCallback
	dragFrame.frame:SetMouseMasking("limited")
	dragFrame.frame.Event.RightUp = function () MouseUp(dragFrame) end
	dragFrame.frame.Event.RightUpoutside = function () MouseUp(dragFrame) end
	dragFrame.frame.Event.RightDown = function () MouseDown(dragFrame) end
	dragFrame.frame.Event.MouseMove = function (event, x, y) MouseMove(dragFrame, x, y) end
	
	return dragFrame
end

-- an alternate dragger

function UI.Frame:EnableDrag()

    local forFrame = self
    local drag = { frame = forFrame }
    function drag.mouseUp(self)
        self.dragging = false
        print("mouseup")
    end
    function drag.mouseDown(self)
        local mouse = Inspect.Mouse()
        self.ofx = self.frame:GetLeft() - mouse.x
        self.ofy = self.frame:GetTop() - mouse.y
        self.dragging = true        
        print("mousedown")
    end
    function drag.mouseMove(self, event, x, y)
        if self.dragging then
            self.frame:SetPoint("TOPLEFT", UIParent, "TOPLEFT",x +self.ofx, y+self.ofy)
        end        
        print("mousemove")
    end

    print("doing the thing!")

	forFrame:SetMouseMasking("full")
	forFrame.Event.LeftUp = function () MouseUp(drag) end
	forFrame.Event.LeftUpoutside = function () MouseUp(drag) end
	forFrame.Event.LeftDown = function () MouseDown(drag) end
    forFrame.Event.MouseMove = function (event, x, y) MouseMove(drag, event, x, y) end
end

-- must pass in a RiftWindow
function Igor.UI.EnableDrag(window)
    local border = window:GetBorder()
    function border.Event:LeftDown()
      self.leftDown = true
      local mouse = Inspect.Mouse()
      self.originalXDiff = mouse.x - self:GetLeft()
      self.originalYDiff = mouse.y - self:GetTop()
      local left, top, right, bottom = window:GetBounds()
      window:ClearAll()
      window:SetPoint("TOPLEFT", UIParent, "TOPLEFT", left, top)
      window:SetWidth(right-left)
      window:SetHeight(bottom-top)
    end
    function border.Event:LeftUp()
      self.leftDown = false
    end
    function border.Event:LeftUpoutside()
      self.leftDown = false
    end
    function border.Event:MouseMove(x, y)
      if not self.leftDown then
        return
      end
      window:SetPoint("TOPLEFT", UIParent, "TOPLEFT", x - self.originalXDiff, y - self.originalYDiff)
    end
  end