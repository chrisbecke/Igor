Igor = {
    -- UI Widgets register here 
    UI = { },
    -- Command handlers register here
    Command = {}
}


-- All /igor commands are of the form
--  /igor <command> [<command parameters>]
local function IgorChatCommand(handle, parameter)

    -- redirect any empty commands to help
    if string.isempty(parameter) then parameter = 'help' end

    -- split the slashcommand parameter into a command and arguments pair
    local command, arguments = parameter:match('(%w+) (.*)')
    if not command then command = parameter end

    -- Igor modules should register their igor commands here as functions
    handler = Igor.Command[command]

    -- execute the handler
    if handler then
        handler(arguments)
    else
        print("Igor doesn't know what '" .. parameter .. "' means.")
    end
end

-- register some defualt debug related commands
-- Igor.Command['info'] = printInfo
-- Igor.Command['c'] = function() printElements(Igor.help.context) end

Command.Event.Attach(Command.Slash.Register("igor"),IgorChatCommand,"Igor Slash Command")

print("Igor is ready to serve. /igor for help");
