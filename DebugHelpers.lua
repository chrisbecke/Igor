
local function table_keys(tableIn)
    keys={}
    for key in pairs(tableIn) do
        keys[#keys+1]=key
    end
    return keys
end

local function print_tableMembersByType(obj,prefix,showMarkdown,showTypes)
    if not prefix then prefix="" end
    local items = {}
    for key, value in pairs(obj) do
        local type = type(value)
        if not items[type] then items[type] = {} end
        table.insert(items[type],key)
    end
    local keys = table_keys(items)
    table.sort(keys)
    for i,type in ipairs(keys) do
        list=items[type]
        if showMarkdown then print("## " .. type) end
        local suffix=""
        if showTypes then suffix = ' (' .. type .. ')' end
        local list=items[type]
        table.sort(list)
        for i=1, #list do
            print(prefix .. list[i] .. suffix)
        end
    end 
end



local function select(match, obj, depth, namespace, seen)
    if not namespace then namespace="" else namespace = namespace .. '.' end
    if not obj then obj = _G end
    if not seen then seen = {} end
    if not depth then depth = 3 end
    
    -- make sure we dont enumerate this item again
    seen[obj]=true
    -- prepare the results table
    local results = {}
    -- generate a list of child tables
    local members = {}
    for key, subObject in pairs(obj) do
        if type(subObject) == 'table' then
            table.insert(members,key)
        end
    end
    table.sort(members)
    -- now process the names - in order - to see which ones match the match clause and emit them
    for i,member in ipairs(members) do
        local fqname = namespace .. member
        if type(member) == 'string' and fqname:match(match) then
            table.insert(results,fqname)
        end
        if not seen[obj[member]] and depth > 0 then
            local inner = select(match,obj[member],depth-1,fqname,seen)
            if #inner then
                for i,value in ipairs(inner) do
                    table.insert(results,value)
                end
            end
        end
    end
    -- return the results table
    return results
end

-- querySelector('UI.Frames')
local function querySelector(selector,root)
    if not root then root = _G end
    if not selector or #selector==0 then return root end
    local names = selector:split("%.")
    local prefix = nil
    for i,name in pairs(names) do
        if prefix then prefix = prefix .. "." .. name else prefix = name end
        root = root[name]
        if not root then
            print("Error '" .. prefix .. "' was not found!")
        end
    end
    return root, prefix
end


Command.Event.Attach(
    Command.Slash.Register("query"),
    function(handle,param)
        if #param == 0 then
            print("Query prints info about objects in the lua namespace")
            print("Usage: /query [md] [path] [type] name")
            print("Example: /query p t UI.Context    -- Shows path and type info for UI.Context")
        end
        local args = param:split("%s")
        local showMarkdown = false
        local recurse = false
        local usePrefix = false
        local showTypes = false
        local walkMeta = false
        for i=1, #args-1 do
            local arg = args[i]
            if arg == 'md' then
                print('showmarkdown')
                showMarkdown=true
            elseif arg == string.sub('recurse',1,#arg) then
                recurse=true
            elseif arg == string.sub('path',1,#arg) then
                usePrefix=true
            elseif arg == string.sub('type',1,#arg) then
                showTypes=true
            elseif arg == string.sub('meta',1,#arg) then
                walkMeta=true
            end
        end

        if #args > 1 then
            param = args[#args];
            if param == '.' then param="" end
        end

        local obj = _G;
        if #param ~= 0 then
            obj = querySelector(param)
        end
        if obj then
            local name = param
            if #name == 0 then name = "Global" end
            print("Showing members of " .. name .. " ...")
            if showMarkdown then print("# " .. param) end
            if usePrefix then param = param .. '.' else param = '' end
            print_tableMembersByType(obj,param,showMarkdown,showTypes)
            if walkMeta then
                print('scanning meta...')
                local meta=obj.__index
                while meta do
                    print_tableMembersByType(obj,param.."meta",showMarkdown,showTypes)
                    meta=meta.__index
                end
            end
        end
    end,
    "DumpSlashCommand")

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
    
    