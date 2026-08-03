local MoveGeneration = require("move_generation")
local State = require("ai_state")
local Threat = require("ai_threat")

local Evaluator = {}

local values = { pawn = 100, knight = 220, bishop = 260, rook = 420, queen = 520, king = 850 }

local function mobility(state, piece)
    local count = 0
    for _ in pairs(MoveGeneration.legalOffsets(state, piece)) do count = count + 1 end
    return math.min(count, 16) * 0.5
end

local function position(state, piece)
    local center = (state.size - 1) / 2
    local centerScore = state.size - math.abs(piece.column - center) - math.abs(piece.row - center)
    local advancement = 0
    if piece.kind == "pawn" then
        advancement = piece.team == "red" and piece.row or state.size - 1 - piece.row
    end
    return centerScore * 0.6 + advancement * 2.5
end

local function pawnShape(state, team)
    local score = 0
    for firstIndex, first in ipairs(state.pieces) do
        if first.team == team and first.kind == "pawn" then
            local neighbors = 0
            for secondIndex = firstIndex + 1, #state.pieces do
                local second = state.pieces[secondIndex]
                if second.team == team and second.kind == "pawn" then
                    local dc, dr = math.abs(first.column - second.column), math.abs(first.row - second.row)
                    if dc <= 1 and dr <= 1 then score, neighbors = score + 3, neighbors + 1 end
                end
            end
            if neighbors > 2 then score = score - (neighbors - 2) * 2 end
        end
    end
    return score
end

local function sideScore(state, team)
    local score = Threat.pressure(state, team) + pawnShape(state, team)
    for _, piece in ipairs(state.pieces) do
        if piece.team == team then
            local hpRatio = piece.hp / piece.maxHp
            score = score + values[piece.kind] * (0.4 + 0.6 * hpRatio)
                + mobility(state, piece) + position(state, piece)
        end
    end
    local danger = Threat.king(state, team)
    score = score - danger.damage * 160 - danger.attackers * 12
    if danger.lethal then score = score - 25000 end
    return score
end

function Evaluator.score(state, perspective)
    local opponent = perspective == "red" and "blue" or "red"
    if not State.hasKing(state, perspective) then return -1000000 end
    if not State.hasKing(state, opponent) then return 1000000 end
    return sideScore(state, perspective) - sideScore(state, opponent)
end

return Evaluator
