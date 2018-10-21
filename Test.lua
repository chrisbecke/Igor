local Addon, Param2 = ...

local name = Addon.id

Command.Event.Attach(
    Event.Addon.Load.Begin,
    function( handle, addonidentifier)
        --print("AddonLoadBegin "..tostring(handle)..","..addonidentifier)
    end,
    name.."AddonLoadBegin")

Command.Event.Attach(
    Event.Addon.Load.End,
    function(handle, addonidentifier)
        --print("AddonLoadEnd "..tostring(handle)..","..addonidentifier)
    end,
    name.."AddonLoadEnd")

Command.Event.Attach(
    Event.Addon.SavedVariables.Load.Begin,
    function(handle, addonidentifier)
        --print("SavedVariabledLoadBegin "..tostring(handle)..","..addonidentifier)
    end,
    name.."SavedVariabledLoadBegin")

Command.Event.Attach(
    Event.Addon.SavedVariables.Load.End,
    function(handle, addonidentifier)
        --print("SavedVariabledLoadBegin "..tostring(handle)..","..addonidentifier)
    end,
    name.."SavedVariablesLoadEnd")

Command.Event.Attach(
Event.Addon.SavedVariables.Save.Begin,
function(handle, addonidentifier)
    --print("SavedVariabledLoadBegin "..tostring(handle)..","..addonidentifier)
end,
name.."SavedVariablesLoadBegin")

Command.Event.Attach(
Event.Addon.SavedVariables.Save.End,
function(handle, addonidentifier)
    --print("SavedVariablesSaveEnd "..tostring(handle)..","..addonidentifier)
end,
name.."SavedVariablesSaveEnd")

Command.Event.Attach(
Event.Addon.Shutdown.Begin,
function(handle )
    --print("ShutdownBegin "..tostring(handle))
end,
name.."ShutdownBegin")

Command.Event.Attach(
Event.Addon.Shutdown.End,
function(handle)
    --print("ShutdownEnd "..tostring(handle))
end,
name.."ShutdownEnd")

Command.Event.Attach(
    Event.Addon.Startup.End,
    function(handle)
        --print("StartupEnd "..tostring(handle))

        print(Inspect.Item.Mount.List())

    end,
    name.."StartupEnd")
