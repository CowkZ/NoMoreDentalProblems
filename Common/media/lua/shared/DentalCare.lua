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
-- FUNÇÃO DE DIAGNÓSTICO FINAL: VAMOS FAZER UM RAIO-X DOS OBJETOS
------------------------------------------------------------------------------------------
function DentalCare.hasWaterSource(player)
    print("--- INICIANDO DIAGNÓSTICO DE FONTE DE ÁGUA ---")

    -- 1. Checagem de inventário (não vamos mexer aqui)
    local inventory = player:getInventory()
    for i = 0, inventory:getItems():size() - 1 do
        local item = inventory:getItems():get(i)
        if instanceof(item, "Drainable") and item:getThirstChange() < 0 then
            print("DIAGNÓSTICO: Encontrada garrafa d'água no inventário.")
            return true
        end
    end

    -- 2. Raio-X do ambiente
    local currentSquare = player:getSquare()
    if not currentSquare then
        print("DIAGNÓSTICO: Erro crítico, não foi possível pegar o quadrado do jogador.")
        return false
    end

    -- Função de ajuda para inspecionar um quadrado
    local function inspectSquare(square, label)
        if not square then return end
        print("--- Inspecionando Quadrado: '"..label.."' em "..square:getX()..","..square:getY().." ---")
        if square:getObjects():size() == 0 then
            print("Nenhum objeto encontrado neste quadrado.")
        else
            for i = 0, square:getObjects():size() - 1 do
                local obj = square:getObjects():get(i)
                print("--- Objeto #"..i.." Encontrado ---")
                -- A linha mais importante: vamos despejar todas as informações do objeto
                ISDebugger.dump(obj)
            end
        end
    end

    -- Inspeciona o quadrado atual
    inspectSquare(currentSquare, "ATUAL")

    -- Inspeciona os 8 vizinhos
    local directionsList = {
        IsoDirections.N, IsoDirections.NE, IsoDirections.E, IsoDirections.SE,
        IsoDirections.S, IsoDirections.SW, IsoDirections.W, IsoDirections.NW
    }
    for _, dir in ipairs(directionsList) do
        inspectSquare(currentSquare:getAdjacentSquare(dir), tostring(dir))
    end

    print("--- FIM DO DIAGNÓSTICO ---")
    return false -- A função vai retornar false de propósito, apenas para gerar o log.
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
            print(hasWater)
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