-- bad global scope utility functions that are useful for debugging.


-- renders a value as a string doing some intelligent expanding.
function dstring(value)

    if type(value) == 'table' then return '{}'
    elseif type(value) == 'string' then return "'"..value.."''"
    end

    return tostring(value)
end


function dtable(tab,prefix)
    for key,value in pairs(tab) do
        print(prefix..key..' = '..dstring(value))
    end
end

function dvalue(value,name)
    if name then
        print(name..' = '..dstring(value))
    else
        print(dstring(value))
    end
    
    if type(value) == 'table' then
        local prefix = ''
        if name then prefix = name..'.' end
        dtable(value,prefix)
    end
end

-- deeply walks a table printing out all discoverable things including metatables
function fulldump(obj,prefix)

    local function dstring(value)
        if type(value) == 'table' then
            return '{} -- '..Utility.Type(value)
        elseif type(value) == 'string' then 
            return "'"..value.."'"
        end
        return tostring(value)
    end

    local function dumpTableRecursive(obj,prefix)
        for key,value in pairs(obj) do
            print(prefix..key..'='..dstring(value))
            if type(value) == 'table' then dumpTableRecursive(value,prefix..key..'.') end
        end
        local meta = getmetatable(obj)
        if meta then
            print(prefix..'!meta! = '..dstring(meta))
            dumpTableRecursive(meta,prefix..'!meta!.')
        end
    end

    if not prefix then
        prefix=''
    end
    print(prefix..' = '..dstring(obj))

    if type(obj) == 'table' then
        dumpTableRecursive(obj,prefix..'.')
    end
end