package.path = "./?.lua;./?/init.lua;" .. package.path

local ARIA = require("aria.core")
local registerTools = require("aria.tools")
local Mock = require("game.mock")

registerTools(ARIA, Mock)

local context = {
    player = Mock.getLocalPlayer()
}

local tests = {
    "oi",
    "quem está perto de mim?",
    "qual player está mais perto?",
    "encontre o player Player_B",
    "mostre somente Player_A",
    "qual a posição do player Player_A?",
    "me leve até Player_A",
    "waypoint 100 50 20",
    "lembre que arma = rifle",
    "o que você lembra?"
}

for _, q in ipairs(tests) do
    print("> " .. q)
    print(ARIA:process(q, context))
    print("")
end
