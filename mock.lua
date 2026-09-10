-- Ambiente fictício SOMENTE para testar o núcleo sem um jogo real.

local Mock = {
    localPlayer = { id = 1, name = "Eu", x = 0, y = 0, z = 0 },

    players = {
        { id = 2, name = "Player_A", x = 10, y = 0, z = 0 },
        { id = 3, name = "Player_B", x = 40, y = 0, z = 0 },
        { id = 4, name = "Player_C", x = 130, y = 0, z = 0 }
    }
}

function Mock.getLocalPlayer()
    return Mock.localPlayer
end

function Mock.getPlayers()
    local all = { Mock.localPlayer }
    for _, p in ipairs(Mock.players) do
        table.insert(all, p)
    end
    return all
end

function Mock.getPosition(player)
    return player.x, player.y, player.z
end

function Mock.findPlayer(name)
    local n = name:lower()

    for _, p in ipairs(Mock.getPlayers()) do
        if p ~= Mock.localPlayer and p.name:lower() == n then
            return p
        end
    end

    return nil
end

function Mock.getPlayersWithin(origin, radius)
    local result = {}

    for _, p in ipairs(Mock.getPlayers()) do
        if p ~= origin then
            local dx = p.x-origin.x
            local dy = p.y-origin.y
            local dz = p.z-origin.z
            local d = math.sqrt(dx*dx+dy*dy+dz*dz)

            if d <= radius then
                table.insert(result, {
                    player = p,
                    distance = d
                })
            end
        end
    end

    return result
end

function Mock.getNearestPlayer(origin)
    local list = Mock.getPlayersWithin(origin, math.huge)
    table.sort(list, function(a,b) return a.distance < b.distance end)
    return list[1]
end

function Mock.navigateTo(origin, target)
    origin.navigationTarget = target
    return true
end

function Mock.setDebugHighlight(player, enabled)
    for _, p in ipairs(Mock.getPlayers()) do
        p.highlight = false
    end

    player.highlight = enabled
    return true
end

function Mock.getPlayerInfo(player)
    return {
        name = player.name,
        id = player.id,
        x = player.x,
        y = player.y,
        z = player.z,
        highlighted = player.highlight == true
    }
end

function Mock.setWaypoint(x,y,z)
    Mock.waypoint = {x=x,y=y,z=z}
    return true
end

return Mock
