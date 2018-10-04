local function dumpall()
    local names = Inspect.Documentation()
  
    function print_docs_with_pattern(pattern)
      local count=0
      for name in pairs(names) do
        -- print('### '..name)
        ConsiderYield()
  
        if name:match(pattern) then
          -- print this doc
          count = count+1
          -- remove it from the table
          names[name] = nil
        end
      end
      print('Entries: ' .. tostring(count))
    end
  
    function print_dump(obj)
      for key,value in pairs(obj) do
        print(tostring(key) ..'= '.. to_string(value))
      end
    end
  
    function print_doc(typename)
      print('### '.. typename)
      local typeinfo = Inspect.Documentation(typename,true)
      print_dump(typeinfo)
    end
  
    print('## Types')
    local types = Inspect.Documentation('types',true)
    for typename in pairs(types) do
      print_doc(typename)
      names[typename] = nil
    end
    names['types']=nil
  
    print('## Commands')
    print_docs_with_pattern('^Command%.')
  
    print('## Events')
    print_docs_with_pattern('^Event%.')
  
    print('## Inspectors')
    print_docs_with_pattern('^Inspect%.')
  
    print('## Native Frames')
    print_docs_with_pattern('^UI%.Native')
  
    print('## UI')
    print_docs_with_pattern('^Canvas:')
    print_docs_with_pattern('^Frame:')
    print_docs_with_pattern('^Layout:')
    print_docs_with_pattern('^Mask:')
    print_docs_with_pattern('^RiftButton:')
    print_docs_with_pattern('^RiftSlider:')
    print_docs_with_pattern('^RiftCheckbox:')
    print_docs_with_pattern('^RiftWindow:')
    print_docs_with_pattern('^RiftWindowBorder:')
    print_docs_with_pattern('^RiftWindowContent:')
    print_docs_with_pattern('^RiftTextfield:')
    print_docs_with_pattern('^RiftScrollbar:')
    print_docs_with_pattern('^Text:')
    print_docs_with_pattern('^Texture:')
  
    print('## UI Events')
    print_docs_with_pattern('%.Event:')
  
    print('## Natives')
    print_docs_with_pattern('^Native:')
  
    print('## UI')
    print_docs_with_pattern('^UI%.')
  
    -- Dump Utilities
    print('## Utilities')
    print_docs_with_pattern('^Utility%.')
  
    -- 
    print('## Other / Globals')
    for name in pairs(names) do
      print(name ..'= '..to_string(Inspect.Documentation(name)))
    end
end

local function dump_doc(doc,indent)
    local lastline = nil
    for key,value in pairs(doc) do
        if lastline then 
            print(lastline..',')
        end
        lastline = indent.."'"..key.."':"
        if type(value)=='nil' then
            lastline = lastline..'nil'
        elseif type(value)=='number' then
            lastline = lastline..tostring(value)
        elseif type(value)=='function' then
            lastline = lastline..tostring(value)
        elseif type(value)=='string' then
            lastline = lastline.."'"..tostring(value).."'"
        elseif type(value)=='table' then
            print(lastline..'{')
            dump_doc(value,indent..'\t')
            lastline=indent..'}'
        else
            lastline=lastline..'('..type(value)..')'
        end
    end
    if lastline then 
        print(lastline)
    end
end

local function dumpcore_json()
    local doc_names = Inspect.Documentation()

    local prefix = '{'
    for name in pairs(doc_names) do
        print(prefix)
        Task.Yield()
        print('\t\''..name..'\': {')
        dump_doc(Inspect.Documentation(name,true),'\t\t')
        prefix = '\t},'
    end
    print('\t}')
    print('}')
end