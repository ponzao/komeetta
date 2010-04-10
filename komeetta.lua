--[[
-- komeetta - Vesa Marttila (vtmarttila@gmail.com)
--
-- Functional style list and functions. None of the functions alter the given
-- list. For example list:reverse() returns a new list and doesn't touch the
-- original one. The lists are currently accessible via other methods though
-- (e.g. list.foo = 100).
--
-- None of the methods take functions as parameters, they return functions
-- that take functions as parameters (e.g. list:map()(string.upper)).
--
-- Usage:
-- > require("komeetta")
-- > list = komeetta.List:new(1, 2, 3, 4)
-- > print(list:reverse():map()(function(n) return 2 * n end))
-- List(8 6 4 2)
-- > print(list)
-- List(1 2 3 4)
--]]
local ipairs = ipairs
local setmetatable = setmetatable
local getmetatable = getmetatable
local table = table
local print = print
local error = error

module("komeetta")

List = {}
setmetatable(List, { __call = function(list, ...)
    return list:new(...)
end})

function List:new(...)
    local o = { ... }
    self.__index = self
    self.__tostring = function(l)
        return "List(" .. table.concat(l, " ") .. ")"
    end
    self.__eq = function(a, b)
        if #a ~= #b then
            return false
        end
        for i = 1, #a do
            if a[i] ~= b[i] then
                return false
            end
        end
        return true
    end
    self.__call = getmetatable(List).__call
    setmetatable(o, self)
    return o
end

function List:new_from_table(t)
    local result = List:new()
    for i = 1, #t do
        result[#result + 1] = t[i]
    end
    return result
end

function List:clone()
    local result = List:new()
    for i = 1, #self do
        result[i] = self[i]
    end
    return result
end

function List:length()
    return #self
end

function List:reverse()
    return self:foldl(List:new())(function(list, element)
        return list:prepend(element)
    end)
end

function List:foreach()
    return function(f)
        for i = 1, #self do
            f(self[i])
        end
    end
end

function List:map()
    local result = List:new()
    return function(f)
        for i = 1, #self do
            result[i] = f(self[i])
        end
        return result
    end
end

function List:filter()
    local result = List:new()
    return function(f)
        for i = 1, #self do
            if f(self[i]) then
                result[#result + 1] = self[i]
            end
        end
        return result
    end
end

function List:head()
    return self[1]
end

function List:tail()
    return self:slice(2, self:length())
end

function List:append(v)
    return self:concat(List:new(v))
end

function List:prepend(v)
    return List:new(v):concat(self)
end

function List:concat(...)
    local result = List:new()
    for i = 1, #self do
        result[#result + 1] = self[i]
    end
    for _, l in ipairs({...}) do
        for i = 1, #l do
            result[#result + 1] = l[i]
        end
    end
    return result
end

function List:null()
    return #self == 0
end

function List:slice(from, to)
    local result = List:new()
    for i = from, to do
        result[#result + 1] = self[i]
    end
    return result;
end

function List:foldr(v)
    return function(f)
        if self:null() then
            return v
        else
            return f(self:head(), self:tail():foldr(v)(f))
        end
    end
end

function List:foldl(v)
    return function(f)
        if self:null() then
            return v
        else
            return self:tail():foldl(f(v, self:head()))(f)
        end
    end
end

function List:qsort()
    if self:null() then
        return List:new()
    else
        local pivot = self:head()
        local left   = self:tail():filter()(lt(pivot)):qsort()
        local middle = List:new(pivot)
        local right  = self:tail():filter()(ge(pivot)):qsort()
        return left:concat(middle, right)
    end
end

function List:sort()
    local result = self:clone()
    table.sort(result)
    return result
end

function List:take(n)
    return self:slice(1, n)
end

function List:product()
    return self:foldr(1)(function(a, b) return a * b end)
end

function replicate(n, v)
    local result = List:new()
    for i = 1, n do
        result[#result + 1] = v
    end
    return result
end

function lt(a)
    return function(b)
        return a > b
    end
end

function le(a)
    return function(b)
        return a >= b
    end
end

function eq(a)
    return function(b)
        return a == b
    end
end

function ge(a)
    return function(b)
        return a <= b
    end
end

function gt(a)
    return function(b)
        return a < b
    end
end

