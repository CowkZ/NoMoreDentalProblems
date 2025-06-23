-- DentalCare_Effects.lua (Versão Final - Lendo ModData)
require "DentalCare_Logic"

local function processEffects(player)
    -- A CORREÇÃO ESTÁ AQUI: Lemos o valor diretamente do ModData.
    local hygieneValue = player:getModData()["NoMoreDentalProblems.HygieneValue"] or 1.0

    local stats = player:getStats()
    if not stats then return end

    local currentUnhappiness = stats:getUnhappiness()
    local unhappinessFromHygiene = player:getModData().hygieneUnhappiness or 0
    local baseUnhappiness = currentUnhappiness - unhappinessFromHygiene

    local newPain = 0
    local newUnhappinessFromHygiene = 0
    local speechKey = nil

    if hygieneValue <= 0.3 then
        newPain = 25
        newUnhappinessFromHygiene = 10
        speechKey = "UI_NDP_Say_Stage2"
    elseif hygieneValue <= 0.7 then
        newPain = 0
        newUnhappinessFromHygiene = 15
        speechKey = "UI_NDP_Say_Stage1"
    end

    stats:setPain(newPain)
    stats:setUnhappiness(baseUnhappiness + newUnhappinessFromHygiene)
    player:getModData().hygieneUnhappiness = newUnhappinessFromHygiene
    
    if speechKey then
        local complaintCooldown = 12
        local lastComplaint = player:getModData().lastDentalComplaintTime or -complaintCooldown
        if getGameTime():getWorldAgeHours() > lastComplaint + complaintCooldown then
            player:Say(getText(speechKey))
            player:getModData().lastDentalComplaintTime = getGameTime():getWorldAgeHours()
        end
    end
end

-- Usando o evento seguro EveryTenMinutes
Events.EveryTenMinutes.Add(function()
    local player = getPlayer()
    if player and player:isLocalPlayer() then
        processEffects(player)
    end
end)

-- Sobrescrevemos a função de reset para limpar os status no client
local original_ResetPlayerHygiene = _G.ResetPlayerHygiene
_G.ResetPlayerHygiene = function(player)
    if original_ResetPlayerHygiene then original_ResetPlayerHygiene(player) end

    if player and player:isLocalPlayer() then
        local stats = player:getStats()
        if stats then
            stats:setPain(0)
            local unhappinessFromHygiene = player:getModData().hygieneUnhappiness or 0
            stats:setUnhappiness(stats:getUnhappiness() - unhappinessFromHygiene)
        end
        player:getModData().hygieneUnhappiness = 0
        print("HIGIENE DENTAL: Nível de higiene resetado e status restaurados!")
    end
end