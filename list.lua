List = {}
function List:new(...)
    local o = { ... }
    self.__index = self
    self.__tostring = function(l)
        return "(" .. table.concat(l, " ") .. ")"
    end
    setmetatable(o, self)
    return o
end

function List:reverse()
    local result = List:new()
    for i = 1, #self do
        result[i] = self[#self - i + 1]
    end
    return result
end

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

function List:qsort()
    if #self == 0 then
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
    return self:qsort()
end

