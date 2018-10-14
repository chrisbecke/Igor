-- is null or empty test
function string.isempty(s)
    return s == nil or s == "";
end

-- for val in values(array) do
function values(t)
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
