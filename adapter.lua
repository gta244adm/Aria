-- ADAPTADOR DO JOGO
--
-- Este arquivo é a única parte que precisa conhecer a API real
-- do jogo/mod. As funções abaixo são contratos, não APIs fictícias.

local Game = {}

local function distance(a,b)
    local ax, ay, az = Game.getPosition(a)
    local bx, by, bz = Game.getPosition(b)

    local dx = ax - bx
    local dy = ay - by
    local dz = az - bz

    return math.sqrt(dx*dx + dy*dy + dz*dz)
end

function Game.getLocalPlayer()
    -- IMPLEMENTE COM A API DO SEU JOGO.
    -- Exemplo:
    -- return jogo:getLocalPlayer()
    return nil
end

function Game.getPlayers()
    -- IMPLEMENTE COM A API DO SEU JOGO.
    -- Deve retornar:
    -- { player1, player2, ... }
    return {}
end

function Game.getPosition(player)
    -- IMPLEMENTE COM A API DO SEU JOGO.
    -- return x, y, z
    assert(player, "player é obrigatório")
    return player.x or 0, player.y or 0, player.z or 0
end

function Game.findPlayer(name)
    if not name or name == "" then return nil end

    local wanted = name:lower()

    for _, player in ipairs(Game.getPlayers()) do
        local playerName = tostring(player.name or ""):lower()

        if playerName == wanted then
            return player
        end
    end

    return nil
end

function Game.getPlayersWithin(origin, radius)
    local found = {}

    for _, player in ipairs(Game.getPlayers()) do
        if player ~= origin then
            local d = distance(origin, player)

            if d <= radius then
                table.insert(found, {
                    player = player,
                    distance = d
                })
            end
        end
    end

    return found
end

function Game.getNearestPlayer(origin)
    local found = Game.getPlayersWithin(origin, math.huge)

    if #found == 0 then
        return nil
    end

    table.sort(found, function(a,b)
        return a.distance < b.distance
    end)

    return found[1]
end

function Game.navigateTo(origin, target)
    -- IMPLEMENTE usando o sistema legítimo de movimento/pathfinding
    -- do seu jogo.
    --
    -- Exemplo conceitual:
    -- return pathfinder:goTo(origin, target)
    --
    return false, "navigateTo não foi ligado ao jogo"
end

function Game.setDebugHighlight(player, enabled)
    -- IMPLEMENTE pelo sistema de debug/visualização do seu jogo.
    --
    -- Deve destacar SOMENTE o alvo solicitado.
    return false, "setDebugHighlight não foi ligado ao jogo"
end

function Game.getPlayerInfo(player)
    -- Retorne somente dados que sua API do jogo fornece.
    return {
        name = player.name,
        id = player.id
    }
end

function Game.setWaypoint(x,y,z)
    -- IMPLEMENTE usando o mapa/waypoint do seu jogo.
    return false, "setWaypoint não foi ligado ao jogo"
end

return Game
