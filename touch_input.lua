local TouchInput = {}
TouchInput.__index = TouchInput

local function touches(state)
    local result = {}
    for id, point in pairs(state.points) do
        result[#result + 1] = { id = id, x = point.x, y = point.y }
    end
    return result
end

local function gesture(points)
    if #points < 2 then return end
    local first, second = points[1], points[2]
    local dx, dy = second.x - first.x, second.y - first.y
    return (first.x + second.x) / 2, (first.y + second.y) / 2,
        math.sqrt(dx * dx + dy * dy)
end

function TouchInput.new(input)
    return setmetatable({ input = input, points = {} }, TouchInput)
end

function TouchInput:pressed(id, x, y)
    self.points[id] = { x = x, y = y }
    local active = touches(self)
    if #active == 1 then
        self.input:touchPointerPressed(x, y)
    elseif #active == 2 then
        self.input:cancelPointer()
        self.midX, self.midY, self.distance = gesture(active)
    end
end

function TouchInput:moved(id, x, y, dx, dy)
    if not self.points[id] then return end
    self.points[id].x, self.points[id].y = x, y
    local active = touches(self)
    if #active < 2 then
        self.input:mousemoved(x, y, dx, dy)
        return
    end

    local midX, midY, distance = gesture(active)
    if self.distance and self.distance > 0 then
        self.input.camera:zoomScaleAt(midX, midY, distance / self.distance)
        self.input.camera:pan(midX - self.midX, midY - self.midY)
    end
    self.midX, self.midY, self.distance = midX, midY, distance
end

function TouchInput:released(id, x, y)
    local active = touches(self)
    if #active == 1 and self.points[id] then self.input:touchPointerReleased(x, y) end
    self.points[id] = nil
    if #touches(self) < 2 then self.midX, self.midY, self.distance = nil, nil, nil end
end

return TouchInput
