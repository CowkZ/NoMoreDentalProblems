-- DentalCare_Logic.lua (Versão Final com a Lógica de Status Corrigida)

local TeethHygiene = {}
TeethHygiene.modDataKey = "NoMoreDentalProblems.HygieneValue"
TeethHygiene.defaultValue = 1.0
TeethHygiene.decayRate = 0.1

function TeethHygiene.Init(player)
    if not player then return end
    player:getModData()[TeethHygiene.modDataKey] = TeethHygiene.defaultValue
    player:getModData().hygieneUnhappiness = 0
end

function TeethHygiene.processEffects(player)

    local hygieneValue = player:getModData()[TeethHygiene.modDataKey] or TeethHygiene.defaultValue
    
    -- Pegamos os DOIS objetos de status, para usar cada um para sua finalidade correta.
    local stats = player:getStats()
    local bodyDamage = player:getBodyDamage()
    if not stats or not bodyDamage then return end

    -- Lógica para Infelicidade (usando BodyDamage, como você apontou)
    local currentUnhappiness = bodyDamage:getUnhappynessLevel() or 0
    local unhappinessFromHygiene = player:getModData().hygieneUnhappiness or 0
    local baseUnhappiness = currentUnhappiness - unhappinessFromHygiene

    local newPain = 0
    local newUnhappinessFromHygiene = 0

    -- Estágio 2: Negligência Severa -> Dor
    if hygieneValue <= 0.3 then
        newPain = 15
        newUnhappinessFromHygiene = 15
    -- Estágio 1: Negligência Leve -> Desconforto (via Infelicidade)
    elseif hygieneValue <= 0.7 then
        newPain = 0
        newUnhappinessFromHygiene = 15
    end

    -- Aplicamos os valores aos objetos corretos
    stats:setPain(newPain) -- Dor é controlada pelo Stats
    bodyDamage:setUnhappynessLevel(baseUnhappiness + newUnhappinessFromHygiene) -- Infelicidade pelo BodyDamage

    -- Guardamos quanta infelicidade o NOSSO MOD adicionou
    player:getModData().hygieneUnhappiness = newUnhappinessFromHygiene
end

function TeethHygiene.update(player)
    if not player then return end
    print("logica funcionando")
    local currentValue = player:getModData()[TeethHygiene.modDataKey] or TeethHygiene.defaultValue
    local hourlyDecay = TeethHygiene.decayRate / 24
    local newValue = currentValue - hourlyDecay
    player:getModData()[TeethHygiene.modDataKey] = newValue
    TeethHygiene.processEffects(player)
end

_G.ResetPlayerHygiene = function(player)
    if not player then return end
    player:getModData()[TeethHygiene.modDataKey] = 1.0
    
    local stats = player:getStats()
    local bodyDamage = player:getBodyDamage()

    if stats and bodyDamage then
        stats:setPain(0)
        local unhappinessFromHygiene = player:getModData().hygieneUnhappiness or 0
        local currentUnhappiness = bodyDamage:getUnhappynessLevel() or 0
        bodyDamage:setUnhappynessLevel(currentUnhappiness - unhappinessFromHygiene)
    end
    player:getModData().hygieneUnhappiness = 0
end

Events.OnCreatePlayer.Add(function(playerIndex, player)
    print("player iniciado")
    TeethHygiene.Init(player)
end)

Events.EveryHours.Add(function()
    for i = 0, getNumActivePlayers() - 1 do
        local player = getPlayer(i)
        if player then
            TeethHygiene.update(player)
        end
    end
end)