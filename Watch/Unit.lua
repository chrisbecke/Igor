local addon,lib = ...

local function Unit_didAdd(handle, units)
--    print("Unit.didAdd")
--    fulldump(units,"units")
end

local function PlayerUnit_didFullAvailability(id)
    print('IsMountValidFor: '..id)
    fulldump(Inspect.Item.Mount.List(),'Mount')
end

local function Unit_didFullAvailability(handle, units)
    for id, name in pairs(units) do
        if name == 'player' then
            PlayerUnit_didFullAvailability(id)
        end
    end
    print("Unit.didFullAvailability")
    fulldump(units,"units")
end

Command.Event.Attach(Event.Unit.Add,Unit_didAdd,"didAddUnit")
Command.Event.Attach(Event.Unit.Availability.Full,Unit_didFullAvailability,'didFullAvailability')