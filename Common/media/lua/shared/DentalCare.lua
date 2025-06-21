-- DentalCare.lua

-- Criamos uma tabela para organizar nosso código e evitar conflitos com outros mods.
DentalCare = {}

------------------------------------------------------------------------------------------
-- FUNÇÃO PRINCIPAL: O que acontece quando o jogador escova os dentes.
------------------------------------------------------------------------------------------
function DentalCare.performBrushTeeth(player)
    local toothpaste = player:getInventory():findAndReturn("Base.Toothpaste")
    if not toothpaste then return end

    toothpaste:setUsedDelta(toothpaste:getUsedDelta() + 0.1)

    player:getModData().dentalHygieneProgress = 0
    print("HIGIENE DENTAL: Dentes escovados! Progresso de 'sujeira' zerado.")

    player:getMoodles():getMoodle(MoodleType.Happy):setEffectiveValue(5, 30)
end

------------------------------------------------------------------------------------------
-- LÓGICA DO MENU: Adiciona a opção "Escovar Dentes" ao clicar com o botão direito.
------------------------------------------------------------------------------------------
function DentalCare.onFillContextMenu(player, context, worldobjects)
    local clickedWaterSource = false
    for i, obj in ipairs(worldobjects) do
        if obj:getSprite() and obj:getSprite():getName() and string.find(obj:getSprite():getName(), "faucet") then
            clickedWaterSource = true
            break
        end
    end
    if not clickedWaterSource then return end

    local hasToothbrush = player:getInventory():contains("Base.Toothbrush")
    local hasToothpaste = player:getInventory():contains("Base.Toothpaste")

    if hasToothbrush and hasToothpaste then
        -- Usando a nossa chave de tradução aqui
        context:addOption(getText("UI_NDP_BrushTeeth"), worldobjects, DentalCare.performBrushTeeth, player)
    end
end

------------------------------------------------------------------------------------------
-- LÓGICA DO TIMER: Aumenta a "sujeira" e aplica os Moodle.
------------------------------------------------------------------------------------------
DentalCare.ticksPorHora = 3600
DentalCare.tickCounter = 0

function DentalCare.updateTimer(player)
    DentalCare.tickCounter = DentalCare.tickCounter + 1

    if DentalCare.tickCounter < DentalCare.ticksPorHora then
        return
    end

    DentalCare.tickCounter = 0

    local hygieneProgress = player:getModData().dentalHygieneProgress or 0
    hygieneProgress = hygieneProgress + 1
    player:getModData().dentalHygieneProgress = hygieneProgress
    
    print("HIGIENE DENTAL: Progresso atual = " .. hygieneProgress)
    
    -- Futura lógica dos moodles virá aqui
end


-- =======================================================================================
-- FUNÇÃO DE INICIALIZAÇÃO (A CORREÇÃO ESTÁ AQUI)
-- =======================================================================================
-- Esta função só vai rodar quando o jogo estiver 100% carregado e pronto.
function DentalCare.onGameStart()
    -- Nós movemos os registros de eventos para DENTRO desta função.
    Events.onFillWorldObjectContextMenu.Add(DentalCare.onFillContextMenu)
    Events.OnPlayerUpdate.Add(DentalCare.updateTimer)
    print("No More Dental Problems: Eventos registrados com sucesso.")
end


------------------------------------------------------------------------------------------
-- EVENTOS: "Ligamos" nossa função de inicialização no evento OnGameStart
------------------------------------------------------------------------------------------
-- Este é o ÚNICO registro de evento que fica no corpo principal do arquivo.
Events.OnGameStart.Add(DentalCare.onGameStart)

print("Mod No More Dental Problems carregado. Aguardando início do jogo...")