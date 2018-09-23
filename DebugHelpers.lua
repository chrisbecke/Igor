


    --[[
Command.Event.Attach(
    Command.Slash.Register(""),
    function(handle,param)
        if #param == 0 then param = ".*" end
        local list = select(param)

        print("dumping members of "..param)
        for key,value in pairs(list) do
            print(value)
        end
        print('(end)')
    end,
    "DumpSlashCommand")
]]    

--[[
function table_print (tt, indent, done)
    done = done or {}
    indent = indent or 0
    if type(tt) == "table" then
        local sb = {}
        for key, value in pairs (tt) do
            table.insert(sb, string.rep (" ", indent)) -- indent it
            if type (value) == "table" and not done [value] then
                done [value] = true
                table.insert(sb, "{\n");
                table.insert(sb, table_print (value, indent + 2, done))
                table.insert(sb, string.rep (" ", indent)) -- indent it
                table.insert(sb, "}\n");
            elseif "number" == type(key) then
                table.insert(sb, string.format("\"%s\"\n", tostring(value)))
            else
                table.insert(sb, string.format("%s = \"%s\"\n", tostring (key), tostring(value)))
            end
        end
        return table.concat(sb)
    else
        return tt .. "\n"
    end
end

function to_string( tbl )
    if  "nil"       == type( tbl ) then
        return tostring(nil)
    elseif  "table" == type( tbl ) then
        return table_print(tbl)
    elseif  "string" == type( tbl ) then
        return tbl
    else
        return tostring(tbl)
    end
end
    
function printInfo()
    print("Language: " .. Inspect.System.Language())
    print(string.format("Secure: %s", Inspect.System.Secure()))
    print(string.format("Version: %s", to_string(Inspect.System.Version())))
end


function printElements(window,indent)
    indent=indent or 0
    print(string.rep(" ",indent) .. window:GetName() .. " (" ..window:GetType() .. ")")

    local children = window:GetChildren()
    for child in pairs(children) do
        printElements(child,indent+4)
    end
end
]]