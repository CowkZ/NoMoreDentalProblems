-- DentalCare_Logic.lua (Versão Final com a sua correção de getPlayer())

local TeethHygiene = {}
TeethHygiene.modDataKey = "NoMoreDentalProblems.HygieneValue"
TeethHygiene.defaultValue = 1.0
TeethHygiene.decayRate = 0.2

function TeethHygiene.Init(playerIndex)
    local player = getPlayer(playerIndex)
    if not player then return end -- Checagem de segurança
    player:getModData()[TeethHygiene.modDataKey] = TeethHygiene.defaultValue
    player:getModData().hygieneUnhappiness = 0
end

function TeethHygiene.processEffects(player)
    local hygieneValue = player:getModData()[TeethHygiene.modDataKey] or TeethHygiene.defaultValue
    local stats = player:getStats()
    if not stats then return end

    local currentUnhappiness = stats:getUnhappiness()
    local unhappinessFromHygiene = player:getModData().hygieneUnhappiness or 0
    local baseUnhappiness = currentUnhappiness - unhappinessFromHygiene
    local newPain = 0
    local newUnhappinessFromHygiene = 0

    if hygieneValue <= 0.3 then
        newPain = 25
        newUnhappinessFromHygiene = 10
    elseif hygieneValue <= 0.7 then
        newPain = 0
        newUnhappinessFromHygiene = 15
    end

    stats:setPain(newPain)
    stats:setUnhappiness(baseUnhappiness + newUnhappinessFromHygiene)
    player:getModData().hygieneUnhappiness = newUnhappinessFromHygiene
end

function TeethHygiene.update(playerIndex)
    local player = getPlayer(playerIndex)
    if not player then return end

    local currentValue = player:getModData()[TeethHygiene.modDataKey] or TeethHygiene.defaultValue
    local hourlyDecay = TeethHygiene.decayRate / 24
    local newValue = currentValue - hourlyDecay
    player:getModData()[TeethHygiene.modDataKey] = newValue
    TeethHygiene.processEffects(player)
end

_G.ResetPlayerHygiene = function(player)
    player:getModData()[TeethHygiene.modDataKey] = 1.0
    local stats = player:getStats()
    if stats then
        stats:setPain(0)
        local unhappinessFromHygiene = player:getModData().hygieneUnhappiness or 0
        stats:setUnhappiness(stats:getUnhappiness() - unhappinessFromHygiene)
    end
    player:getModData().hygieneUnhappiness = 0
end

-- Eventos corrigidos para passar o ÍNDICE do jogador, não o objeto
Events.OnCreatePlayer.Add(function(playerIndex, player)
    TeethHygiene.Init(playerIndex)
end)

Events.EveryHours.Add(function()
    for i = 0, getNumActivePlayers() - 1 do
        TeethHygiene.update(i)
    end
end)