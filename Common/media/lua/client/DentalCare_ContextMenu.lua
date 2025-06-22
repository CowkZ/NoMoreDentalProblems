-- DentalCare_ContextMenu.lua

require "client/TimedActions/ISBrushTeethAction"

-- Função de ajuda para encontrar pasta de dente utilizável
local function findToothpaste(player)
    local inventory = player:getInventory()
    -- Procura por uma pasta de dente que não esteja vazia
    local allItems = inventory:getItems()
    for i=0,allItems:size()-1 do
        local item = allItems:get(i)
        if item:getType() == "Toothpaste" and item:getUsedDelta() < 1 then
            return item
        end
    end
    return nil
end

local function AddBrushTeethOption(player, context, items)
    -- O 'items' aqui é uma lista de itens do inventário que foram clicados
    local clickedItem = items[1]
    if not clickedItem then return end

    -- A opção só aparece se clicarmos em uma escova de dentes não quebrada
    if clickedItem:getType() == "Toothbrush" and not clickedItem:isBroken() then
        local toothpaste = findToothpaste(player)
        -- E se tivermos pasta de dente
        if toothpaste then
            -- Adiciona a opção, que inicia nossa TimedAction
            context:addOption(getText("UI_NDP_BrushTeeth"), items, ISTimedActionQueue.add, ISBrushTeethAction:new(player, clickedItem, toothpaste))
        end
    end
end

Events.OnFillInventoryObjectContextMenu.Add(AddBrushTeethOption)