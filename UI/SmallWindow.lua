local addon, lib = ...

local function createFrame(name,context)
    local frame = UI.CreateFrame("Frame",name,context)

    local content = UI.CreateFrame("Texture",name.."Content",frame) -- 256x256
    content:SetTexture("Rift","window_small_bg_(yellow).png.dds")
    
    local border = UI.CreateFrame("Texture",name.."Border",frame)
    border:SetTexture("Rift","window_small_frame.png.dds") -- 256x256

    function frame:GetBorder()
        return border
    end

    function frame:GetContent()
        return content
    end

    function frame:SetController(controller)
        if controller == 'border' then
            border:ClearAll()
            content:ClearAll()

            border:SetAllPoints(self)

            content:SetPoint("TOPLEFT",frame,"TOPLEFT",14,9)
            content:SetPoint("BOTTOMRIGHT",frame,"BOTTOMRIGHT",-12,-11)
        
        elseif controller == 'content' then
        end
    end

    frame:SetController('border')
    frame:SetWidth(border:GetTextureWidth())
    frame:SetHeight(border:GetTextureHeight())

    frame.EnableDrag = lib.UI.EnableDrag

    return frame
end


lib.UI.Factory['SmallWindow'] = createFrame