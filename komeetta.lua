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
-- > list = List:new(1, "foo", 7)
-- > print(list)
-- List(1 foo 7)
-- ]]
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
-- > list = List:new({1, 2, 3})
-- > print(list)
-- List(1 2 3)
-- ]]
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
-- > list = List:new(1, 2, 3)
-- > cloned_list = list:clone()
-- > print(list, cloned_list)
-- List(1 2 3)      List(1 2 3)
-- ]]
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
-- > list = List:new(1, 2, 3)
-- > print(list:length())
-- 3
-- ]]
function List:length()
    return #self
end

--[[
-- Returns a copy of the given list reversed.
-- 
-- Usage:
-- > list = List:new(1, 2, 3)
-- > print(list:reverse())
-- List(3, 2, 1)
-- ]]
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
-- > List:new(1, 2, 3):foreach(print)
-- 1
-- 2
-- 3
-- ]]
function List:foreach(f)
    for i = 1, #self do
        f(self[i])
    end
end

--[[
-- Returns a copy of the list with 'f' applied to each of its members.
--
-- Usage:
-- > List:new(1,2,3):map(function(n) return 2 * n end)
-- List(2, 4, 6)
-- ]]
function List:map(f)
    local result = List:new()
    for i = 1, #self do
        result[i] = f(self[i])
    end
    return result
end

function List:filter(f)
    local result = List:new()
    for i = 1, #self do
        if f(self[i]) then
            result[#result + 1] = self[i]
        end
    end
    return result
end

function List:head()
    return self[1]
end

function List:tail()
    local result = List:new()
    for i = 2, #self do
        result[#result + 1] = self[i]
    end
    return result
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

function List:foldr(f, v)
    if self:null() then
        return v
    else
        return f(self:head(), self:tail():foldr(f, v))
    end
end

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

function List:sort()
    local result = self:clone()
    table.sort(result)
    return result
end

function List:take(n)
    local result = List:new()
    for i = 1, n do
        result[i] = self[i]
    end
    return result
end

-- TODO The following functions are not list functions.

function replicate(n, v)
    local result = List:new()
    for i = 1, n do
        result[#result + 1] = v
    end
    return result
end
