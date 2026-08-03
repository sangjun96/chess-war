local ResultRenderer = require("result_renderer")

local StatusRenderer = {}
local teamName = { red = "RED", blue = "BLUE" }

local function teamColor(theme, team)
    return team == "red" and theme.redTeam or theme.blueTeam
end

local function teamSoftColor(theme, team)
    return team == "red" and theme.redTeamSoft or theme.blueTeamSoft
end

local function drawCard(theme, x, y, width, height, color, softColor)
    love.graphics.setColor(theme.shadow)
    love.graphics.rectangle("fill", x + 4, y + 6, width, height, 16, 16)
    love.graphics.setColor(theme.panel)
    love.graphics.rectangle("fill", x, y, width, height, 16, 16)
    love.graphics.setColor(softColor)
    love.graphics.rectangle("fill", x, y, 8, height, 16, 16)
    love.graphics.setColor(color)
    love.graphics.rectangle("fill", x, y + 14, 5, height - 28, 3, 3)
    love.graphics.setColor(theme.panelEdge)
    love.graphics.setLineWidth(1)
    love.graphics.rectangle("line", x, y, width, height, 16, 16)
end

local function commandPrompt(board, flow, aiStatus)
    if flow.activeTeam == "red" then return aiStatus or "RED AI PREPARING" end
    if board:isMoving() then return "MOVE MODE  -  choose a cyan tile" end
    if board:isAttacking() then return "ATTACK MODE  -  choose an orange tile" end
    if board:selectedCount() > 0 then return "UNIT READY  -  press Q for actions" end
    return "Select a blue piece to begin"
end

local function compactPrompt(board, flow, aiStatus)
    if flow.activeTeam == "red" then return aiStatus or "AI is planning" end
    if board:isMoving() then return "Tap a cyan destination" end
    if board:isAttacking() then return "Tap an orange target" end
    if board:selectedCount() > 0 then return "Tap selected unit again for actions" end
    return "Tap a blue unit"
end

local function isCompact()
    return love.graphics.getWidth() < 700 or love.graphics.getHeight() < 520
end

local function drawTurnCard(theme, fonts, board, flow, aiStatus)
    local x, y, width, height = 24, 24, 332, 174
    local color = teamColor(theme, flow.activeTeam)
    drawCard(theme, x, y, width, height, color, teamSoftColor(theme, flow.activeTeam))
    love.graphics.setColor(theme.text)
    love.graphics.setFont(fonts.title)
    love.graphics.print("CHESS WAR", x + 22, y + 17)
    love.graphics.setColor(theme.muted)
    love.graphics.setFont(fonts.body)
    love.graphics.printf(string.format("TURN %02d", flow.turnNumber), x + 225, y + 22, 82, "right")
    love.graphics.setColor(color)
    love.graphics.print("ACTIVE COMMAND", x + 22, y + 52)
    love.graphics.setFont(fonts.statusTitle)
    love.graphics.print(teamName[flow.activeTeam] .. " TEAM", x + 22, y + 68)
    love.graphics.setColor(color)
    love.graphics.circle("fill", x + 286, y + 81, 17)
    love.graphics.setColor(theme.panel)
    love.graphics.circle("fill", x + 286, y + 81, 8)
    love.graphics.setColor(theme.text)
    love.graphics.setFont(fonts.statusBody)
    love.graphics.print(flow.activeTeam == "red" and "AI TURN" or "YOUR TURN", x + 22, y + 108)
    love.graphics.setColor((board:isMoving() or board:isAttacking()) and theme.actionMove or theme.muted)
    love.graphics.printf(commandPrompt(board, flow, aiStatus), x + 22, y + 128, width - 44, "left")
    love.graphics.setColor(theme.panelEdge)
    love.graphics.line(x + 22, y + 151, x + width - 22, y + 151)
    love.graphics.setColor(theme.muted)
    love.graphics.setFont(fonts.body)
    love.graphics.print(string.format("%d unit%s selected", board:selectedCount(),
        board:selectedCount() == 1 and "" or "s"), x + 22, y + 157)
    love.graphics.printf(flow.activeTeam == "blue" and "Q  ACTIONS" or "AI CONTROL",
        x + 194, y + 157, 116, "right")
end

local function drawCompactCard(theme, fonts, board, flow, aiStatus)
    local width = math.max(176, love.graphics.getWidth() - 112)
    local x, y, height = 10, 10, 92
    local color = teamColor(theme, flow.activeTeam)
    drawCard(theme, x, y, width, height, color, teamSoftColor(theme, flow.activeTeam))
    love.graphics.setColor(theme.muted)
    love.graphics.setFont(fonts.body)
    love.graphics.print(string.format("TURN %02d", flow.turnNumber), x + 16, y + 13)
    love.graphics.printf(flow.activeTeam == "red" and "AI" or "YOU", x, y + 13, width - 14, "right")
    love.graphics.setColor(color)
    love.graphics.setFont(fonts.title)
    love.graphics.print(teamName[flow.activeTeam] .. " TEAM", x + 16, y + 31)
    love.graphics.setColor(theme.text)
    love.graphics.setFont(fonts.body)
    love.graphics.printf(compactPrompt(board, flow, aiStatus), x + 16, y + 55, width - 32, "left")
    love.graphics.setColor(theme.muted)
    love.graphics.printf(string.format("%d selected", board:selectedCount()), x + 16, y + 74, width - 32, "left")
end

function StatusRenderer.draw(theme, fonts, board, flow, _, aiStatus)
    if flow.finished then ResultRenderer.draw(theme, fonts, flow, drawCard)
    elseif isCompact() then drawCompactCard(theme, fonts, board, flow, aiStatus)
    else drawTurnCard(theme, fonts, board, flow, aiStatus) end
end

return StatusRenderer
