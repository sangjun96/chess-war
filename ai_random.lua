local Random = {}
Random.__index = Random

function Random.new(seed)
    return setmetatable({ state = math.max(1, math.floor(seed or 1) % 2147483647) }, Random)
end

function Random:next()
    self.state = self.state * 16807 % 2147483647
    return (self.state - 1) / 2147483646
end

return Random
