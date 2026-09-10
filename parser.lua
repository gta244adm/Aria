local Parser = {}

local function norm(s)
    s = s:lower()
    local map = {
        ["á"]="a",["à"]="a",["ã"]="a",["â"]="a",
        ["é"]="e",["ê"]="e",
        ["í"]="i",
        ["ó"]="o",["ô"]="o",["õ"]="o",
        ["ú"]="u",["ç"]="c"
    }

    for a,b in pairs(map) do
        s = s:gsub(a,b)
    end

    return s
end

local function trim(s)
    return (s:gsub("^%s+", ""):gsub("%s+$", ""))
end

function Parser.parse(input)
    local text = trim(norm(input))

    -- Memória
    local key, value = text:match("^lembre que ([^=]+)%s*=%s*(.+)$")
    if key and value then
        return {
            tool = "remember",
            args = { key = trim(key), value = trim(value) }
        }
    end

    local phrase = text:match("^lembre que (.+)$")
    if phrase then
        return {
            tool = "remember",
            args = { key = "nota", value = trim(phrase) }
        }
    end

    if text:find("esqueca tudo") or text:find("esquece tudo") then
        return { tool = "clear_memory", args = {} }
    end

    if text:find("o que voce lembra") then
        return { tool = "memory_dump", args = {} }
    end

    -- Players próximos
    if text:find("player") and
       (text:find("perto") or text:find("proximo") or text:find("proximos")) then
        local radius = tonumber(text:match("(%d+)%s*m")) or 100
        return {
            tool = "nearest_players",
            args = { radius = radius }
        }
    end

    -- Player mais próximo
    if text:find("player") and text:find("mais perto") then
        return {
            tool = "nearest_player",
            args = {}
        }
    end

    -- Procurar player
    local target = text:match("encontre o player%s+(.+)")
        or text:match("procure o player%s+(.+)")
        or text:match("ache o player%s+(.+)")
        or text:match("onde esta o player%s+(.+)")
        or text:match("onde esta%s+(.+)")

    if target then
        return {
            tool = "find_player",
            args = { name = trim(target) }
        }
    end

    -- Navegação
    target = text:match("me leve ate%s+(.+)")
        or text:match("va ate%s+(.+)")
        or text:match("vai ate%s+(.+)")
        or text:match("navegue ate%s+(.+)")

    if target then
        return {
            tool = "navigate_to_player",
            args = { name = trim(target) }
        }
    end

    -- Destaque
    target = text:match("mostre somente%s+(.+)")
        or text:match("mostre apenas%s+(.+)")
        or text:match("destaque%s+(.+)")

    if target then
        return {
            tool = "highlight_player",
            args = { name = trim(target) }
        }
    end

    -- Informações
    target = text:match("informacoes do player%s+(.+)")
        or text:match("informacao do player%s+(.+)")
        or text:match("dados do player%s+(.+)")

    if target then
        return {
            tool = "player_info",
            args = { name = trim(target) }
        }
    end

    -- Waypoint em coordenadas
    local x,y,z = text:match("waypoint%s+(-?[%d%.]+)%s+(-?[%d%.]+)%s+(-?[%d%.]+)")
    if x and y and z then
        return {
            tool = "set_waypoint",
            args = {
                x = tonumber(x),
                y = tonumber(y),
                z = tonumber(z)
            }
        }
    end

    -- Posição do próprio player
    if text:find("minha posicao") or text:find("onde eu estou") then
        return { tool = "my_position", args = {} }
    end

    return nil
end

return Parser
