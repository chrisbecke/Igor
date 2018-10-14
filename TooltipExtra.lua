-- Adds an extra display box to the tooltip

local assets = {
    seperator = { source = 'Rift', texture = 'line_window_break.png.dds' },
    tooltip = { source = 'Rift', texture = ''}
}
-- background_image_default.png
-- btn_generic.png
-- btn_generic_(disabled).png
-- btn_generic_(over).png
-- rewardbar-(disabled).png
-- rewardbar.png

local context = UI.CreateContext("TooltipExtraContext")

--[[
local window = UI.CreateFrame("RiftWindow", "IgorWindow2", context)
window:SetPoint("CENTER", UIParent, "CENTER")
window:SetTitle("Igor")
Igor.UI.EnableDrag(window)

local border = window:GetBorder()
local content = window:GetContent()

--content:SetBackgroundColor(1.0,0.8,0.6,0.5)
]]

local texture = UI.CreateFrame('Texture','tex',context)
-- texture:SetAllPoints()
texture:SetTexture('Rift','window_popup_small.png.dds')
texture:SetPoint("CENTER",content,"CENTER")
texture:SetWidth(texture:GetTextureWidth())
texture:SetHeight(texture:GetTextureHeight())


-- <- Element          (hidden)
-- <- Layout           (hidden)
-- Layout <- Native
-- Layout <- Element
-- Element <- Frame
-- Frame <- Canvas
-- Frame <- Mask
-- Frame <- RiftButton
-- Frame <- RiftCheckbox
-- Frame <- RiftScrollbar
-- Frame <- RiftSlider
-- Frame <- RiftTextField
-- Frame <- RiftWindow -* content, border
-- Frame <- RiftWindowBorder
-- Element <- RiftWindowContent
-- Frame <- Text
-- Frame <- Texture

fulldump(content,'RiftWindowContent')


local function OnTooltip(handle, type, shown, buff)
    if not shown then return end

    local left,top,right,bottom = UI.Native.Tooltip:GetBounds()

    local padding = 0;
    local verticalOffset = 15;

	texture:ClearAll()
	texture:SetPoint("BOTTOMLEFT", UI.Native.Tooltip, "TOPLEFT", padding, verticalOffset)
	texture:SetPoint("BOTTOMRIGHT", UI.Native.Tooltip, "TOPRIGHT", -padding, verticalOffset)
end

Command.Event.Attach(Event.Tooltip,OnTooltip,"AuctionsOnTooltip")