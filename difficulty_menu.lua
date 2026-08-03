local DifficultyMenu = {}
DifficultyMenu.__index = DifficultyMenu

local levels = {
    { id = "easy", label = "EASY", detail = "Fast, forgiving decisions" },
    { id = "medium", label = "MEDIUM", detail = "Balanced tactical play" },
    { id = "hard", label = "HARD", detail = "Deeper, precise search" },
}

local function buttons()
    local width, height = love.graphics.getDimensions()
    local buttonWidth, buttonHeight, gap = math.min(260, width - 80), 72, 16
    local total = #levels * buttonHeight + (#levels - 1) * gap
    local result, x, firstY = {}, (width - buttonWidth) / 2, (height - total) / 2 + 36
    for index, level in ipairs(levels) do
        result[index] = { x = x, y = firstY + (index - 1) * (buttonHeight + gap),
            width = buttonWidth, height = buttonHeight, level = level }
    end
    return result
end

function DifficultyMenu.new(theme)
    return setmetatable({ theme = theme, active = true, selected = 2 }, DifficultyMenu)
end

function DifficultyMenu:show() self.active = true end
function DifficultyMenu:hide() self.active = false end

function DifficultyMenu:keypressed(key)
    local index = tonumber(key)
    if index and levels[index] then self.selected = index return end
    if key == "return" or key == "kpenter" then
        self.active = false
        return levels[self.selected].id
    end
end

function DifficultyMenu:mousepressed(x, y, button)
    if button ~= 1 then return end
    for index, item in ipairs(buttons()) do
        if x >= item.x and x <= item.x + item.width and y >= item.y and y <= item.y + item.height then
            self.selected, self.active = index, false
            return item.level.id
        end
    end
end


function DifficultyMenu:draw(fonts)
    if not self.active then return end
    local width, height = love.graphics.getDimensions()
    love.graphics.setColor(self.theme.background)
    love.graphics.rectangle("fill", 0, 0, width, height)
    love.graphics.setColor(self.theme.text)
    love.graphics.setFont(fonts.resultTitle)
    love.graphics.printf("CHESS WAR", 0, 72, width, "center")
    love.graphics.setColor(self.theme.redTeam)
    love.graphics.setFont(fonts.statusBody)
    love.graphics.printf("RED AI  vs  BLUE PLAYER", 0, 116, width, "center")
    love.graphics.setColor(self.theme.muted)
    love.graphics.printf("Choose the Red AI difficulty", 0, 145, width, "center")
    for index, item in ipairs(buttons()) do
        local selected = index == self.selected
        love.graphics.setColor(selected and self.theme.redTeamSoft or self.theme.panel)
        love.graphics.rectangle("fill", item.x, item.y, item.width, item.height, 12, 12)
        love.graphics.setColor(selected and self.theme.redTeam or self.theme.panelEdge)
        love.graphics.setLineWidth(selected and 2 or 1)
        love.graphics.rectangle("line", item.x, item.y, item.width, item.height, 12, 12)
        love.graphics.setColor(self.theme.text)
        love.graphics.setFont(fonts.title)
        love.graphics.print(index .. "  " .. item.level.label, item.x + 20, item.y + 14)
        love.graphics.setColor(self.theme.muted)
        love.graphics.setFont(fonts.body)
        love.graphics.print(item.level.detail, item.x + 20, item.y + 43)
    end
    love.graphics.setColor(self.theme.muted)
    love.graphics.setFont(fonts.body)
    love.graphics.printf("Press 1 / 2 / 3, then Enter  -  or click a difficulty", 0, height - 52, width, "center")
end

return DifficultyMenu
