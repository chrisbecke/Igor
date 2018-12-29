local addon, lib = ...

local summary = lib.summary

local OnLoadBegin = function(a,addonidentifier)
    print("OnLoadBegin "..summary(a)..', "'..addonidentifier..'"')
end

local OnLoadEnd = function(handle,addonidentifier)
    print("Event.Addon.Load.End "..summary(handle)..', "'..addonidentifier..'"')
end

local OnLoadVariablesBegin = function(a,addonidentifier)
    print("Event.Addon.SavedVariables.Load.Begin "..summary(a)..', "'..addonidentifier..'"')
end

local OnLoadVariablesEnd = function(a,addonidentifier)
    print("Event.Addon.SavedVariables.Load.End "..summary(a)..', "'..addonidentifier..'"')
end

local OnSaveVariablesBegin = function(a,addonidentifier)
    print("OnSaveVariablesBegin "..summary(a)..', "'..addonidentifier..'"')
end

local OnSavedVariablesEnd = function(a,addonidentifier)
    print("OnSaveVariablesEnd "..summary(a)..', "'..addonidentifier..'"')
end

local OnShutdownBegin = function(a)
    print("OnShutdownBegin "..summary(a))
end

local OnShutdownEnd = function(a)
    print("OnShutdownEnd "..summary(a))
end

local OnStartupEnd = function(a)
    print("Event.Addon.Startup.End "..summary(a))
end

Command.Event.Attach(Event.Addon.Load.Begin,OnLoadBegin,"AddonOnLoadBegin")
Command.Event.Attach(Event.Addon.Load.End,OnLoadEnd,"AddonOnLoadEnd")
Command.Event.Attach(Event.Addon.SavedVariables.Load.Begin,OnLoadVariablesBegin,"AddonOnLoadVariablesBegin")
Command.Event.Attach(Event.Addon.SavedVariables.Load.End,OnLoadVariablesEnd,"AddonOnLoadVariablesEnd")
Command.Event.Attach(Event.Addon.SavedVariables.Save.Begin,OnSaveVariablesBegin,"AddonOnSaveVariablesBegin")
Command.Event.Attach(Event.Addon.SavedVariables.Save.End,OnSavedVariablesEnd,"AddonOnSaveVariablesEnd")
Command.Event.Attach(Event.Addon.Shutdown.Begin,OnShutdownBegin,"AddonOnShutdownBegin")
Command.Event.Attach(Event.Addon.Shutdown.End,OnShutdownEnd,"AddonOnShutdownEnd")
Command.Event.Attach(Event.Addon.Startup.End,OnStartupEnd,"AddonOnStartupEnd")

print("Addon Started.")

for key,value in pairs(addon) do
    print('addon.'..key..'='..summary(value))
end
