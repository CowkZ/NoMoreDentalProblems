-- /shared/DentalCare.lua -- VERSÃO ADAPTADA PARA CLICAR NA PASTA DE DENTE

DentalCare = {}

------------------------------------------------------------------------------------------
-- Ação que acontece ao escovar os dentes
------------------------------------------------------------------------------------------
function DentalCare.performBrushTeeth(player, toothpaste) -- Trocamos 'sinkObject' por 'toothpaste'
    -- Consome a pasta de dente que foi clicada
    toothpaste:setUsedDelta(toothpaste:getUsedDelta() + 0.1)

    -- Lógica para consumir um pouco de água (seja da garrafa ou do ambiente)
    -- (Podemos adicionar isso depois para mais realismo)

    player:getModData().dentalHygieneProgress = 0
    print("HIGIENE DENTAL: Dentes escovados! Progresso de 'sujeira' zerado.")
    player:getMoodles():getMoodle(MoodleType.Happy):setEffectiveValue(5, 30)
end

------------------------------------------------------------------------------------------
-- NOVA FUNÇÃO: Verifica se o jogador tem acesso à água (VERSÃO FINALÍSSIMA E SEGURA)
------------------------------------------------------------------------------------------
function DentalCare.hasWaterSource(player)
    -- 1. Verifica se há um item com água no inventário principal (esta parte está 100% correta)
    local inventory = player:getInventory()
    for i = 0, inventory:getItems():size() - 1 do
        local item = inventory:getItems():get(i)
        if instanceof(item, "Drainable") and item:getThirstChange() < 0 then
            return true
        end
    end

    -- 2. Se não encontrou no inventário, procura por uma pia/barril por perto
    local currentSquare = player:getSquare()
    if not currentSquare then return false end

    -- Função de ajuda para não repetir código
    local function checkSquareForWater(square)
        if not square then return false end
        for i = 0, square:getObjects():size() - 1 do
            local obj = square:getObjects():get(i)
            if obj.getWaterAmount then
                return true
            end
        end
        return false
    end

    -- Primeiro, checa o quadrado em que o jogador está pisando
    if checkSquareForWater(currentSquare) then return true end

    -- DEPOIS, CHECA OS VIZINHOS USANDO UM LOOP FIXO E SEGURO
    local directions = IsoDirections.values()
    -- Nós sabemos que existem 8 direções válidas. O loop vai de 0 a 7.
    for i = 0, 7 do
        local dir = directions[i]
        local adjacentSquare = currentSquare:getAdjacentSquare(dir)
        if checkSquareForWater(adjacentSquare) then return true end
    end

    return false -- Nenhuma fonte de água encontrada no ambiente
end

------------------------------------------------------------------------------------------
-- LÓGICA DO MENU DE CONTEXTO (VERSÃO FINALÍSSIMA)
------------------------------------------------------------------------------------------
function DentalCare.onFillInventoryContextMenu(player, context, items)
    -- PASSO 1: Pegamos o objeto do jogador de forma segura, ignorando o argumento 'player'.
    local playerObj = getSpecificPlayer(0)
    if not playerObj then return end -- Uma checagem de segurança.

    -- PASSO 2: A SUA DESCOBERTA! Pegamos a lista de itens real usando a função correta.
    local actualItems = ISInventoryPane.getActualItems(items, playerObj)
    if not actualItems then return end

    -- PASSO 3: O nosso loop, que agora vai funcionar com os itens reais.
    for _, item in ipairs(actualItems) do
        -- Checamos se o item é válido e se é uma pasta de dente.
        if item and item:getFullType() == "Base.Toothpaste" then

            -- Usamos 'playerObj' para garantir que não teremos erros de 'nil'.
            local hasToothbrush = playerObj:getInventory():contains("Base.Toothbrush")
            local hasWater = DentalCare.hasWaterSource(playerObj)

            if hasToothbrush and hasWater then
                -- Adicionamos a opção usando o playerObj seguro.
                context:addOption(getText("UI_NDP_BrushTeeth"), item, DentalCare.performBrushTeeth, playerObj, item)
                -- O 'break' impede que a opção seja adicionada várias vezes.
                break
            end
        end
    end
end

------------------------------------------------------------------------------------------
-- Lógica do Timer de Higiene (sem alterações)
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
end

------------------------------------------------------------------------------------------
-- Inicialização dos Eventos (com o evento de inventário)
------------------------------------------------------------------------------------------
function DentalCare.onGameStart()
    -- MUDANÇA IMPORTANTE: Trocamos o evento para o de inventário.
    Events.OnFillInventoryObjectContextMenu.Add(DentalCare.onFillInventoryContextMenu)
    Events.OnPlayerUpdate.Add(DentalCare.updateTimer)
    print("No More Dental Problems: Eventos registrados com sucesso.")
end

Events.OnGameStart.Add(DentalCare.onGameStart)
print("Mod No More Dental Problems carregado. Aguardando início do jogo...")