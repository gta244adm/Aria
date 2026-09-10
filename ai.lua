local AI = {
    enabled = false,
    endpoint = nil,
    apiKey = nil,
    model = nil
}

function AI.configure(config)
    config = config or {}

    for k,v in pairs(config) do
        AI[k] = v
    end
end

-- Adaptador propositalmente separado.
-- O formato exato de HTTP/JSON depende do host Lua.
-- Implemente AI.transport(request) no seu ambiente.
function AI.chat(payload)
    if not AI.enabled then
        return nil
    end

    assert(type(AI.transport) == "function",
        "AI.transport não foi configurado para este ambiente Lua")

    local request = {
        endpoint = AI.endpoint,
        apiKey = AI.apiKey,
        model = AI.model,
        payload = payload
    }

    local ok, result = pcall(AI.transport, request)

    if not ok then
        return nil, result
    end

    if type(result) == "table" then
        return result.text or result.content or result.message
    end

    return tostring(result)
end

return AI
