require("luarocks.require")
require("luaspec")
require("komeetta")

List = komeetta.List
describe["A List"] = function()
    before = function()
        list = List:new()
    end

    it["should return 0 length when it is empty"] = function()
        expect(list:length()).should_be(0)
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

    it["should not be modified when values are appended"] = function()
        expect(list:append(100)).should_be(List:new(100))
        expect(list).should_be(List:new())
    end

end
