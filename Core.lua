local addon, lib = ...

-- is null or empty test
function string.isempty(s)
    return s == nil or s == "";
end

-- for val in values(array) do
function lib.values(t)
    local i = 0
    return function() i = i + 1; return t[i] end
end

-- split a string
function string:split(delimiter)
    local result = { }
    local from  = 1
    local delim_from, delim_to = string.find( self, delimiter, from  )
    while delim_from do
      table.insert( result, string.sub( self, from , delim_from-1 ) )
      from  = delim_to + 1
      delim_from, delim_to = string.find( self, delimiter, from  )
    end
    table.insert( result, string.sub( self, from  ) )
    return result
end

-- returns a dense array table containing the keys
-- passing it an array table produces an undefined result
function table.keys(self)
    local keys = {}
    for key in pairs(self) do
        keys[#keys+1]=key
    end
    return keys
end

-- sorts a table, but case insensitive.
function table.casesort(self)
    table.sort(self,function(a,b) return string.lower(a) < string.lower(b) end)
end

function table.isempty(self)
    return next(self)
end

-- various things use math.random. seed it with the os time to prevent determanisitic playback
math.randomseed( os.time() )


-- local foo = ['a','b']
-- if cond then foo = 'z' end
-- for i,j in ids(foo) do 
--   print(j)
function lib.ids(stringOrTable)
    if type(stringOrTable) == 'table' then
        return pairs(stringOrTable)
    end
    local i = 0
    return function()
        if i == 0 then
            i = i + 1
            return stringOrTable
        end
        return nil
    end
end


local table_meta = { __index = table }

lib.table = {}

setmetatable(lib.table,table_meta)

function lib.table.count(t)
    local count = 0
    for k,v in pairs(t) do
        count = count +1
    end
    return count
end

-- builds a new table containing all the elements that pass a test
function lib.table.filter(tab,cb)
    local result = {}
    for key,value in pairs(tab) do
        if cb(key,value) then
            result[key] = value
        end
    end
    return result
end

-- builds a new table array containing all the elements that pass a test
-- treats the table as an array.
function lib.table.ifilter(tab,cb)
    local result = {}
    for i,value in ipairs(tab) do
        if cb(i,value) then
            result[#result+1] = value
        end
    end
    return result
end

function lib.table.values(tab)
    local values = {}
    for key,value in pairs(tab) do
        values[#values+1]=value
    end
    return values
end