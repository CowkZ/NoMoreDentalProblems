-- DentalCare_ContextMenu.lua (Com a arquitetura final e correta)

require "client/TimedActions/ISBrushTeethAction"

-- Função de ajuda para encontrar pasta de dente utilizável (sem alterações)
local function findToothpaste(player)
    local inventory = player:getInventory()
    local allItems = inventory:getItems()
    for i=0,allItems:size()-1 do
        local item = allItems:get(i)
        if item:getType() == "Toothpaste" then
            if instanceof(item, "Drainable") and item:getCurrentUsesFloat() > 0 then
                return item
            end
        end
    end
    return nil
end

-- A NOVA FUNÇÃO "PONTE", inspirada no seu exemplo
-- Esta função é chamada quando o jogador clica na opção do menu.
local function OnBrushTeeth(toothbrush)
    local playerObj = getSpecificPlayer(0)
    if not playerObj then return end

    -- Verificamos novamente se temos a pasta de dente, por segurança
    local toothpaste = findToothpaste(playerObj)
    if not toothpaste then return end

    -- Estando tudo certo, AGORA sim adicionamos nossa ação com tempo à fila.
    ISTimedActionQueue.add(ISBrushTeethAction:new(playerObj, toothbrush, toothpaste))
end

-- A função principal que adiciona a opção ao menu
local function AddBrushTeethOption(player, context, items)
    local playerObj = getSpecificPlayer(0)
    if not playerObj then return end

    local actualItems = ISInventoryPane.getActualItems(items, playerObj)
    if not actualItems then return end

    for _, item in ipairs(actualItems) do
        if item and item:getType() == "Toothbrush" and not item:isBroken() then
            local toothpaste = findToothpaste(playerObj)
            if toothpaste then
                -- A CORREÇÃO FINAL: A opção do menu agora chama a nossa função "ponte" OnBrushTeeth.
                context:addOption(getText("UI_NDP_BrushTeeth"), item, OnBrushTeeth, item)
            end
        end
    end
end

Events.OnFillInventoryObjectContextMenu.Add(AddBrushTeethOption)