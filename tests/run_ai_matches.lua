local Runner = require("ai_match_runner")

local games = tonumber(arg[1]) or 1
local redDifficulty = arg[2] or "medium"
local blueDifficulty = arg[3] or "easy"
local format = arg[4] or "jsonl"
local wins = { red = 0, blue = 0, draw = 0 }

if format == "csv" then print("game,seed,red,blue,winner,turns,nodes,moves,skills,formations") end
for game = 1, games do
    local seed = 1000 + game
    local result = Runner.play(redDifficulty, blueDifficulty, seed, 300)
    local winner = result.winner or "draw"
    wins[winner] = wins[winner] + 1
    if format == "csv" then
        print(table.concat({ game, seed, redDifficulty, blueDifficulty, winner, result.turns,
            result.nodes, result.moves, result.skills, result.formations }, ","))
    else
        print(string.format('{"game":%d,"seed":%d,"red":"%s","blue":"%s",'
            .. '"winner":"%s","turns":%d,"nodes":%d,"formations":%d}',
            game, seed, redDifficulty, blueDifficulty, winner, result.turns,
            result.nodes, result.formations))
    end
end
print(string.format("summary red=%d blue=%d draw=%d", wins.red, wins.blue, wins.draw))
