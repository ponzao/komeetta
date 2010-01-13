--[[
-- komeetta - Vesa Marttila (vesa.marttila@helsinki.fi)
--
-- Functional style list and functions. None of the functions alter the given
-- list. For example list:reverse() returns a new list and doesn't touch the
-- original one. The lists are currently accessible via other methods though
-- (e.g. list.foo = 100).
--
-- Usage:
-- > require("komeetta")
-- > list = komeetta.List:new(1, 2, 3, 4)
-- > print(list:reverse():map(function(n) return 2 * n end))
-- List(8 6 4 2)
-- > print(list)
-- List(1 2 3 4)
--]]
local ipairs = ipairs
local setmetatable = setmetatable
local table = table
local print = print
local error = error

module("komeetta")

List = {}

--[[
-- Creates a new list with given parameters.
--
-- Usage:
-- > list = komeetta.List:new(1, "foo", 7)
-- > print(list)
-- List(1 foo 7)
--]]
function List:new(...)
    local o = { ... }
    self.__index = self
    self.__tostring = function(l)
        return "List(" .. table.concat(l, " ") .. ")"
    end
    setmetatable(o, self)
    return o
end

--[[
-- Creates a new list from a table given as a parameter. Undefined behavior
-- if values in table are stored with as key-value pairs.
--
-- Usage:
-- > list = komeetta.List:new({1, 2, 3})
-- > print(list)
-- List(1 2 3)
--]]
function List:new_from_table(t)
    local result = List:new()
    for i = 1, #t do
        result[#result + 1] = t[i] 
    end
    return result
end

--[[
-- Clones the existing list.
--
-- Usage:
-- > list = komeetta.List:new(1, 2, 3)
-- > cloned_list = list:clone()
-- > print(list, cloned_list)
-- List(1 2 3)      List(1 2 3)
--]]
function List:clone()
    local result = List:new()
    for i = 1, #self do
        result[i] = self[i]
    end
    return result
end

--[[
-- Returns the length of the list.
--
-- Usage:
-- > list = komeetta.List:new(1, 2, 3)
-- > print(list:length())
-- 3
--]]
function List:length()
    return #self
end

--[[
-- Returns a copy of the given list reversed.
-- 
-- Usage:
-- > list = komeetta.List:new(1, 2, 3)
-- > print(list:reverse())
-- List(3, 2, 1)
--]]
function List:reverse()
    local result = List:new()
    for i = 1, #self do
        result[i] = self[#self - i + 1]
    end
    return result
end

--[[
-- Applies the given function to all the members in the list.
--
-- Usage:
-- > komeetta.List:new(1, 2, 3):foreach(print)
-- 1
-- 2
-- 3
--]]
function List:foreach(f)
    for i = 1, #self do
        f(self[i])
    end
end

--[[
-- Returns a copy of the list with 'f' applied to each of its members.
--
-- Usage:
-- > komeetta.List:new(1,2,3):map(function(n) return 2 * n end)
-- List(2, 4, 6)
--]]
function List:map(f)
    local result = List:new()
    for i = 1, #self do
        result[i] = f(self[i])
    end
    return result
end

--[[
-- Returns a list without the filtered values.
--
-- Usage:
-- > print(komeetta.List:new(1, 2, 3, 4):filter(function(n) return n <= 2 end))
-- List(1 2)
--]]
function List:filter(f)
    local result = List:new()
    for i = 1, #self do
        if f(self[i]) then
            result[#result + 1] = self[i]
        end
    end
    return result
end

--[[
-- Returns the first value in the list.
--
-- Usage:
-- > print(komeetta.List:new(1, 2, 3):head())
-- 1
--]]
function List:head()
    return self[1]
end

--[[
-- Returns a new list starting from the second value in the list.
--
-- Usage:
-- > print(komeetta.List:new(1, 2, 3):tail())
-- List(2 3)
--]]
function List:tail()
    local result = List:new()
    for i = 2, #self do
        result[#result + 1] = self[i]
    end
    return result
end

--[[
-- Appends a value into the end of the list.
--
-- Usage:
-- > print(komeetta.List:new(1, 2, 3):append(4))
-- List(1 2 3 4)
--]]
function List:append(v)
    local result = self:clone()
    result[#result + 1] = v
    return result
end

--[[
-- Returns a new list with the given list arguments concatenated into the
-- original one.
--
-- Usage:
-- > a = komeetta.List:new(1, 2)
-- > b = komeetta.List:new(3, 4)
-- > c = komeetta.List:new(-4, 10)
-- > print(a:concat(b, c))
-- List(1 2 3 4 -4 10)
--]]
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

--[[
-- Returns true if list has no values.
--
-- Usage:
-- > print(komeetta.List:new():null())
-- true
--]]
function List:null()
    return #self == 0
end

--[[
-- Returns a "slice" of the list. First argument is the first index and second
-- the last index to include in the list.
--
-- Usage:
-- > print(komeetta.List:new(1, 199, 87, -4):slice(2, 3))
-- List(199 87)
--]]
function List:slice(from, to)
    local result = List:new()
    for i = from, to do
        result[#result + 1] = self[i]
    end
    return result;
end

--[[
-- Returns the value after performing folding from right on the given list.
-- First argument is the function to apply and second the default value.
--
-- Usage:
-- > print(komeetta.List:new(1, 2, 3, 4, 5):foldr(function(a, b) return a * b
--                                                end, 1))
-- 120
--]]
function List:foldr(f, v)
    if self:null() then
        return v
    else
        return f(self:head(), self:tail():foldr(f, v))
    end
end

--[[
-- Sorts the list with quicksort. This implementation is not fast and I 
-- recommend using "sort" instead.
--
-- Usage:
-- > print(komeetta.List:new(10, -4, 1):qsort())
-- List(-4 1 10)
--]]
function List:qsort()
    if self:null() then
        return List:new()
    else
        return self:tail():filter(function(x)
                    return self:head() > x end):
                        qsort():concat(List:new(self:head()):
                        concat(self:tail():
                        filter(function(x) return self:head() <= x end):
                        qsort()))
    end
end
--
--[[
-- Sorts the list with Lua's built in sort.
--
-- Usage:
-- > print(komeetta.List:new(10, -4, 1):sort())
-- List(-4 1 10)
--]]
function List:sort()
    local result = self:clone()
    table.sort(result)
    return result
end

--[[
-- Returns a list consisting of n-amount of values starting from the list head.
--
-- Usage:
-- > print(komeetta.List:new(1, 2, 3):take(2))
-- List(1 2)
--]]
function List:take(n)
    local result = List:new()
    for i = 1, n do
        result[i] = self[i]
    end
    return result
end

--[[
-- Creates a list consisting of the second argument. The amount of values is
-- based on the size of the first argument.
--
-- Usage:
-- > komeetta.replicate(3, "foo")
-- List(foo foo foo)
--]]
function replicate(n, v)
    local result = List:new()
    for i = 1, n do
        result[#result + 1] = v
    end
    return result
end

