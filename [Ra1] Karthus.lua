require ("OpenPredict")
require ("DamageLib")

if GetObjectName(GetMyHero()) ~= 'Karthus' then return end

local ra1Karthus = Menu('Karthus', '[Ra1] Karthus')
  -- Combo
  ra1Karthus:SubMenu('Combo', 'Combo Settings')
  ra1Karthus.Combo:Boolean('Q', 'Use Q', true)
  ra1Karthus.Combo:Boolean('W', 'Use W', true)
  ra1Karthus.Combo:Boolean('E', 'Use E', true)
  ra1Karthus.Combo:Boolean('R', 'Use R', false)

  -- Harass
  ra1Karthus:SubMenu('Harass', 'Harass Settings')
  ra1Karthus.Harass:Boolean('Q', 'Use Q', true)
  ra1Karthus.Harass:Boolean('E', 'Use E', true)
  ra1Karthus.Harass:Slider("Mana", "Min. Mana", 60, 0, 100, 1)

  -- Lane Clear
  ra1Karthus:SubMenu('LaneClear', 'Lane Clear Settings')
  ra1Karthus.LaneClear:Boolean('Q', 'Use Q', true)
  ra1Karthus.LaneClear:Boolean('E', 'Use E', true)
  ra1Karthus.LaneClear:Slider("Mana", "Min. Mana", 70, 0, 100, 1)

  -- Auto
  ra1Karthus:SubMenu('Auto', 'AutoCast Settings')
  ra1Karthus.Auto:Boolean('Q', 'Use Q', true)
  ra1Karthus.Auto:Boolean('aE', 'Enable E when Target is close', true)
  ra1Karthus.Auto:Slider("Mana", "Min. Mana", 80, 0, 100, 1)

  -- AutoKS
  ra1Karthus:SubMenu('AutoKS', 'Auto KS Settings')
  ra1Karthus.AutoKS:Boolean('Q', 'Use Q', true)
  ra1Karthus.AutoKS:Boolean('R', 'KS with R', false)

  -- Draws
  ra1Karthus:SubMenu('Draw', 'Drawing Settings')
  ra1Karthus.Draw:Boolean('HP', 'Draw Enemy Team HP', true)
  ra1Karthus.Draw:DropDown("DrawMode","Draw mode method", 1, {"OnDraw", "OnTick"})

  -- Misc
  ra1Karthus:SubMenu('Misc', 'Misc')
  ra1Karthus.Misc:DropDown("Target","Target method", 1, {"GosTarget", "GameTarget"})
  ra1Karthus.Misc:DropDown("qPred","Q Prediction", 1, {"OpenPredict", "GoS"})
  ra1Karthus.Misc:Slider("qHitChance", "Q HitChance for OpenPredict", 8, 0, 10, 1)

  -- Spells Data
local Spells = {
    Q = {
        range = 875,
        delay = 0.5,
        width = 100,
        radius = 50,
    },
    W = {
        range = 1000,
        delay = 0.1,
        width = 800,
    },
    E = {
        range = 850
    },
    R = {
        range = 10000
    },
}

-- Orbwalker
function Mode()
    if _G.IOW_Loaded and IOW:Mode() then
		return IOW:Mode()
	elseif _G.PW_Loaded and PW:Mode() then
		return PW:Mode()
	elseif _G.DAC_Loaded and DAC:Mode() then
		return DAC:Mode()
	elseif _G.AutoCarry_Loaded and DACR:Mode() then
		return DACR:Mode()
	elseif _G.SLW_Loaded and SLW:Mode() then
		return SLW:Mode()
	elseif GoSWalkLoaded and GoSWalk.CurrentMode then
		return ({"Combo", "Harass", "LaneClear", "LastHit"})[GoSWalk.CurrentMode+1]
	end
end

-- Cast Functions
function CastQ(customTarget)
    local hitChance = ra1Karthus.Misc.qHitChance:Value() / 10
    if ra1Karthus.Misc.qPred:Value() == 1 then
        PrintChat('OpenPred')
        local qPred = GetCircularAOEPrediction(customTarget, Spells.Q)
        PrintChat(qPred.hitChance .. ' - ' .. hitChance)
        if qPred.hitChance >= hitChance then
            CastSkillShot(_Q, qPred.castPos)
        end
    else 
        local qPred = GetPredictionForPlayer(GetOrigin(myHero), customTarget, GetMoveSpeed(target), 10000, Spells.Q.delay*1000, Spells.Q.range, Spells.Q.width, false, false)
        CastSkillShot(_Q, qPred.PredPos)
    end
end

function CastW()
    local wPred = GetLinearAOEPrediction(target, Spells.W)
    if wPred.hitChance > 0.8 then
        CastSkillShot(_W, wPred.castPos)
    end
end

function CastE()
    CastSpell(_E)
end

function CastR()
    CastSpell(_R)
end

-- Functions
function Combo()
    if Mode() == 'Combo' then
        if ra1Karthus.Combo.W:Value() then
            if Ready(_W) and GetDistance(myHero, target) <= Spells.W.range then
                CastW()
            end
        end
        if ra1Karthus.Combo.Q:Value() then
            if Ready(_Q) and GetDistance(myHero, target) <= Spells.Q.range then
                CastQ(target)
            end
        end
        if ra1Karthus.Combo.E:Value() then
            local isEnabled = GotBuff(myHero, "KarthusDefile")
            if isEnabled == 0 and Ready(_E) and GetDistance(myHero, target) <= Spells.E.range + 10 then
                CastE()
            end
        end
        if ra1Karthus.Combo.R:Value() then
            local safeR = 2500
            for _, enemy in pairs(GetEnemyHeroes()) do
                if GetDistance(myHero, enemy) < safeR then break end
                if getdmg('r', enemy, myHero) >= GetCurrentHP(enemy) then
                    castR()
                end
            end
        end
    end
end

function Harass()
    if Mode() == 'Harass' then
        local manaStatus = (myHero.mana/myHero.maxMana >= ra1Karthus.Harass.Mana:Value() / 100)
        if manaStatus then
            if ra1Karthus.Harass.Q:Value() then
                CastQ(target)
            end
            if ra1Karthus.Harass.E:Value() then
                local isEnabled = GotBuff(myHero, "KarthusDefile")
                if isEnabled == 0 and Ready(_E) and GetDistance(myHero, target) <= Spells.E.range + 10 then
                    CastE()
                end
            end
        end
    end
end

function LaneClear()
    if Mode() == 'LaneClear' then
        local manaStatus = (myHero.mana/myHero.maxMana >= ra1Karthus.LaneClear.Mana:Value() / 100)
        if manaStatus then 
            if ra1Karthus.LaneClear.Q:Value() then
                for _, minion in pairs(minionManager.objects) do
                    if ra1Karthus.LaneClear.Q:Value() then
                        if GetTeam(minion) == MINION_ENEMY and ValidTarget(minion, Spells.Q.range) then
                            CastSkillShot(_Q, GetOrigin(minion))
                        end
                    end
                    if ra1Karthus.LaneClear.E:Value() then
                        local isEnabled = GotBuff(myHero, "KarthusDefile")
                        if GetTeam(minion) == MINION_ENEMY and GetDistance(minion, myHero) <= Spells.E.range and isEnabled == 0 then
                            CastSpell(_E)
                        end    
                    end
                end
            end
        end
    end
end

function Auto()
    local manaStatus = (myHero.mana/myHero.maxMana >= ra1Karthus.Auto.Mana:Value() / 100)
    if manaStatus then
        if ra1Karthus.Auto.Q:Value() and Ready(_Q) and GetDistance(myHero, target) <= Spells.Q.range then
            CastQ(target)
        end
        if ra1Karthus.Auto.aE:Value() then
            if GetDistance(myHero, target) <= Spells.E.range + 50 then
                local isEnabled = GotBuff(myHero, "KarthusDefile")
                if isEnabled == 0 then
                    CastE()
                end
            end
        end
    end
end

function AutoKS()
    for _, enemy in pairs(GetEnemyHeroes()) do
        if ra1Karthus.AutoKS.Q:Value() then
            if getdmg('Q', enemy, myHero) > GetCurrentHP(enemy) and ValidTarget(enemy, Spells.Q.range) then
                CastQ(enemy)
            end
        end
        if ra1Karthus.AutoKS.R:Value() then
            if getdmg('R', enemy, myHero) > GetCurrentHP(enemy) then
                CastR()
            end
        end 
    end
end

function DrawEnemyTeamHP()
    if ra1Karthus.Draw.HP:Value() then
        for _, enemy in pairs(GetEnemyHeroes()) do
            if IsObjectAlive(enemy) == true then
                local maxHp = math.floor(GetMaxHP(enemy))
                local currHp = math.floor(GetCurrentHP(enemy))
                local redColor = ARGB(255, 255, 10, 10)
                local whiteColor = ARGB(255, 255, 255, 255)
                local usedColor = 'null'
                if currHp < getdmg('R', enemy, myHero) then
                    usedColor = redColor
                else
                    usedColor = whiteColor
                end
                DrawText(enemy.name .. ' - ' .. maxHp .. ' / ' .. currHp, 32, 150, 800 + 25 * _, usedColor)
            end
        end
    end
end

OnTick(function()
    if ra1Karthus.Misc.Target:Value() == 1 then
        target = GetCurrentTarget()
    else
        target = GetGameTarget()
    end
    Combo()
    Harass()
    LaneClear()
    Auto()
    AutoKS()
    if ra1Karthus.Draw.DrawMode:Value() == 2 then
        DrawEnemyTeamHP()
    end
end)

OnDraw(function()
    if ra1Karthus.Draw.DrawMode:Value() == 1 then
        DrawEnemyTeamHP()
    end
end)
