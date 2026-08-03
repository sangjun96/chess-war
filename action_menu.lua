local Renderer = require("action_menu_renderer")

local ActionMenu = {}
ActionMenu.__index = ActionMenu

local actions = {
    { name = "MOVE", angle = -math.pi / 2, enabled = true },
    { name = "ATTACK", angle = 0, enabled = true },
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

function ActionMenu.new(board, flow, theme)
    return setmetatable({
        board = board,
        flow = flow,
        theme = theme,
        open = false,
        x = 0,
        y = 0,
        status = "Select a piece, then press Q to choose an action.",
    }, ActionMenu)
end

function ActionMenu:setStatus(message) self.status = message end

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
    if not self.flow:isPlaying() then
        self:close(self.flow.status)
        return
    end
    if self.open then
        self:close("Action menu closed. Press Q to open it again.")
    else
        if self.board:isMoving() then self.board:cancelMove() end
        if self.board:isAttacking() then self.board:cancelAttack() end
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
        local started, message = self.flow:beginMove()
        self:close(started and "Move: click a cyan tile to move the selection. Press Esc to cancel." or message)
    elseif action.name == "ATTACK" then
        local _, message = self.flow:beginAttack()
        self:close(message)
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
    if key == "escape" and self.board:isAttacking() then
        self.board:cancelAttack()
        self:setStatus("Skill cancelled. Press Q to choose an action.")
        return true
    end
    return false
end

function ActionMenu:draw(fonts) return Renderer.draw(self, fonts, actions) end

return ActionMenu
