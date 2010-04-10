require("luarocks.require")
require("luaspec")
require("komeetta")

List = komeetta.List
describe["A List"] = function()
    before = function()
        list = List:new()
        list_with_values = List:new(1, 2, 3, 4)
        list_from_table = List:new_from_table({ "foo", "bar" })
    end

    it["should return 0 length when it is empty"] = function()
        expect(list:length()).should_be(0)
    end

    it["should return the length of the list"] = function()
        expect(list_with_values:length()).should_be(4)
    end

    it["should return true from null when it is empty"] = function()
        expect(list:null()).should_be(true)
    end

    it["should allow items to be appended"] = function()
        expect(list:append(10)).should_be(List:new(10))
    end

    it["should allow items to be appended several times"] = function()
        expect(list:append(10):append(100):append(20)).should_be(
            List:new(10, 100, 20))
    end

    it['should have a string representation like "List(a b c d)"'] = function()
        expect(tostring(list)).should_be("List()")
        expect(tostring(list_with_values)).should_be("List(1 2 3 4)")
        expect(tostring(list_from_table)).should_be("List(foo bar)")
    end

    it["when cloned should contain the same values"] = function()
        expect(list_from_table:clone()).should_be(List:new("foo", "bar"))
    end

    it["should be reversable with the reverse function"] = function()
        expect(list_from_table:reverse()).should_be(List:new("bar", "foo"))
    end

    it["should have a function for performing operations on each element"] = function()
        local length = 0
        List:new(1,2,3):foreach()(function() 
            length = length + 1
        end)
        expect(length).should_be(3)
    end
    
    it["can be applied with a map function to return a new list"] = function()
        expect(list_from_table:map()(string.upper)).should_be(
            List:new("FOO", "BAR"))
    end

    it["can be filtered"] = function()
        expect(list_with_values:filter()(function(n) return n <= 2 end)).
            should_be(List:new(1, 2))
    end

    it["can be queried for its head"] = function()
        expect(list_with_values:head()).should_be(1) 
    end

    it["can be queried for its tail"] = function()
        expect(list_with_values:tail()).should_be(List:new(2, 3, 4)) 
    end

    it["can be concatenated with other lists"] = function()
        expect(list_with_values:concat(List:new("a", "b"), List:new(
            "foo", "bar"))).should_be(List:new(1, 2, 3, 4, "a", "b", "foo",
            "bar")) 
    end

    it["can be sliced"] = function()
        expect(list_with_values:slice(2, 3)).should_be(List:new(2, 3)) 
    end

    it["can be folded from right"] = function()
        expect(list_with_values:foldr(1)(
            function(a, b) return a * b end)).should_be(24) 
    end

    it["can be folded from left"] = function()
        expect(list_with_values:foldl(0)(
            function(a, b) return a - b end)).should_be(-10) 
    end

    it['can be sorted with "qsort"'] = function()
        expect(List:new(10, -4, 1, -1000):qsort()).should_be(
            List:new(-1000, -4, 1, 10)) 
    end

    it['can be sorted with "sort"'] = function()
        expect(List:new(10, -4, 1, -1000):sort()).should_be(
            List:new(-1000, -4, 1, 10)) 
    end

    it["can be queried for its values from the start of the list"] = function()
        expect(List:new(10, -4, 1, -1000):take(2)).should_be(List:new(10, -4)) 
    end

    it["is not mutable by its methods"] = function()
        expect(list_with_values).should_be(List:new(1, 2, 3, 4))
        list:reverse():append(100):reverse():append(-21):take(4):map()(
            function(n)
                return 100 * n end):filter()(
                    function(n) return n >= 100 end):concat(
                        List:new(1, 2, -100)):tail():slice(2, 5):sort():take(2)
        expect(list_with_values).should_be(List:new(1, 2, 3, 4))
    end

    it["has a method for calculating the product of its elements"] = 
        function()
        expect(list_with_values:product()).should_be(24)
    end
end
