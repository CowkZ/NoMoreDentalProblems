-- DentalCare_Effects.lua (Versão Final - Lendo ModData)
require "DentalCare_Logic"

-- DentalCare_Effects.lua (Versão Final com a Lógica de Status Corrigida)

local function processEffects(player)
    -- Lemos o valor de higiene que o servidor calculou e sincronizou via ModData.
    local hygieneValue = player:getModData()["NoMoreDentalProblems.HygieneValue"] or 1.0
    
    -- Pegamos os dois objetos de status para usar cada um para sua finalidade.
    local stats = player:getStats()
    local bodyDamage = player:getBodyDamage()
    if not stats or not bodyDamage then return end

    -- Lógica segura para não interferir com outras fontes de dor ou infelicidade:
    -- Primeiro, removemos os valores que nosso mod adicionou na última vez.
    stats:setPain(stats:getPain() - (player:getModData().hygienePain or 0))
    bodyDamage:setUnhappynessLevel(bodyDamage:getUnhappynessLevel() - (player:getModData().hygieneUnhappiness or 0))

    local newPain = 0
    local newUnhappiness = 0
    local speechKey = nil

    -- Estágio 2: Negligência Severa -> Dor
    if hygieneValue <= 0.3 then
        newPain = 20 -- Adiciona Dor via Stats
    -- Estágio 1: Negligência Leve -> Desconforto
    elseif hygieneValue <= 0.7 then
        newUnhappiness = 15 -- Adiciona Infelicidade (Desconforto) via BodyDamage
    end
    
    -- Agora, aplicamos os novos valores. Se a higiene for boa, os valores serão 0.
    stats:setPain(stats:getPain() + newPain)
    bodyDamage:setUnhappynessLevel(bodyDamage:getUnhappynessLevel() + newUnhappiness)

    -- Guardamos quanto nós adicionamos para podermos remover da próxima vez.
    player:getModData().hygienePain = newPain
    player:getModData().hygieneUnhappiness = newUnhappiness
    
    -- Lógica das falas (só acontece se houver algum efeito negativo)
    if newPain > 0 then speechKey = "UI_NDP_Say_Stage2" end
    if newUnhappiness > 0 then speechKey = "UI_NDP_Say_Stage1" end

    if speechKey and not nil then -- trava de seguranca para nao vir valores nulos
        local complaintCooldown = 12
        local lastComplaint = player:getModData().lastDentalComplaintTime or -complaintCooldown
        if getGameTime():getWorldAgeHours() > lastComplaint + complaintCooldown then
            --player:Say(getText(speechKey)) isso nao funciona pois so vai ser ativado quando apertado a tecla do jogo
            player:getModData().lastDentalComplaintTime = getGameTime():getWorldAgeHours()
        end
    end
end

-- Usamos um evento estável para rodar a lógica de efeitos.
Events.EveryTenMinutes.Add(function()
    local player = getPlayer()
    if player and player:isLocalPlayer() then
        processEffects(player)
    end
end)

-- A função de reset agora também zera os status no client
local original_ResetPlayerHygiene = _G.ResetPlayerHygiene
_G.ResetPlayerHygiene = function(player)
    if original_ResetPlayerHygiene then original_ResetPlayerHygiene(player) end

    if player and player:isLocalPlayer() then
        local stats = player:getStats()
        local bodyDamage = player:getBodyDamage()
        print("resetando player ihigiene")
        if stats and bodyDamage then
            stats:setPain(stats:getPain() - (player:getModData().hygienePain or 0))
            bodyDamage:setUnhappynessLevel(bodyDamage:getUnhappynessLevel() - (player:getModData().hygieneUnhappiness or 0))
        end
        player:getModData().hygienePain = 0
        player:getModData().hygieneUnhappiness = 0
    end
end