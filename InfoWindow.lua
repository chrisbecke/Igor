local toc, Igor = ...

local function OnLoaded()
    print("BankGuild loaded?")
end

local function OnMove(handle,args)
    print("Move --> handle: " .. tostring(handle) .. ", args: " .. tostring(args))
end

--UI.Native.BankGuild.EventAttach(Event.UI.Native.Loaded,OnLoaded,"OnBankGuildLoaded")

--print('SecureMode: '.. UI.Native.BankGuild:GetSecureMode())
--print(Utility.Type(Event.UI.Layout.Move))
--print(Utility.Type(Event.UI.Native.Loaded))

--UI.Native.BankGuild:EventAttach(Event.UI.Layout.Move,OnMove,"OnBankGuildMoved")

local function DumpItemInfo(item)

    local detail = Inspect.Item.Detail(item)
    fulldump(detail,'item')

end


local context = UI.CreateContext("TooltipExtraContext")
local window = Igor.UI.CreateFrame("RiftWindow","DropWindow",context)

window:SetPoint("CENTER", UIParent, "CENTER")
window:SetContentSize(200,200)
window:SetTitle("Debug Item Window")
window:EnableDrag()
window:EnableClose(function() 
    window:SetVisible(false)
end)

local content = window:GetContent()
local texture = UI.CreateFrame("Texture","DumpTexture",content)
texture:SetPoint("CENTER",content,"CENTER")
texture:SetMouseMasking('limited')

local last = {}

content:EventAttach(Event.UI.Input.Mouse.Cursor.Move,
function(wnd,event,x, y)
    print('Cursor move Event')

    local type, held = Inspect.Cursor()
    if not type or not held then return end
    if type ~= last.type or held ~= last.held then
        last.type = type
        last.held = held
        local detail = Inspect.Item.Detail(held)

--        DumpItemInfo(held)

--        fulldump(icon,'icon')
--        texture:SetTexture("Rift","")
--        texture:ClearWidth()
--        texture:ClearHeight()
        texture:SetTexture("Rift",detail.icon)
    end
end,
"DebugItemCatchCursor")


Command.Event.Attach(Event.Cursor,
function(handle,type, held)
    --print('Cursor Event')

    if type == 'item' then
--        DumpItemInfo(held)
    end
--    fulldump(handle,'handle')
--    fulldump(type,'type')
--    fulldump(held,'held')
end,
"TestCursor")