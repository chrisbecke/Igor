
local function OnLoaded()
    print("BankGuild loaded?")
end

local function OnMove(handle,args)
    print("Move --> handle: " .. tostring(handle) .. ", args: " .. tostring(args))
end

--UI.Native.BankGuild.EventAttach(Event.UI.Native.Loaded,OnLoaded,"OnBankGuildLoaded")

print('SecureMode: '.. UI.Native.BankGuild:GetSecureMode())
print(Utility.Type(Event.UI.Layout.Move))
print(Utility.Type(Event.UI.Native.Loaded))

UI.Native.BankGuild:EventAttach(Event.UI.Layout.Move,OnMove,"OnBankGuildMoved")