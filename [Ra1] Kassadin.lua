-- Champion Detect
if GetObjectName(GetMyHero()) ~= "Kassadin" then return end

-- Menu
local ra1Kassadin = Menu('Kassadin','[Ra1] Kassadin')

-- Combo
ra1Kassadin:SubMenu("Combo", "Combo Settings")
ra1Kassadin.Combo:Boolean("Q", "Use Q", true)
ra1Kassadin.Combo:Boolean("W", "Use W", true)
ra1Kassadin.Combo:Boolean("E", "Use E", true)
ra1Kassadin.Combo:Boolean("R", "Use R", true)

-- Harras
ra1Kassadin:SubMenu("Harass", "Harass Settings")
ra1Kassadin.Harass:Boolean("Q", "Use Q", true)
ra1Kassadin.Harass:Boolean("W", "Use W", true)
ra1Kassadin.Harass:Boolean("E", "Use E", true)
ra1Kassadin.Harass:Slider("Mana", "Min. Mana", 50, 0, 100, 1)

-- Lane Clear
ra1Kassadin:SubMenu("LaneClear", "Lane Clear Settings")
ra1Kassadin.LaneClear:Boolean("Q", "Use Q", true)
ra1Kassadin.LaneClear:Boolean("W", "Use W", true)
ra1Kassadin.LaneClear:Boolean("E", "Use E", false)
ra1Kassadin.LaneClear:Boolean("R", "Use R", false)
ra1Kassadin.LaneClear:Slider("Mana", "Min. Mana", 70, 0, 100, 1)

-- Auto
ra1Kassadin:SubMenu("Auto", "Auto Settings")
ra1Kassadin.Auto:Boolean("Q", "Auto Q", false)
ra1Kassadin.Auto:Boolean("E", "Auto E", false)
ra1Kassadin.Auto:Slider("Mana", "Min. Mana", 50, 0, 100, 1)

-- Drawings
ra1Kassadin:SubMenu("Draw", "Draw")
ra1Kassadin.Draw:Boolean("Q", "Draw Q", true)
ra1Kassadin.Draw:Boolean("W", "Draw W", true)
ra1Kassadin.Draw:Boolean("E", "Draw E", true)
ra1Kassadin.Draw:Boolean("R", "Draw R", true)
ra1Kassadin.Draw:Boolean("Disable", "Disable all", false)

local SpellsRange = {
    Q = 650,
    W = 300,
    E = 700,
    R = 500,
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

-- Drawings
function Draw(myHero)
    if myHero.dead or ra1Kassadin.Draw.Disable:Value() then return end
    local pos = GetOrigin(myHero)
    if ra1Kassadin.Draw.Q:Value() then
        DrawCircle(pos, SpellsRange.Q, 1, 1, 0xFFF97F51)
    end
    if ra1Kassadin.Draw.W:Value() then
        DrawCircle(pos, SpellsRange.E, 1, 1, 0xFF82589F)
    end
    if ra1Kassadin.Draw.E:Value() then
        DrawCircle(pos, SpellsRange.W, 1, 1, 0xFF1B9CFC)
    end
    if ra1Kassadin.Draw.R:Value() then
        DrawCircle(pos, SpellsRange.R, 2, 1, 0xFF182C61)
    end
end

function getDistance(trg)
    local enemyTarget = trg
    return math.sqrt( (myHero.x - enemyTarget.x)^2 + (myHero.z - enemyTarget.z)^2 )
end

function castQ()
    CastTargetSpell(target, _Q)
end

function castW()
    if getDistance(target) < 400 then
        CastSpell(_W)
        AttackUnit(target)
    end
end

function castE()
    if getDistance(target) < SpellsRange.E - 10 then
        local targetPos = GetOrigin(target)
        CastSkillShot(_E, targetPos)
    end
end

function castR()
    if getDistance(target) < SpellsRange.R then
        CastTargetSpell(target, _R)
    end
end

function Combo()
    if Mode() == 'Combo' then
        if ra1Kassadin.Combo.Q:Value() and Ready(_Q) then
            castQ()
        end
        if ra1Kassadin.Combo.R:Value() and Ready(_R) then
            castR()
        end
        if ra1Kassadin.Combo.W:Value() and Ready(_W) then
            castW()
        end
        if ra1Kassadin.Combo.E:Value() and Ready(_E) then
            castE()
        end
    end
end

function Harass()
    if Mode() == 'Harass' then
        if 100*GetCurrentMana(myHero)/GetMaxMana(myHero) > ra1Kassadin.Harass.Mana:Value() then
            if ra1Kassadin.Harass.Q:Value() and Ready(_Q) then
                castQ()
            end
            if ra1Kassadin.Harass.W:Value() and Ready(_W) then
                castW()
            end
            if ra1Kassadin.Harass.E:Value() and Ready(_E) then
                castE()
            end
        end
    end
end

function LaneClear()
    if Mode() == 'LaneClear' then
    local HeroMana = 100*GetCurrentMana(myHero)/GetMaxMana(myHero)
        for _, Minion in pairs(minionManager.objects) do
            if GetTeam(Minion) == MINION_ENEMY and HeroMana > ra1Kassadin.LaneClear.Mana:Value() then
                -- Use Q
                if ra1Kassadin.LaneClear.Q:Value() then
                    if ValidTarget(Minion, SpellsRange.Q) and Ready(_Q) then
                        CastTargetSpell(Minion, _Q)
                    end
                end
                -- Use W 
                if ra1Kassadin.LaneClear.W:Value() then
                    if ValidTarget(Minion, SpellsRange.W) and Ready(_W) then
                        CastSpell(_W)
                        AttackUnit(Minion)
                    end
                end
                -- Use E
                if ra1Kassadin.LaneClear.E:Value() then
                    if ValidTarget(Minion, SpellsRange.E) and Ready(_E) then
                        CastSkillShot(_E, GetOrigin(Minion))
                    end
                end
                -- Use R
                if ra1Kassadin.LaneClear.R:Value() then
                    if ValidTarget(Minion, SpellsRange.R) and Ready(_R) then
                        CastSkillShot(_R, GetOrigin(Minion))
                    end
                end
            end
        end
    end
end

function Auto()
    if 100*GetCurrentMana(myHero)/GetMaxMana(myHero) > ra1Kassadin.Auto.Mana:Value() then
        if ra1Kassadin.Auto.Q:Value() and Ready(_Q) then
            castQ()
        end
        if ra1Kassadin.Auto.E:Value() and Ready(_E) then
            castE()
        end
    end
end

OnTick(function()
    target = GetCurrentTarget()
    Combo()
    Harass()
    Auto()
    LaneClear()
    end
)

OnDraw(function(myHero)
        Draw(myHero)
    end
)
