local ARIA = require("aria.core")
local Game = require("game.adapter")
local registerTools = require("aria.tools")
local Parser = require("aria.parser")
local AI = require("aria.ai")

registerTools(ARIA, Game)

-- IA opcional. Sem provedor, o parser local continua funcionando.
AI.configure({
    enabled = false,
    endpoint = nil,       -- seu endpoint compatível com JSON
    apiKey = nil,
    model = nil
})

ARIA:setAI(AI)

-- Contexto do jogador atual.
local context = {
    player = Game.getLocalPlayer()
}

local function ask(text)
    local answer = ARIA:process(text, context)
    print("Você: " .. text)
    print("ARIA: " .. answer)
    return answer
end

-- Exemplos:
ask("quem está perto de mim?")
ask("qual player está mais próximo?")
ask("mostre somente Player_A")
ask("me leve até Player_A")
ask("coloque um waypoint em 100 50 20")
ask("qual a posição desse player?")
ask("lembre que minha rota preferida é norte")
ask("o que você lembra?")
ask("olá")

return {
    ARIA = ARIA,
    Game = Game,
    ask = ask
}
