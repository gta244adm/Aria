local ARIA = {}
ARIA.__index = ARIA

function ARIA.new(config)
    local self = setmetatable({}, ARIA)

    self.name = "A.R.I.A."
    self.version = "1.0.0"

    self.config = {
        maxHistory = 40,
        defaultRadius = 100,
        maxToolCalls = 4
    }

    if config then
        for k, v in pairs(config) do
            self.config[k] = v
        end
    end

    self.tools = {}
    self.memory = {}
    self.history = {}
    self.events = {}
    self.ai = nil

    return self
end

function ARIA:registerTool(name, spec)
    assert(type(name) == "string" and name ~= "", "nome da ferramenta inválido")
    assert(type(spec) == "table", "spec da ferramenta inválido")
    assert(type(spec.execute) == "function", "execute deve ser function")

    self.tools[name] = {
        description = spec.description or "",
        aliases = spec.aliases or {},
        execute = spec.execute
    }
end

function ARIA:setAI(provider)
    self.ai = provider
end

function ARIA:emit(eventName, ...)
    local listeners = self.events[eventName]
    if not listeners then return end

    for _, fn in ipairs(listeners) do
        pcall(fn, ...)
    end
end

function ARIA:on(eventName, fn)
    assert(type(fn) == "function", "listener inválido")
    self.events[eventName] = self.events[eventName] or {}
    table.insert(self.events[eventName], fn)
end

function ARIA:remember(key, value)
    self.memory[key] = value
    self:emit("memory_changed", key, value)
end

function ARIA:forget(key)
    self.memory[key] = nil
    self:emit("memory_changed", key)
end

function ARIA:getMemory(key)
    return self.memory[key]
end

function ARIA:getAllMemory()
    local copy = {}
    for k, v in pairs(self.memory) do
        copy[k] = v
    end
    return copy
end

function ARIA:addMessage(role, content)
    table.insert(self.history, {
        role = role,
        content = content,
        time = os.time()
    })

    while #self.history > self.config.maxHistory do
        table.remove(self.history, 1)
    end
end

function ARIA:getHistory()
    return self.history
end

function ARIA:callTool(name, args, context)
    local tool = self.tools[name]
    if not tool then
        return false, "Ferramenta inexistente: " .. tostring(name)
    end

    local ok, result = pcall(tool.execute, args or {}, context or {}, self)
    if not ok then
        self:emit("tool_error", name, result)
        return false, "Erro na ferramenta '" .. name .. "': " .. tostring(result)
    end

    self:emit("tool_executed", name, result)
    return true, result
end

function ARIA:listTools()
    local list = {}
    for name, tool in pairs(self.tools) do
        table.insert(list, {
            name = name,
            description = tool.description,
            aliases = tool.aliases
        })
    end

    table.sort(list, function(a, b) return a.name < b.name end)
    return list
end

function ARIA:reply(text)
    local answer = tostring(text or "")
    self:addMessage("assistant", answer)
    self:emit("reply", answer)
    return answer
end

function ARIA:process(text, context)
    context = context or {}

    if type(text) ~= "string" or text:match("^%s*$") then
        return self:reply("Não recebi nenhuma pergunta.")
    end

    self:addMessage("user", text)
    self:emit("input", text, context)

    -- O parser local é determinístico e não depende de internet.
    local Parser = require("aria.parser")
    local intent = Parser.parse(text)

    if intent then
        local ok, result = self:callTool(intent.tool, intent.args, context)
        if ok then
            return self:reply(result)
        end
        return self:reply(result)
    end

    -- Conversa normal ou conhecimento externo.
    if self.ai and self.ai.enabled and type(self.ai.chat) == "function" then
        local ok, result = pcall(function()
            return self.ai.chat({
                assistant = self.name,
                user = text,
                history = self.history,
                memory = self.memory,
                tools = self:listTools(),
                context = context
            })
        end)

        if ok and result and result ~= "" then
            return self:reply(result)
        end
    end

    local t = text:lower()

    if t:match("^oi$") or t:match("^ola") or t:match("^olá") then
        return self:reply("Olá. Sou a A.R.I.A. Posso conversar e executar as ferramentas disponíveis no jogo.")
    end

    if t:find("o que voce lembra") or t:find("o que você lembra") then
        local items = {}
        for k, v in pairs(self.memory) do
            table.insert(items, tostring(k) .. " = " .. tostring(v))
        end
        table.sort(items)

        if #items == 0 then
            return self:reply("Minha memória está vazia.")
        end

        return self:reply("Lembro de: " .. table.concat(items, "; "))
    end

    return self:reply(
        "Posso conversar, mas essa pergunta precisa de um provedor de IA ou de uma ferramenta específica. "
        .. "Ferramentas disponíveis: " .. tostring(#self:listTools())
    )
end

return ARIA.new()
