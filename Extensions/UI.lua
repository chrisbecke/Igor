local toc, lib = ...

local UI_meta = { __index = UI }

local ui = { Factory = {} }

setmetatable(ui,UI_meta)

function ui.CreateFrame(type,name,parent)
    if ui.Factory[type] then
        return ui.Factory[type](name,parent)
    end
    return UI.CreateFrame(type,name,parent)
end

lib.UI = ui
