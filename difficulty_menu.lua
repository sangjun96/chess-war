local DifficultyMenu = {}
DifficultyMenu.__index = DifficultyMenu

local levels = {
    { id = "easy", label = "EASY", detail = "Fast, forgiving decisions" },
    { id = "medium", label = "MEDIUM", detail = "Balanced tactical play" },
    { id = "hard", label = "HARD", detail = "Deeper, precise search" },
}

local function buttons()
    local width, height = love.graphics.getDimensions()
    local compact = height < 520
    local buttonWidth = math.min(300, width - (width < 560 and 32 or 80))
    local buttonHeight, gap = compact and 54 or 72, compact and 8 or 16
    local total = #levels * buttonHeight + (#levels - 1) * gap
    local firstY = compact and 112 or (height - total) / 2 + 36
    local result, x = {}, (width - buttonWidth) / 2
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
    local compact = height < 520
    love.graphics.setFont(compact and fonts.title or fonts.resultTitle)
    love.graphics.printf("CHESS WAR", 0, compact and 24 or 72, width, "center")
    love.graphics.setColor(self.theme.redTeam)
    love.graphics.setFont(fonts.statusBody)
    love.graphics.printf("RED AI  vs  BLUE PLAYER", 0, compact and 53 or 116, width, "center")
    love.graphics.setColor(self.theme.muted)
    love.graphics.printf("Choose the Red AI difficulty", 0, compact and 76 or 145, width, "center")
    for index, item in ipairs(buttons()) do
        local selected = index == self.selected
        love.graphics.setColor(selected and self.theme.redTeamSoft or self.theme.panel)
        love.graphics.rectangle("fill", item.x, item.y, item.width, item.height, 12, 12)
        love.graphics.setColor(selected and self.theme.redTeam or self.theme.panelEdge)
        love.graphics.setLineWidth(selected and 2 or 1)
        love.graphics.rectangle("line", item.x, item.y, item.width, item.height, 12, 12)
        love.graphics.setColor(self.theme.text)
        love.graphics.setFont(fonts.title)
        love.graphics.print(index .. "  " .. item.level.label, item.x + 20, item.y + (compact and 8 or 14))
        love.graphics.setColor(self.theme.muted)
        love.graphics.setFont(fonts.body)
        if not compact then love.graphics.print(item.level.detail, item.x + 20, item.y + 43) end
    end
    love.graphics.setColor(self.theme.muted)
    love.graphics.setFont(fonts.body)
    love.graphics.printf(compact and "Tap a difficulty" or
        "Press 1 / 2 / 3, then Enter  -  or click a difficulty", 0, height - 34, width, "center")
end

return DifficultyMenu
