local Formations = {}

local function adjacent(first, second)
    return math.abs(first.column - second.column) <= 1
        and math.abs(first.row - second.row) <= 1
end

local function componentFrom(pawns, first, visited)
    local result, queue = {}, { first }
    visited[first] = true
    while #queue > 0 do
        local pawn = table.remove(queue, 1)
        result[#result + 1] = pawn
        for _, other in ipairs(pawns) do
            if not visited[other] and adjacent(pawn, other) then
                visited[other] = true
                queue[#queue + 1] = other
            end
        end
    end
    return result
end

local function idsFor(pieces)
    local ids = {}
    for _, piece in ipairs(pieces) do ids[#ids + 1] = piece.id end
    table.sort(ids)
    return ids
end

local function add(groups, seen, pieces)
    if #pieces < 2 then return end
    local ids = idsFor(pieces)
    local key = table.concat(ids, ",")
    if not seen[key] then seen[key], groups[#groups + 1] = true, ids end
end

local function nearest(component, anchor, count)
    local ordered = {}
    for _, pawn in ipairs(component) do ordered[#ordered + 1] = pawn end
    table.sort(ordered, function(a, b)
        local da = math.abs(a.column - anchor.column) + math.abs(a.row - anchor.row)
        local db = math.abs(b.column - anchor.column) + math.abs(b.row - anchor.row)
        return da == db and a.id < b.id or da < db
    end)
    local result = {}
    for index = 1, math.min(count, #ordered) do result[index] = ordered[index] end
    return result
end

function Formations.groups(state, team)
    local pawns, groups, seen, visited = {}, {}, {}, {}
    for _, piece in ipairs(state.pieces) do
        if piece.team == team and piece.kind == "pawn" then pawns[#pawns + 1] = piece end
    end
    table.sort(pawns, function(a, b) return a.id < b.id end)
    for _, pawn in ipairs(pawns) do
        if not visited[pawn] then
            local component = componentFrom(pawns, pawn, visited)
            add(groups, seen, component)
            for _, count in ipairs({ 2, 4, 8 }) do
                if #component >= count then
                    for anchorIndex = 1, #component, count do
                        add(groups, seen, nearest(component, component[anchorIndex], count))
                    end
                end
            end
        end
    end
    return groups
end

return Formations
