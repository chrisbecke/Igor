--[[
-- it seems very dangerous to unilaterally remove native-events
-- as they are chained.
function UI.Native.BankGuild.Event:Loaded()
    if self:GetLayer() > -1 then
        self.Event.Move = nil
    else
        self.Event.Move = 
        function(handle, args)
           print("Move --> handle: " .. tostring(handle) .. ", args: " .. tostring(args))
        end
    dump(self.Event)
    end
end
]]
