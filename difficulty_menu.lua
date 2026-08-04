local DifficultyMenu = {}
DifficultyMenu.__index = DifficultyMenu

local levels = {
    { id = "easy", label = "EASY", detail = "Fast, forgiving decisions" },
    { id = "medium", label = "MEDIUM", detail = "Balanced tactical play" },
    { id = "hard", label = "HARD", detail = "Deeper, precise search" },
    { id = "hard_vs_hard", label = "HARD vs HARD", detail = "Watch both AI armies battle automatically" },
}

local function buttons()
    local width, height = love.graphics.getDimensions()
    local compact = height < 520
    local buttonWidth = math.min(300, width - (width < 560 and 32 or 80))
    local gap = compact and 4 or 12
    local buttonHeight = compact
        and math.min(54, math.max(30, math.floor((height - 150 - (#levels - 1) * gap) / #levels)))
        or 64
    local total = #levels * buttonHeight + (#levels - 1) * gap
    local firstY = compact and 88 or (height - total) / 2 + 36
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
    love.graphics.printf("CHOOSE BATTLE MODE", 0, compact and 50 or 116, width, "center")
    love.graphics.setColor(self.theme.muted)
    love.graphics.printf("Play Blue or watch an AI battle", 0, compact and 68 or 145, width, "center")
    for index, item in ipairs(buttons()) do
        local selected = index == self.selected
        love.graphics.setColor(selected and self.theme.redTeamSoft or self.theme.panel)
        love.graphics.rectangle("fill", item.x, item.y, item.width, item.height, 12, 12)
        love.graphics.setColor(selected and self.theme.redTeam or self.theme.panelEdge)
        love.graphics.setLineWidth(selected and 2 or 1)
        love.graphics.rectangle("line", item.x, item.y, item.width, item.height, 12, 12)
        love.graphics.setColor(self.theme.text)
        love.graphics.setFont(fonts.title)
        love.graphics.print(index .. "  " .. item.level.label, item.x + 20, item.y + (compact and 5 or 10))
        love.graphics.setColor(self.theme.muted)
        love.graphics.setFont(fonts.body)
        if not compact then love.graphics.print(item.level.detail, item.x + 20, item.y + 37) end
    end
    love.graphics.setColor(self.theme.muted)
    love.graphics.setFont(fonts.body)
    love.graphics.printf(compact and "Tap a mode" or
        "Press 1 / 2 / 3 / 4, then Enter  -  or click a mode", 0, height - 34, width, "center")
end

return DifficultyMenu
