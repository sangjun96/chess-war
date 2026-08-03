local profiles = {
    easy = {
        name = "EASY", depth = 1, qDepth = 0, beam = 12,
        nodeBudget = 1000, timeBudget = 0.08, regret = 220, temperature = 90, thinkDelay = 0.55,
    },
    medium = {
        name = "MEDIUM", depth = 2, qDepth = 1, beam = 20,
        nodeBudget = 8000, timeBudget = 0.25, regret = 60, temperature = 25, thinkDelay = 0.65,
    },
    hard = {
        name = "HARD", depth = 3, qDepth = 2, beam = 28,
        nodeBudget = 35000, timeBudget = 0.75, regret = 12, temperature = 4, thinkDelay = 0.85,
    },
}

local Profiles = {}

function Profiles.get(name)
    assert(profiles[name], "Unknown AI difficulty '" .. tostring(name) .. "'.")
    return profiles[name]
end

function Profiles.all() return profiles end

return Profiles
