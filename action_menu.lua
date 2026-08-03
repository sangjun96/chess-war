local ActionMenu = {}
ActionMenu.__index = ActionMenu

local actions = {
    { name = "MOVE", angle = -math.pi / 2, enabled = true },
    { name = "ATTACK", angle = 0, enabled = false },
    { name = "GUARD", angle = math.pi / 2, enabled = false },
    { name = "CLOSE", angle = math.pi, enabled = true },
}

local function clamp(value, minimum, maximum)
    return math.max(minimum, math.min(maximum, value))
end

local function angleAt(x, y)
    if math.atan2 then return math.atan2(y, x) end
    if x == 0 then return y >= 0 and math.pi / 2 or -math.pi / 2 end
    local angle = math.atan(y / x)
    return x < 0 and angle + math.pi or angle
end

local function angleDistance(first, second)
    return math.abs((first - second + math.pi) % (2 * math.pi) - math.pi)
end

function ActionMenu.new(board, theme)
    return setmetatable({
        board = board,
        theme = theme,
        open = false,
        x = 0,
        y = 0,
        status = "Select a piece, then press Q to choose an action.",
    }, ActionMenu)
end

function ActionMenu:setStatus(message)
    self.status = message
end

function ActionMenu:close(message)
    self.open = false
    if message then self:setStatus(message) end
end

function ActionMenu:openAtMouse()
    local mouseX, mouseY = love.mouse.getPosition()
    self.x = clamp(mouseX, 116, love.graphics.getWidth() - 116)
    self.y = clamp(mouseY, 116, love.graphics.getHeight() - 116)
    self.open = true
    self:setStatus("Choose an action from the wheel.")
end

function ActionMenu:toggle()
    if self.open then
        self:close("Action menu closed. Press Q to open it again.")
    else
        if self.board:isMoving() then self.board:cancelMove() end
        self:openAtMouse()
    end
end

function ActionMenu:actionAt(x, y)
    local dx, dy = x - self.x, y - self.y
    local distance = math.sqrt(dx * dx + dy * dy)
    if distance < 32 or distance > 104 then return nil end
    local angle = angleAt(dx, dy)
    for _, action in ipairs(actions) do
        if angleDistance(angle, action.angle) <= math.pi / 4 then return action end
    end
end

function ActionMenu:perform(action)
    if action.name == "CLOSE" then
        self:close("Action menu closed. Press Q to open it again.")
    elseif action.name == "MOVE" then
        local started, message = self.board:beginMove()
        self:close(started and "Move: click a cyan tile to move the selection. Press Esc to cancel." or message)
    else
        self:close(action.name:sub(1, 1) .. action.name:sub(2):lower() .. " is not available yet.")
    end
end

function ActionMenu:mousepressed(x, y)
    if not self.open then return false end
    local action = self:actionAt(x, y)
    if action then self:perform(action) end
    return true
end

function ActionMenu:keypressed(key)
    if key == "q" then
        self:toggle()
        return true
    end
    if key == "escape" and self.open then
        self:close("Action menu closed.")
        return true
    end
    if key == "escape" and self.board:isMoving() then
        self.board:cancelMove()
        self:setStatus("Move cancelled. Press Q to choose an action.")
        return true
    end
    return false
end

function ActionMenu:draw(fonts)
    if not self.open then return end

    local radius = 104
    for _, action in ipairs(actions) do
        local color = action.enabled and self.theme.actionFill or self.theme.actionDisabled
        if action.name == "MOVE" then color = self.theme.actionMove end
        love.graphics.setColor(color)
        love.graphics.arc("fill", "pie", self.x, self.y, radius,
            action.angle - math.pi / 4 + 0.025, action.angle + math.pi / 4 - 0.025, 18)
        love.graphics.setColor(self.theme.actionEdge)
        love.graphics.setLineWidth(1)
        love.graphics.arc("line", "pie", self.x, self.y, radius,
            action.angle - math.pi / 4 + 0.025, action.angle + math.pi / 4 - 0.025, 18)

        local textX = self.x + math.cos(action.angle) * 66
        local textY = self.y + math.sin(action.angle) * 66
        love.graphics.setFont(fonts.body)
        love.graphics.setColor(action.enabled and self.theme.text or self.theme.muted)
        love.graphics.print(action.name, textX - fonts.body:getWidth(action.name) / 2, textY - 6)
    end

    love.graphics.setColor(self.theme.panel)
    love.graphics.circle("fill", self.x, self.y, 32)
    love.graphics.setColor(self.theme.actionEdge)
    love.graphics.setLineWidth(1)
    love.graphics.circle("line", self.x, self.y, 32)
    love.graphics.setColor(self.theme.text)
    love.graphics.setFont(fonts.body)
    love.graphics.print("ACTION", self.x - fonts.body:getWidth("ACTION") / 2, self.y - 6)
end

return ActionMenu
