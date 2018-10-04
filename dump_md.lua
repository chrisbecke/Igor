local function dump_md()
    local doc_names_map = Inspect.Documentation()

    local function to_string(val)
        if type(val) == 'string' then
            return '\''..val:gsub('([<\\\r\n\t\'])', { ['\r']='\\r', ['\n']='\\n', ['\t']='\\t', ['<']='&lt;',['\'']='\\\''})..'\''
        elseif type(val) == 'table' then
            return "{}"
        else
            return tostring(val) .. ' ('..type(val)..')'
        end
    end

    -- fix some characters in strings that cause md parsing to screw up
    local function safe(val)
        return val:gsub('<','&lt;')
    end

    local function print_table(tbl,prefix,recurse)
        if not prefix then prefix='' end
        for field,value in pairs(tbl) do
            print(prefix .. field .. '=' ..to_string(value))
            if recurse and type(value) == 'table' then print_table(value,prefix..field..'.') end
        end
    end

    local function dump_md_doc(doc)
        local isfunction=false
        local showReadable=false
        -- start with the summary if present
        if doc.summary then
            print(doc.summary)
            doc.summary = nil
        end
        if doc.type == 'function' then
            isFunction=true
            doc.type=nil
        end

        if doc.signature then
            print('')
            print('    '..doc.signature)
            doc.signature = nil
        end

        if doc.signatures then
            print('')
            for field,value in ipairs(doc.signatures) do
                -- as md quotes these dont need to be made safe despite '<'s
                print('    '..value)
            end
            doc.signatures = nil
        end

        if doc.parameter then
            print('#### Parameters:')
            local order = doc.order
            if not order then order = table.keys(doc.parameter) end
            for i,key in ipairs(order) do
                print('**'..key..'** - '..safe(tostring(doc.parameter[key]))..'  ')
            end
            doc.parameter = nil
            doc.order = nil
        end

        if doc.order then
            print('#### Order:')
            print(table.concat(doc.order,', '))
            doc.order=nil
        end

        if doc.result then
            print('#### Return Values:')
            for field,value in pairs(doc.result) do
                print('**'..field..'** - '..safe(value)..'  ')
            end
            doc.result=nil
        end
    
        if doc.members then
            print('#### Returned Members:')
            for field,value in pairs(doc.members) do
               print('**'..field..'** - '..safe(value))
            end
            doc.members=nil
        end

        if doc.throttleGlobal or doc.deprecated or doc.noSecureFrameAndEnvironment or doc.requireSecureFrameAndInsecureEnvironment 
        or doc.hardwareevent or doc.interaction then

            print('#### Restrictions:')
            if doc.hardwareevent then
                print('This function consumes a hardware event to function. Hardware events include Event.UI.Input.Mouse.*.Down, Event.UI.Input.Mouse.*.Up, and Event.UI.Input.Mouse.Wheel.*.  ')
            end
            if doc.throttleGlobal then
                print('This function is subject to the "global" command queue.  ')
                doc.throttleGlobal=nil
            end
            if doc.deprecated == 'soft' then
                print('This function will be removed in the future.  ')
                doc.deprecated = nil
            elseif doc.deprecated == 'standard' then
                print('This function is deprecated and will be removed in the future. It should not be used.  ')
                doc.deprecated = nil
            end
            if doc.noSecureFrameAndEnvironment then
                print('Not permitted on a frame with the "restricted" SecureMode while the addon environment is secured.  ')
                doc.noSecureFrameAndEnvironment = nil
            end
            if doc.requireSecureFrameAndInsecureEnvironment then
                print('Permitted only on a frame with the "restricted" SecureMode while the addon environment is not secured.  ')
                doc.requireSecureFrameAndInsecureEnvironment = nil
            end
            if doc.interaction then
                print('Permitted only with the \''..doc.interaction..'\' interaction active.  ')
                doc.interaction = nil
            end
        end

        if doc.readable and not showReadable then
            doc.readable=nil
        end

        if doc.name then
            doc.name=nil
        end

        -- spit out anything that we didnt catch properly
        print_table(doc,'self.',true)
    end

    local function dump_md_for(pattern,hide)
        -- collect the matching names
        local set = {}
        for name in pairs(doc_names_map) do
            if name:match(pattern) then
                table.insert(set,name)
                doc_names_map[name]=nil
            end
        end
        -- sort the collected names
        table.casesort(set)
        -- now emit the docs
        for name in values(set) do
            Task.Yield()
            if not hide then 
                print('### '..name)
                dump_md_doc(Inspect.Documentation(name,true))
            end
        end
    end

    -- grab the types and censor them from the big list.
    -- they will be printed as an appendix
    local types_map = Inspect.Documentation('types',true)
    for typename in pairs(types_map) do
         doc_names_map[typename] = nil
    end
    doc_names_map['types']=nil

    -- Infer from the big doc what things are "Frames"
    local frame_types={}
    for name in pairs(doc_names_map) do
        local matchname = name:match('^(%w+):GetOwner')
        if matchname then
            table.insert(frame_types,matchname)
            --types_map[matchname]=nil
        end
    end
    local types = table.keys(types_map)
    table.casesort(types)
    table.casesort(frame_types)

    print('# RIFT API Documents')

    print('## Commands')
    dump_md_for('^Command%.')

    print('## Inspectors')
    dump_md_for('^Inspect%.')

    print('## Utilities')
    dump_md_for('^Utility%.')

    print('## UI')
    dump_md_for('^UI%.[^N][^a][^t]')

    print('## UI Frames')
    for frame in values(frame_types) do
        dump_md_for('^'..frame..':')
    end

    print('## Native UI')
    dump_md_for('^UI%.Native%.')

    print('## Events')
    dump_md_for('^Event%.')

    print('## UI Events')
    for frame in values(frame_types) do
        dump_md_for('^'..frame..'%.Event:')
    end

    local doc_names = table.keys(doc_names_map)
    table.casesort(doc_names)

    print('## Globals')
    for name in values(doc_names) do
        print('### '.. name)
        dump_md_doc(Inspect.Documentation(name,true))
    end

    print('## Types')
    for name in values(types) do
        print('### '..name)
        dump_md_doc(Inspect.Documentation(name,true))
    end

    print('(eof)')
end


Igor.Command['dumpall'] = function(param)
    if string.isempty(param) or param=='-help' then
        print("DumpAll prints all documentation to the console.")
        print("Usage:")
        print("/log")
        print("/igor dumpall md")
        print("/log")
    elseif param == 'md' then
        Task.Run(dump_md)
    end
end

--[[
Command.Event.Attach(
    Command.Slash.Register("x"),
    function (handle)
        Task.Run(dump_md)
    end,
    "Slash command")
]]    