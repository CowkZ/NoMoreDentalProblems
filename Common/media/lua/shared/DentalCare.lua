-- DentalCare.lua

-- Criamos uma tabela para organizar nosso código e evitar conflitos com outros mods.
DentalCare = {}

------------------------------------------------------------------------------------------
-- FUNÇÃO PRINCIPAL: O que acontece quando o jogador escova os dentes.
------------------------------------------------------------------------------------------
function DentalCare.performBrushTeeth(player)
    -- Encontra a pasta de dente no inventário principal do jogador
    local toothpaste = player:getInventory():findAndReturn("Base.Toothpaste")
    if not toothpaste then return end -- Segurança extra

    -- Consome um pouco da pasta de dente.
    -- O item original tem 10 usos, então vamos simular isso. Usamos 0.1 para 10 usos (1 / 10 = 0.1).
    toothpaste:setUsedDelta(toothpaste:getUsedDelta() + 0.1)

    -- AQUI é onde vamos resetar o timer de higiene.
    -- Usamos ModData para salvar essa informação especificamente no seu personagem.
    player:getModData().dentalHygieneProgress = 0
    print("HIGIENE DENTAL: Dentes escovados! Progresso de 'sujeira' zerado.")

    -- OPCIONAL: Dar um pequeno e curto buff de felicidade por ter hálito fresco.
    player:getMoodles():getMoodle(MoodleType.Happy):setEffectiveValue(5, 30) -- +5 de felicidade por 30 minutos de jogo.
end

------------------------------------------------------------------------------------------
-- LÓGICA DO MENU: Adiciona a opção "Escovar Dentes" ao clicar com o botão direito.
------------------------------------------------------------------------------------------
function DentalCare.onFillContextMenu(player, context, worldobjects)
    -- Primeiro, verificamos se o jogador clicou em algo com água (uma pia, por exemplo).
    local clickedWaterSource = false
    -- worldobjects é uma tabela com tudo que o jogador clicou.
    for i, obj in ipairs(worldobjects) do
        -- A maioria dos objetos de pia/torneira tem "faucet" no nome do sprite.
        if obj:getSprite() and obj:getSprite():getName() and string.find(obj:getSprite():getName(), "faucet") then
            clickedWaterSource = true
            break
        end
    end
    -- Se não foi numa fonte de água, a função para.
    if not clickedWaterSource then return end

    -- Agora, verificamos se o jogador tem os itens necessários no inventário principal.
    local hasToothbrush = player:getInventory():contains("Base.Toothbrush")
    local hasToothpaste = player:getInventory():contains("Base.Toothpaste")

    -- Se ele tiver ambos, adicionamos a opção ao menu.
    if hasToothbrush and hasToothpaste then
        context:addOption("Escovar Dentes", worldobjects, DentalCare.performBrushTeeth, player)
    end
end

------------------------------------------------------------------------------------------
-- LÓGICA DO TIMER: Aumenta a "sujeira" e aplica os Moodle.
------------------------------------------------------------------------------------------

-- Vamos checar a cada 60 minutos de jogo (3600 ticks, já que OnPlayerUpdate roda ~60x por segundo)
DentalCare.ticksPorHora = 3600
DentalCare.tickCounter = 0

function DentalCare.updateTimer(player)
    -- Incrementa nosso contador de ticks
    DentalCare.tickCounter = DentalCare.tickCounter + 1

    -- Se ainda não passou uma hora de jogo, não fazemos nada.
    if DentalCare.tickCounter < DentalCare.ticksPorHora then
        return
    end

    -- Se passou uma hora, resetamos o contador e rodamos nossa lógica.
    DentalCare.tickCounter = 0

    -- Pega ou inicializa o progresso de higiene do jogador.
    -- O 'or 0' garante que, se a variável não existir, ela comece com o valor 0.
    local hygieneProgress = player:getModData().dentalHygieneProgress or 0

    -- Aumenta o progresso de "sujeira" em 1 a cada hora.
    hygieneProgress = hygieneProgress + 1
    player:getModData().dentalHygieneProgress = hygieneProgress
    
    -- DEBUG: Imprime o valor atual para podermos testar.
    -- Remova ou comente esta linha quando o mod estiver pronto.
    print("HIGIENE DENTAL: Progresso atual = " .. hygieneProgress)

    -- AQUI VAI A LÓGICA DOS MOODLES (nosso próximo passo)
    
end

------------------------------------------------------------------------------------------
-- EVENTOS: "Ligamos" nossa nova função
------------------------------------------------------------------------------------------
Events.OnPlayerUpdate.Add(DentalCare.updateTimer)
------------------------------------------------------------------------------------------
-- EVENTOS: "Ligamos" nossas funções nos eventos do jogo.
------------------------------------------------------------------------------------------
-- Conecta nossa função ao evento que constrói o menu de contexto do mundo.
Events.onFillWorldObjectContextMenu.Add(DentalCare.onFillContextMenu)

print("Mod Higiene Dental v1.0 [Ação] carregado.")