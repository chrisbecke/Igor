local addon, lib = ...

-- This module publishes two values
-- Igor_Persist is created by virtual of the value existin in the .toc file
--
-- Here we map it into the private space as "Settings" where other modules
-- can store their values.
--
-- No extra work is required to persist settings as Rift will see
-- that Igor_Persist = lib.Settings = { whatever }
-- and be able to save it.

lib.Settings = {}

Command.Event.Attach(
    Event.Addon.SavedVariables.Load.End,
    function(handle, addonidentifier)
        if addonidentifier == addon.identifier then
            -- ensure any defaults are copied over.
            for key,value in pairs(lib.Settings) do
                if Igor_Persist[key] == nil then
                    Igor_Persist[key] = value
                end
            end
            -- now associate lib.Settings with the persistent anchor
            lib.Settings = Igor_Persist
        end
    end,
    addon.id.."SavedVariablesLoadEnd")

Command.Event.Attach(
    Event.Addon.SavedVariables.Save.Begin,
    function(handle, addonidentifier)
        if addonidentifier == addon.identifier then
            print(addon.name.." did start saving variables")
        end
    end,
    addon.id.."SavedVariablesSaveBegin")

Command.Event.Attach(
    Event.Addon.Startup.End,
    function(handle)
    end,
    addon.id.."StartupEnd")
