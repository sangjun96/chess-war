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

local function commandPrompt(board, flow)
    if board:isMoving() then return "MOVE MODE  -  choose a cyan tile" end
    if board:isAttacking() then return "ATTACK MODE  -  choose an orange tile" end
    if board:selectedCount() > 0 then return "UNIT READY  -  press Q for actions" end
    return "Select a " .. flow.activeTeam .. " piece to begin"
end

local function drawTurnCard(theme, fonts, board, flow)
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
    love.graphics.setFont(fonts.body)
    love.graphics.print("ACTIVE COMMAND", x + 22, y + 52)
    love.graphics.setFont(fonts.statusTitle)
    love.graphics.print(teamName[flow.activeTeam] .. " TEAM", x + 22, y + 68)

    love.graphics.setColor(color)
    love.graphics.circle("fill", x + 286, y + 81, 17)
    love.graphics.setColor(theme.panel)
    love.graphics.circle("fill", x + 286, y + 81, 8)

    love.graphics.setColor(theme.text)
    love.graphics.setFont(fonts.statusBody)
    love.graphics.print("YOUR TURN", x + 22, y + 108)
    local statusColor = (board:isMoving() or board:isAttacking()) and theme.actionMove or theme.muted
    love.graphics.setColor(statusColor)
    love.graphics.printf(commandPrompt(board, flow), x + 22, y + 128, width - 44, "left")

    love.graphics.setColor(theme.panelEdge)
    love.graphics.line(x + 22, y + 151, x + width - 22, y + 151)
    love.graphics.setColor(theme.muted)
    love.graphics.setFont(fonts.body)
    love.graphics.print(string.format("%d unit%s selected", board:selectedCount(), board:selectedCount() == 1 and "" or "s"), x + 22, y + 157)
    love.graphics.printf("Q  ACTIONS", x + 194, y + 157, 116, "right")
end

local function drawResult(theme, fonts, flow)
    local width, height = love.graphics.getDimensions()
    local color = teamColor(theme, flow.winner)
    local cardWidth, cardHeight = math.min(530, width - 48), 284
    local x, y = (width - cardWidth) / 2, (height - cardHeight) / 2

    love.graphics.setColor(theme.overlay)
    love.graphics.rectangle("fill", 0, 0, width, height)
    drawCard(theme, x, y, cardWidth, cardHeight, color, teamSoftColor(theme, flow.winner))

    love.graphics.setColor(theme.victory)
    love.graphics.setFont(fonts.body)
    love.graphics.printf("BATTLE COMPLETE", x, y + 30, cardWidth, "center")
    love.graphics.setColor(theme.text)
    love.graphics.setFont(fonts.resultTitle)
    love.graphics.printf(teamName[flow.winner] .. " TEAM WINS", x, y + 56, cardWidth, "center")

    love.graphics.setColor(theme.victorySoft)
    love.graphics.circle("fill", x + cardWidth / 2, y + 144, 38)
    love.graphics.setColor(color)
    love.graphics.setLineWidth(3)
    love.graphics.circle("line", x + cardWidth / 2, y + 144, 27)
    love.graphics.line(x + cardWidth / 2 - 14, y + 152, x + cardWidth / 2 + 14, y + 152)
    love.graphics.line(x + cardWidth / 2, y + 126, x + cardWidth / 2, y + 158)

    love.graphics.setColor(theme.muted)
    love.graphics.setFont(fonts.statusBody)
    love.graphics.printf(flow.status, x + 42, y + 194, cardWidth - 84, "center")
    love.graphics.setColor(theme.panelEdge)
    love.graphics.line(x + 34, y + 235, x + cardWidth - 34, y + 235)
    love.graphics.setColor(theme.muted)
    love.graphics.setFont(fonts.body)
    love.graphics.printf("The board is now locked.", x, y + 246, cardWidth, "center")
end

function StatusRenderer.draw(theme, fonts, board, flow, statusMessage)
    if flow.finished then
        drawResult(theme, fonts, flow)
    else
        drawTurnCard(theme, fonts, board, flow)
    end
end

return StatusRenderer
