dumper = {}

function dumper.printAllDocuments()
    local documentables = Inspect.Documentation()

    for document, enabled in pairs(documentables) do
        print(document .. " (" .. type(document) .. ")")
    end
end

function dumper.printDocument(item)
    local documentation = Inspect.Documentation(item)

    if documentation then
        dump(documentation)
    end
end

function dumper.SlashCommand(handle, param)
    if string.isempty(param) then
        dumper.printAllDocuments()
    else
        dumper.printDocument(param)
    end
end

Command.Event.Attach(Command.Slash.Register("d"),dumper.SlashCommand,"z")