local Memory = require("ai_memory")
local Profiles = require("ai_profiles")
local Random = require("ai_random")
local Search = require("ai_search")
local Simulator = require("ai_simulator")
local StartingPieces = require("starting_pieces")
local State = require("ai_state")

local MatchRunner = {}

function MatchRunner.play(redDifficulty, blueDifficulty, seed, maxTurns)
    local state = State.snapshot({ size = 16, pieces = StartingPieces.create(16) }, "red")
    local profiles = { red = Profiles.get(redDifficulty), blue = Profiles.get(blueDifficulty) }
    local random = { red = Random.new(seed), blue = Random.new(seed + 104729) }
    local memory = { red = Memory.new(), blue = Memory.new() }
    local stats = { turns = 0, moves = 0, skills = 0, formations = 0, nodes = 0 }
    for turn = 1, maxTurns or 300 do
        local team = state.activeTeam
        local search = Search.new(state, team, profiles[team], random[team], memory[team])
        local action, info = search:run()
        if not action then stats.draw, stats.reason = true, "no_action" return stats end
        local nextState = Simulator.apply(state, action)
        if not nextState then stats.draw, stats.reason = true, "illegal_action" return stats end
        memory[team]:record(action)
        stats.turns, stats.nodes = turn, stats.nodes + info.nodes
        if action.type == "move" then stats.moves = stats.moves + 1 else stats.skills = stats.skills + 1 end
        if #action.actorIds > 1 then stats.formations = stats.formations + 1 end
        state = nextState
        local winner = Simulator.winner(state)
        if winner then stats.winner = winner return stats end
    end
    stats.draw, stats.reason = true, "turn_limit"
    return stats
end

return MatchRunner
