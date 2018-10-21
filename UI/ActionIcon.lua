local toc, Igor = ...

local function createWindow(name,context)

    local content = UI.CreateFrame("Texture","IconContent",context)
    content:SetPoint("CENTER",context,"CENTER")

    local l,t,r,b = content:GetBounds()

--    print(string.format('Bounts: %d %d %d %d',l,t,r,b))

    local border = UI.CreateFrame("Texture","IconBorder",content)
    border:SetPoint("CENTER",content,"CENTER")
    border:SetTexture("Rift","icon_border.dds")
    border:SetWidth(64-4)
    border:SetHeight(64-4)

    l,t,r,b = border:GetBounds()

    print(string.format('Bounts: %d %d %d %d',l,t,r,b))

    return content
end

Igor.UI.Factory['ActionIcon'] = createWindow