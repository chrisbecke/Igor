local addon, lib = ...

local function createFrame(name,context)
    local frame = UI.CreateFrame("Frame",name,context)

    local bg = UI.CreateFrame("Texture",name.."Bg",frame) -- 256x256
    bg:SetTexture("Rift","window_small_bg_(yellow).png.dds")
    
    local border = UI.CreateFrame("Texture",name.."Border",frame)
    border:SetTexture("Rift","window_small_frame.png.dds") -- 256x256

    local content = UI.CreateFrame("Frame",name.."Content",frame)
    --content:SetBackgroundColor(1,1,1,0.5)

    function frame:GetBorder()
        return border
    end

    function frame:GetContent()
        return content
    end

    function frame:SetController(controller)
        if controller == 'border' then
            border:ClearAll()
            bg:ClearAll()
            content:ClearAll()

            border:SetAllPoints(self)

            bg:SetPoint("TOPLEFT",frame,"TOPLEFT",14,9)
            bg:SetPoint("BOTTOMRIGHT",frame,"BOTTOMRIGHT",-12,-11)

            content:SetPoint("TOPLEFT",frame,"TOPLEFT",16,16)
            content:SetPoint("BOTTOMRIGHT",frame,"BOTTOMRIGHT",-16,-16)
        
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