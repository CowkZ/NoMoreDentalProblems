-- DentalCare_ContextMenu.lua (Com a correção que faltava)

require "client/TimedActions/ISBrushTeethAction"

-- Função de ajuda para encontrar pasta de dente utilizável
local function findToothpaste(player)
    local inventory = player:getInventory()
    local allItems = inventory:getItems()
    for i=0,allItems:size()-1 do
        local item = allItems:get(i)
        if item:getType() == "Toothpaste" and item:getUsedDelta() < 1 then
            return item
        end
    end
    return nil
end

-- Nossa função de adicionar a opção ao menu, agora corrigida
local function AddBrushTeethOption(player, context, items)
    -- PASSO 1: Pegar o jogador de forma segura (lição #1)
    local playerObj = getSpecificPlayer(0)
    if not playerObj then return end

    -- PASSO 2: "Desenvelopar" a lista de itens (lição #2 - a que eu esqueci)
    local actualItems = ISInventoryPane.getActualItems(items, playerObj)
    if not actualItems then return end

    -- PASSO 3: Iterar sobre a lista de itens REAL
    for _, item in ipairs(actualItems) do
        -- A opção só aparece se clicarmos em uma escova de dentes não quebrada
        if item and item:getType() == "Toothbrush" and item:getType() == "Toothpaste" and not item:isBroken() then
                -- Adiciona a opção, que inicia nossa TimedAction
            context:addOption(getText("UI_NDP_BrushTeeth"), item, ISTimedActionQueue.add, ISBrushTeethAction:new(playerObj, item, toothpaste))
        end
    end
end

Events.OnFillInventoryObjectContextMenu.Add(AddBrushTeethOption)