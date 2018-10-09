
local function printAllDocuments(pattern)
    local documentables = Inspect.Documentation()
    if string.isempty(pattern) then pattern=".*" end

    local names = {}
    for name in pairs(documentables) do
        if name:match(pattern) then
            names[#names+1] = name
        end
    end

    -- sort the names table for presentation
    table.casesort(names)

    -- print out the names
    for i,document in ipairs(names) do
        print(document)
    end
end

local function printDocument(item)
    local documentation = Inspect.Documentation(item)

    if documentation then
        dump(documentation)
    end
end

local function print_tableMembersByType(obj,prefix,showMarkdown,showTypes,recurse,exSuffix)
    if not exSuffix then exSuffix="" end
    if not prefix then prefix="" end
    local items = {}
    for key, value in pairs(obj) do
        local type = type(value)
        if not items[type] then items[type] = {} end
        table.insert(items[type],key)
    end
    local keys = table.keys(items)
    table.sort(keys)
    for i,type in ipairs(keys) do
        list=items[type]
        if showMarkdown then print("## " .. type) end
        local suffix=""
        --if showTypes then suffix = ' (' .. type .. ')' end
        local list=items[type]
        table.sort(list)
        for i=1, #list do
            if showTypes then
                if type == 'nil' then suffix = " = nil"
                elseif type == 'table' then suffix = " = { }"
                elseif type == 'string' then suffix = " = '".. obj[list[i]].."'"
                elseif type == 'number' then suffix = " = " .. tostring(obj[list[i]])
                elseif type == 'function' then suffix = " = function()"
                else suffix = " = " .. tostring(obj[list[i]] .. " ("..type..")")
                end
            end
            print(prefix .. list[i] .. suffix .. exSuffix)
            if recurse and type=='table' then
                print_tableMembersByType(obj[list[i]],prefix .. list[i] ..'.',false,showTypes,recurse,exSuffix)
            end
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

local function dumpcommand(param)
    local args = param:split("%s")
    local showMarkdown = false
    local recurse = false
    local usePrefix = false
    local showTypes = false
    local walkMeta = false
    local showValues = false
    for i=1, #args-1 do
        local arg = args[i]
        if arg == 'md' then
            showMarkdown=true
        elseif arg == string.sub('recurse',1,#arg) then
            recurse=true
        elseif arg == string.sub('path',1,#arg) then
            usePrefix=true
        elseif arg == string.sub('types',1,#arg) or arg == string.sub('values',1,#arg) then
            showTypes=true
        elseif arg == string.sub('meta',1,#arg) then
            walkMeta=true
        end
    end

    param = args[#args];
    if param == '.' then param="" end

    local obj = _G;
    if #param ~= 0 then
        obj = querySelector(param)
    end
    if obj then
        local name = param
        if #name == 0 then name = "Global" end
        print("Showing members of " .. name .. ":")
        if showMarkdown then print("# " .. param) end
        if usePrefix then param = param .. '.' else param = '' end
        print_tableMembersByType(obj,param,showMarkdown,showTypes,recurse)
        if walkMeta then
            local meta=getmetatable(obj)
            if meta then meta = meta.__index end
            while meta do
                print_tableMembersByType(obj,param,showMarkdown,showTypes,recurse," (inherited)")
                meta=getmetatable(meta)
                if meta then meta = meta.__index end
            end
        end
    end
end

Igor.Command['dump'] = function(param)
    if string.isempty(param) or param=='-help' then
        print("Dump prints info about objects in the lua namespace")
        print("Usage: /igor dump [path] [type] <name>")
        print('where <name> is the name of the object to dump or "." for _G')
        print("Example: /igor dump p t UI.Context\t\t\tShows path and type info for UI.Context")
    else
        Task.Run(dumpcommand(param))
    end
end

Igor.Command['list'] = function( param )
    if param == '-help' then
        print("list lists Inspector.Documentation")
        print("Usage: /igor list [<pattern>]")
        print("where <pattern> is an optional lua string matching pattern.")
    else
        if string.isempty(param) then
            print('Listing all Documentation artifacts:')
        else
            print('Listing Documentation artifacts that match ' .. param ..':')
        end
        Task.Run(printAllDocuments(param))
    end
end
    
Igor.Command['doc'] = function( param )
    if string.isempty(param) or param == '-help' then
        print('doc shows the Inspector Documentation for an item')
        print('Usage: /igor doc <name>')
        print('where <name> is an Inspector.Documentation item e.g. from /igor list')
    else
        print('Showing Documentation for ' .. param)
        Task.Run(printDocument(param))
    end
end