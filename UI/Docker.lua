local toc, Igor = ...

local function createFrame(name, context)

    -- the control window
    local docker = UI.CreateFrame("Frame",name,context)

    docker:SetPoint("CENTERX",UIParent,"CENTERX")
    docker:SetPoint("BOTTOM",UIParent,"BOTTOM")

    local border = UI.CreateFrame("Texture","DockTex",docker)
    border:SetTexture('Rift','Tab_Bottom_On(flip).png.dds')

    local texWidth = border:GetTextureWidth()
    local texHeight = border:GetTextureHeight()

    docker:SetWidth(texWidth)
    docker:SetHeight(texHeight)
    border:SetAllPoints()

    return docker
end

Igor.UI.Factory['Docker'] = createFrame