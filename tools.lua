return function(ARIA, Game)

    local function safeName(p)
        return tostring((p and p.name) or "Unknown")
    end

    local function fmtDistance(d)
        if type(d) ~= "number" then
            return "?"
        end
        return string.format("%.1f m", d)
    end

    ARIA:registerTool("remember", {
        description = "Guarda uma informação na memória.",
        execute = function(args)
            if not args.key or not args.value then
                return "Preciso de uma chave e um valor."
            end

            ARIA:remember(args.key, args.value)
            return "Memorizado: " .. args.key .. " = " .. args.value
        end
    })

    ARIA:registerTool("clear_memory", {
        description = "Limpa a memória da sessão.",
        execute = function()
            ARIA.memory = {}
            return "Memória limpa."
        end
    })

    ARIA:registerTool("memory_dump", {
        description = "Lista a memória atual.",
        execute = function()
            local out = {}
            for k,v in pairs(ARIA.memory) do
                table.insert(out, tostring(k) .. " = " .. tostring(v))
            end
            table.sort(out)

            if #out == 0 then
                return "Minha memória está vazia."
            end

            return "Memória: " .. table.concat(out, "; ")
        end
    })

    ARIA:registerTool("nearest_players", {
        description = "Lista players próximos do jogador local.",
        execute = function(args, context)
            local origin = context.player or Game.getLocalPlayer()
            if not origin then
                return "Jogador local não encontrado."
            end

            local radius = tonumber(args.radius) or ARIA.config.defaultRadius
            local found = Game.getPlayersWithin(origin, radius)

            table.sort(found, function(a,b)
                return (a.distance or math.huge) < (b.distance or math.huge)
            end)

            if #found == 0 then
                return "Nenhum player encontrado nesse raio."
            end

            local lines = {}
            for i, item in ipairs(found) do
                table.insert(lines,
                    string.format("%d. %s — %s", i, safeName(item.player), fmtDistance(item.distance)))
            end

            return "Players próximos:\n" .. table.concat(lines, "\n")
        end
    })

    ARIA:registerTool("nearest_player", {
        description = "Encontra o player mais próximo.",
        execute = function(_, context)
            local origin = context.player or Game.getLocalPlayer()
            local nearest = Game.getNearestPlayer(origin)

            if not nearest then
                return "Não encontrei nenhum player."
            end

            return string.format(
                "O player mais próximo é %s — %s.",
                safeName(nearest.player),
                fmtDistance(nearest.distance)
            )
        end
    })

    ARIA:registerTool("find_player", {
        description = "Procura um player pelo nome.",
        execute = function(args)
            local player = Game.findPlayer(args.name)

            if not player then
                return "Não encontrei '" .. tostring(args.name) .. "'."
            end

            local x,y,z = Game.getPosition(player)

            return string.format(
                "Encontrei %s. Posição: %.2f, %.2f, %.2f.",
                safeName(player), x, y, z
            )
        end
    })

    ARIA:registerTool("navigate_to_player", {
        description = "Inicia navegação do jogador local até outro player.",
        execute = function(args, context)
            local origin = context.player or Game.getLocalPlayer()
            local target = Game.findPlayer(args.name)

            if not origin then
                return "Jogador local não encontrado."
            end

            if not target then
                return "Não encontrei '" .. tostring(args.name) .. "'."
            end

            local ok, reason = Game.navigateTo(origin, target)
            if ok then
                return "Navegação iniciada até " .. safeName(target) .. "."
            end

            return "Não foi possível iniciar a navegação: " .. tostring(reason or "motivo desconhecido")
        end
    })

    ARIA:registerTool("highlight_player", {
        description = "Ativa destaque de depuração para um player.",
        execute = function(args)
            local target = Game.findPlayer(args.name)

            if not target then
                return "Não encontrei '" .. tostring(args.name) .. "'."
            end

            local ok, reason = Game.setDebugHighlight(target, true)

            if not ok then
                return "Não foi possível destacar: " .. tostring(reason or "erro")
            end

            return "Destaque ativado somente para " .. safeName(target) .. "."
        end
    })

    ARIA:registerTool("player_info", {
        description = "Mostra informações de um player.",
        execute = function(args)
            local target = Game.findPlayer(args.name)

            if not target then
                return "Player não encontrado."
            end

            local info = Game.getPlayerInfo(target)
            if not info then
                return "O jogo não forneceu informações sobre esse player."
            end

            local out = {}
            for k,v in pairs(info) do
                table.insert(out, tostring(k) .. "=" .. tostring(v))
            end
            table.sort(out)

            return safeName(target) .. ": " .. table.concat(out, ", ")
        end
    })

    ARIA:registerTool("my_position", {
        description = "Mostra a posição do jogador local.",
        execute = function(_, context)
            local p = context.player or Game.getLocalPlayer()
            if not p then return "Jogador local não encontrado." end

            local x,y,z = Game.getPosition(p)
            return string.format(
                "Sua posição: X %.2f, Y %.2f, Z %.2f.",
                x,y,z
            )
        end
    })

    ARIA:registerTool("set_waypoint", {
        description = "Define um waypoint por coordenadas.",
        execute = function(args)
            local ok, reason = Game.setWaypoint(args.x, args.y, args.z)

            if not ok then
                return "Não foi possível definir o waypoint: " .. tostring(reason or "erro")
            end

            return string.format(
                "Waypoint definido em %.2f, %.2f, %.2f.",
                args.x, args.y, args.z
            )
        end
    })
end
