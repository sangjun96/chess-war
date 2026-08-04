local GameMode = {}

function GameMode.resolve(id)
    id = id or "medium"
    if id == "hard_vs_hard" then
        return { id = id, redDifficulty = "hard", blueDifficulty = "hard", automated = true }
    end
    return { id = id, redDifficulty = id, automated = false }
end

return GameMode
