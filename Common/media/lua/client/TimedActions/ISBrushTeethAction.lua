-- ISBrushTeethAction.lua (Usando o construtor :new() correto e funcional)

require "TimedActions/ISBaseTimedAction"

ISBrushTeethAction = ISBaseTimedAction:derive("ISBrushTeethAction")

function ISBrushTeethAction:isValid()
    -- Checa se o jogador ainda tem os itens e se eles são utilizáveis
    if not self.character:getInventory():contains(self.toothbrush) or self.toothbrush:isBroken() then return false end
    if not self.character:getInventory():contains(self.toothpaste) then return false end
    if instanceof(self.toothpaste, "Drainable") and self.toothpaste:getCurrentUsesFloat() <= 0 then return false end
    return true
end

function ISBrushTeethAction:waitToStart()
	return false -- Ação começa imediatamente
end

function ISBrushTeethAction:update()
end

function ISBrushTeethAction:start()
    self:setActionAnim("WashFace")
    self.sound = self.character:playSound("PZ_WashHands")
    self:setOverrideHandModels(self.toothbrush, nil)
end

function ISBrushTeethAction:stop()
    if self.sound and self.character:getEmitter():isPlaying(self.sound) then
        self.character:stopOrTriggerSound(self.sound)
    end
    ISBaseTimedAction.stop(self)
end

function ISBrushTeethAction:perform()
    self.toothpaste:Use()
    self.toothbrush:setCondition(self.toothbrush:getCondition() - 0.5)
    ResetPlayerHygiene(self.character)
    ISBaseTimedAction.perform(self)
end

-- A CORREÇÃO FINAL ESTÁ AQUI: Usando o método de construção que funciona.
function ISBrushTeethAction:new(character, toothbrush, toothpaste)
    local o = {}
    setmetatable(o, self)
    self.__index = self
    o.character = character
    o.toothbrush = toothbrush
    o.toothpaste = toothpaste
    o.maxTime = 90
    o.stopOnWalk = true
    o.stopOnRun = true
    return o
end