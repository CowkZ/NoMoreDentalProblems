-- ISBrushTeethAction.lua

require "TimedActions/ISBaseTimedAction"

ISBrushTeethAction = ISBaseTimedAction:derive("ISBrushTeethAction")

function ISBrushTeethAction:isValid()
    -- Checa se o jogador ainda tem os itens
    if not self.toothbrush or self.toothbrush:isBroken() then return false end
    if not self.toothpaste or self.toothpaste:getUsedDelta() <= 0 then return false end
    return true
end

function ISBrushTeethAction:start()
    self:setActionAnim("WashFace") -- Animação de lavar o rosto, uma boa aproximação
    self.sound = self.character:playSound("PZ_WashHands")
    self:setOverrideHandModels(self.toothbrush, nil) -- Mostra a escova na mão
end

function ISBrushTeethAction:stop()
    if self.sound and self.character:getEmitter():isPlaying(self.sound) then
        self.character:stopOrTriggerSound(self.sound)
    end
    ISBaseTimedAction.stop(self)
end

function ISBrushTeethAction:perform()
    -- Consome a pasta de dente
    self.toothpaste:Use()

    -- Desgasta a escova de dentes
    self.toothbrush:setCondition(self.toothbrush:getCondition() - 1)

    -- Reseta a higiene do jogador (chamando a função do arquivo de lógica)
    ResetPlayerHygiene(self.character)
    
    -- Bônus de felicidade
    self.character:getMoodles():getMoodle(MoodleType.Happy):setEffectiveValue(5, 30)
    
    ISBaseTimedAction.perform(self)
end

function ISBrushTeethAction:new(character, toothbrush, toothpaste)
    local o = {}
    setmetatable(o, self)
    self.__index = self
    o.character = character
    o.toothbrush = toothbrush
    o.toothpaste = toothpaste
    o.maxTime = 90 -- Duração da ação
    return o
end