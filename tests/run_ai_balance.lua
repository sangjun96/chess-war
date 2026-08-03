local Runner = require("ai_match_runner")

local pairs = tonumber(arg[1]) or 2
local stronger = arg[2] or "hard"
local weaker = arg[3] or "medium"
local score, totalTurns = 0, 0

local function points(result, strongerTeam)
    if not result.winner then return 0.5 end
    return result.winner == strongerTeam and 1 or 0
end

print("pair,seed,strong_red_winner,strong_blue_winner,strong_score")
for index = 1, pairs do
    local seed = 2000 + index
    local asRed = Runner.play(stronger, weaker, seed, 300)
    local asBlue = Runner.play(weaker, stronger, seed, 300)
    local pairScore = points(asRed, "red") + points(asBlue, "blue")
    score, totalTurns = score + pairScore, totalTurns + asRed.turns + asBlue.turns
    print(table.concat({ index, seed, asRed.winner or "draw", asBlue.winner or "draw", pairScore }, ","))
end

local games = pairs * 2
print(string.format("summary stronger=%s weaker=%s score=%.1f/%d rate=%.1f%% avg_turns=%.1f",
    stronger, weaker, score, games, score / games * 100, totalTurns / games))
