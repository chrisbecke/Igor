local addon, lib = ...

local commandRegistry = {}

-- All /igor commands are of the form
--  /igor <command> [<command parameters>]
local function IgorChatCommand(handle, parameter)

    -- redirect any empty commands to help
    if string.isempty(parameter) or parameter == '-help' then
        print("Usage: /"..addon.id.." <command>")
        print("where command is one of:")
        local commands = table.keys(commandRegistry)
        table.sort(commands)
        print('\t'..table.concat(commands,', '))
        return
    end

    -- split the slashcommand parameter into a command and arguments pair
    local command, arguments = parameter:match('(%w+) (.*)')
    if not command then command = parameter end

    -- Igor modules should register their igor commands here as functions
    handler = commandRegistry[command]

    -- execute the handler
    if handler then
        handler(arguments)
    else
        print("Igor doesn't know what '" .. parameter .. "' means.")
    end
end

Command.Event.Attach(Command.Slash.Register(addon.id),IgorChatCommand,"Igor Slash Command")

lib.Command = commandRegistry

print("Igor is ready to serve. /"..addon.id.." for help");
