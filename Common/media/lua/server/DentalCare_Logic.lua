-- DentalCare_Logic.lua (Atualizado com Moodles e Falas)

local TeethHygiene = {}
TeethHygiene.modDataKey = "NoMoreDentalProblems.HygieneValue"
TeethHygiene.defaultValue = 1.0
TeethHygiene.decayRate = 0.2 -- Perde 20% de higiene por dia

-- Inicializa o valor de higiene para um novo jogador
function TeethHygiene.Init(player)
    player:getModData()[TeethHygiene.modDataKey] = TeethHygiene.defaultValue
end

-- Pega o valor atual de higiene
function TeethHygiene.getValue(player)
    return player:getModData()[TeethHygiene.modDataKey] or TeethHygiene.defaultValue
end

-- Define um novo valor de higiene
function TeethHygiene.setValue(player, value)
    local clampedValue = math.max(0, math.min(1.0, value))
    player:getModData()[TeethHygiene.modDataKey] = clampedValue
end

-- NOVA FUNÇÃO: Controla os efeitos (moodles e falas)
function TeethHygiene.processEffects(player, hygieneValue)
    local moodles = player:getMoodles()
    local complaintCooldown = 12 -- Personagem só reclama a cada 12 horas
    local lastComplaint = player:getModData().lastDentalComplaintTime or -complaintCooldown

    -- Estágio 2: Negligência Severa -> Dor
    if hygieneValue <= 0.3 then
        moodles:setMoodleLevel(MoodleType.Pain, 1) -- Nível 1 de Dor
        moodles:setMoodleLevel(MoodleType.Discomfort, 0) -- Dor substitui o desconforto
        -- Se já passou tempo suficiente desde a última reclamação...
        if getGameTime():getWorldAgeHours() > lastComplaint + complaintCooldown then
            player:Say(getText("UI_NDP_Say_Stage2")) -- ...faz o personagem falar.
            player:getModData().lastDentalComplaintTime = getGameTime():getWorldAgeHours()
        end
    -- Estágio 1: Negligência Leve -> Desconforto
    elseif hygieneValue <= 0.7 then
        moodles:setMoodleLevel(MoodleType.Pain, 0)
        moodles:setMoodleLevel(MoodleType.Discomfort, 1) -- Nível 1 de Desconforto
        if getGameTime():getWorldAgeHours() > lastComplaint + complaintCooldown then
            player:Say(getText("UI_NDP_Say_Stage1"))
            player:getModData().lastDentalComplaintTime = getGameTime():getWorldAgeHours()
        end
    -- Sem Negligência
    else
        moodles:setMoodleLevel(MoodleType.Pain, 0)
        moodles:setMoodleLevel(MoodleType.Discomfort, 0)
    end
end

-- Função principal que roda a cada hora
function TeethHygiene.update(player)
    local currentValue = TeethHygiene.getValue(player)
    local hourlyDecay = TeethHygiene.decayRate / 24
    local newValue = currentValue - hourlyDecay
    TeethHygiene.setValue(player, newValue)
    -- Após atualizar o valor, processamos os efeitos
    TeethHygiene.processEffects(player, newValue)
end

-- Função global para resetar a higiene (chamada pela ação de escovar)
_G.ResetPlayerHygiene = function(player)
    TeethHygiene.setValue(player, 1.0)
    -- Remove imediatamente os moodles ao escovar
    player:getMoodles():setMoodleLevel(MoodleType.Pain, 0)
    player:getMoodles():setMoodleLevel(MoodleType.Discomfort, 0)
    print("HIGIENE DENTAL: Nível de higiene resetado!")
end

-- Conecta os eventos do jogo às nossas funções (sem alterações aqui)
Events.OnCreatePlayer.Add(function(playerNum, player)
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