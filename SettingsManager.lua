local addon, Igor = ...

local name = addon.id

Command.Event.Attach(
    Event.Addon.SavedVariables.Load.End,
    function(handle, addonidentifier)
        if addonidentifier == addon.identifier then
            Igor.Settings = Igor_Persist
        end
    end,
    name.."SavedVariablesLoadEnd")

Command.Event.Attach(
    Event.Addon.SavedVariables.Save.Begin,
    function(handle, addonidentifier)
        if addonidentifier == addon.identifier then
            print(addon.name.." did start saving variables")
        end
    end,
    name.."SavedVariablesSaveBegin")

Command.Event.Attach(
    Event.Addon.Startup.End,
    function(handle)
    end,
    name.."StartupEnd")
