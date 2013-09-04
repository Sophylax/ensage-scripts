
--[[
 0 1 0 1 0 0 1 1    
 0 1 1 0 1 1 1 1        ____          __        __         
 0 1 1 1 0 0 0 0       / __/__  ___  / /  __ __/ /__ ___ __
 0 1 1 0 1 0 0 0      _\ \/ _ \/ _ \/ _ \/ // / / _ `/\ \ /
 0 1 1 1 1 0 0 1     /___/\___/ .__/_//_/\_, /_/\_,_//_\_\ 
 0 1 1 0 1 1 0 0             /_/        /___/             
 0 1 1 0 0 0 0 1    
 0 1 1 1 1 0 0 0  

                All-in-One GUI Helper

        Rune and Roshan monitor at the top bar

        Rune monitoring at the minimap

        Side-Screen enemy monitoring

        Missing hero monitor at the side of the minimap
        -When an enemy is missing ETA timer appears
        -ETA timer ignores terrain and assumes heroes ms as 500 (because you can't know when a guy will have haste)

        Last known location of the missing heroes shown at the minimap and actual position
        -Minimap: Mini icon of the hero
        -Actual Position: Hero name and HP percent

        6 Different 4:3 resolution support
        -800x600
        -1024x768
        -1152x864
        -1280x960
        -1280x1024
        -1600x1200

        5 Different 16:9 resolution support
        -1280x720
        -1360x768
        -1366x768
        -1600x900
        -1920x1080

        5 Different 16:10 resolution support
        -1280x768
        -1280x800
        -1440x900
        -1680x1050
        -1920x1200

        Special Thanks:
        -Zynox: For Ensage, RuneMarker Script and RoshanTimer Script
        -Ryan: For completely adapting the script to 4:3 resolutions
        -4xing: For his idea of Side-Screen enemy monitoring
]]


--==A lot of constants==--
init = false
location = {}
--Roshan Monitor
deathTick = nil
tickDelta = 0
roshText = ""
--Rune Monitor
filename = ""
runeMsg = nil
--Missing Monitor
MapLeft = -8000
MapTop = 7350
MapRight = 7500
MapBottom = -7200
MapWidth = math.abs(MapLeft - MapRight)
MapHeight = math.abs(MapBottom - MapTop)
lastseenList = {}
--Settings Table for 16 resolution
ResTable = 
{
 -- Settings for 4:3
 {800,600,{rosh = {x = 640, y = 3},rune = {x = 730, y = 3},minimap={px = 4, py = 5, h = 146, w = 151},ssMonitor={x = 172, y = 488, h = 19, w =84, size = 12},sideview={w = 82, h = 60, t = 77, b = 200}}},
 {1024,768,{rosh = {x = 820, y = -1},rune = {x = 820 , y = 13},minimap={px = 5, py = 7, h = 186, w = 193},ssMonitor={x = 222, y = 625, h = 25, w = 104, size = 12},sideview={w = 82, h = 60, t = 90, b = 240}}}, 
 {1152,864,{rosh = {x = 930, y = 0},rune = {x = 930 , y = 16},minimap={px = 6, py = 7, h = 211, w = 217},ssMonitor={x = 249, y = 703, h = 27, w = 115, size = 13},sideview={w = 82, h = 60, t = 90, b = 266}}},
 {1280,960,{rosh = {x = 1030, y = 1},rune = {x = 1030 , y = 19},minimap={px = 6, py = 9, h = 233, w = 241},ssMonitor={x = 277, y = 782, h = 30, w = 130, size = 14},sideview={w = 82, h = 60, t = 99, b = 290}}},
 {1280,1024,{rosh = {x = 1030, y = 3},rune = {x = 1030 , y = 21},minimap={px = 6, py = 9, h = 233, w = 241},ssMonitor={x = 277, y = 845, h = 30, w = 130, size = 14},sideview={w = 82, h = 60, t = 99, b = 290}}},
 {1360,1024,{rosh = {x = 1100, y = 3},rune = {x = 1100 , y = 21},minimap={px = 6, py = 11, h = 246, w = 260},ssMonitor={x = 296, y = 835, h = 30, w = 132, size = 14},sideview={w = 82, h = 60, t = 99, b = 290}}},
 {1600,1200,{rosh = {x = 1395, y = 6},rune = {x = 1395 , y = 24},minimap={px = 8, py = 14, h = 288, w = 304},ssMonitor={x = 346, y = 978, h = 37, w = 156, size = 15},sideview={w = 82, h = 60, t = 99, b = 360}}},
 -- Settings for 16:9
 {1280,720,{rosh = {x = 150, y = 4},rune = {x = 241 , y = 4},minimap={px = 8, py = 8, h = 174, w = 181},ssMonitor={x = 200, y = 605, h = 21, w = 90, size = 12},sideview={w = 82, h = 60, t = 29, b = 193}}},
 {1360,768,{rosh = {x = 167, y = 6},rune = {x = 258 , y = 6},minimap={px = 8, py = 8, h = 186, w = 193},ssMonitor={x = 213, y = 645, h = 23, w = 95, size = 13},sideview={w = 82, h = 60, t = 31, b = 206}}},
 {1366,768,{rosh = {x = 167, y = 6},rune = {x = 258 , y = 6},minimap={px = 8, py = 8, h = 186, w = 193},ssMonitor={x = 213, y = 645, h = 23, w = 95, size = 13},sideview={w = 82, h = 60, t = 31, b = 206}}},
 {1600,900,{rosh = {x = 202, y = 9},rune = {x = 293 , y = 9},minimap={px = 9, py = 9, h = 217, w = 227},ssMonitor={x = 250, y = 756, h = 27, w = 100, size = 14},sideview={w = 82, h = 60, t = 37, b = 242}}},
 {1920,1080,{rosh = {x = 212, y = 3},rune = {x = 212 , y = 21},minimap={px = 11, py = 11, h = 261, w = 272},ssMonitor={x = 300, y = 907, h = 32, w = 100, size = 14},sideview={w = 82, h = 60, t = 44, b = 290}}},
 -- Settings for 16:10
 {1280,768,{rosh = {x = 146, y = 6},rune = {x = 236 , y = 6},minimap={px = 8, py = 8, h = 186, w = 193},ssMonitor={x = 283, y = 620, h = 25, w = 103, size = 13},sideview={w = 82, h = 60, t = 31, b = 206}}},
 {1280,800,{rosh = {x = 1020, y = 6},rune = {x = 1110 , y = 6},minimap={px = 8, py = 10, h = 192, w = 203},ssMonitor={x = 283, y = 652, h = 25, w = 103, size = 13},sideview={w = 82, h = 60, t = 31, b = 206}}},
 {1440,900,{rosh = {x = 172, y = 9},rune = {x = 262 , y = 9},minimap={px = 9, py = 9, h = 217, w = 227},ssMonitor={x = 318, y = 734, h = 28, w = 115, size = 14},sideview={w = 82, h = 60, t = 37, b = 242}}},
 {1680,1050,{rosh = {x = 212, y = 3},rune = {x = 212 , y = 21},minimap={px = 10, py = 11, h = 252, w = 267},ssMonitor={x = 277, y = 857, h = 32, w = 95, size = 14},sideview={w = 82, h = 60, t = 44, b = 290}}},
 {1920,1200,{rosh = {x = 242, y = 6},rune = {x = 242 , y = 24},minimap={px = 12, py = 14, h = 288, w = 304},ssMonitor={x = 320, y = 977, h = 32, w = 100, size = 14},sideview={w = 82, h = 60, t = 44, b = 290}}},
}

function Tick(tick)
    if not engineClient.inGame or engineClient.console or not me then
        DeInit()
        return
    end

    DrawInit()

    RoshanTick()

    MissingTick()

    RuneTick()

    SideTick()
end

heroCount = 0

function MissingTick()
    --Missing heroes monitoring
    local heroes = entityList:FindEntities({type=TYPE_HERO,team=TEAM_ENEMY})
    for i,v in ipairs(heroes) do
        if v.replicatingModel == -1 and not v.illusion then
            if missingMonitor.side.heroes[v.handle] == nil then
                heroCount = heroCount + 1
                missingMonitor.side.heroes[v.handle] = {}
                missingMonitor.side.heroes[v.handle].bmp = drawManager:CreateRectM(location.ssMonitor.x,location.ssMonitor.y+location.ssMonitor.h*(heroCount-1),32,32,"NyanUI/miniheroes/"..v.name)
                missingMonitor.side.heroes[v.handle].missTime = drawManager:CreateText(location.ssMonitor.x + 34,location.ssMonitor.y+2+location.ssMonitor.h*(heroCount-1),location.ssMonitor.size,0x00000000,"Missing: ")
                missingMonitor.side.heroes[v.handle].etaTime = drawManager:CreateText(location.ssMonitor.x + 34,location.ssMonitor.y+2+location.ssMonitor.size+location.ssMonitor.h*(heroCount-1),location.ssMonitor.size,0x00000000,"ETA: ")
                missingMonitor.side.heroes[v.handle].visibleText = drawManager:CreateText(location.ssMonitor.x + 40,location.ssMonitor.y+location.ssMonitor.size/2+2+location.ssMonitor.h*(heroCount-1),location.ssMonitor.size,0xFFFFFFFF,"  Visible")
                missingMonitor.side.heroes[v.handle].miniBMP = nil
                missingMonitor.side.heroes[v.handle].mapText = {}
                missingMonitor.side.heroes[v.handle].mapText.top = nil
                missingMonitor.side.heroes[v.handle].mapText.bot = nil
            end
            if lastseenList[v.handle] == nil and v.visible == false then
                lastseenList[v.handle] = GetGameTime()
                missingMonitor.side.heroes[v.handle].missTime.color = 0xFFFFFFFF
                missingMonitor.side.heroes[v.handle].etaTime.color = 0xFFFFFFFF
                missingMonitor.side.heroes[v.handle].visibleText.color = 0x00000000
            elseif v.visible == true then
                lastseenList[v.handle] = nil
                missingMonitor.side.heroes[v.handle].missTime.color = 0x00000000
                missingMonitor.side.heroes[v.handle].etaTime.color = 0x00000000
                missingMonitor.side.heroes[v.handle].visibleText.color = 0xFFFFFFFF
                if missingMonitor.side.heroes[v.handle].miniBMP then
                    missingMonitor.side.heroes[v.handle].miniBMP:Destroy()
                    missingMonitor.side.heroes[v.handle].miniBMP = nil
                end
                if missingMonitor.side.heroes[v.handle].mapText.top then
                    missingMonitor.side.heroes[v.handle].mapText.top:Destroy()
                   missingMonitor.side.heroes[v.handle].mapText.top = nil
                    missingMonitor.side.heroes[v.handle].mapText.bot:Destroy()
                   missingMonitor.side.heroes[v.handle].mapText.bot = nil
                end
            end
            if not v.visible and not v.illusion then
                --Minimap Draw
                local coord = MapToMinimap(v.x,v.y)
                if not missingMonitor.side.heroes[v.handle].miniBMP then
                    missingMonitor.side.heroes[v.handle].miniBMP = drawManager:CreateRectM(coord.x-8,coord.y-8,16,16,"NyanUI/miniheroes/"..v.name)
                end

                --Mainmap Draw
                local pos = Vector()
                if v:ScreenPosition(pos) and IsInScreen(pos) and v.alive then
                    if not missingMonitor.side.heroes[v.handle].mapText.top then
                        missingMonitor.side.heroes[v.handle].mapText.top = drawManager:CreateText(math.floor(pos.x),math.floor(pos.y)-30,0xFFFFFFFF,v.name)
                        missingMonitor.side.heroes[v.handle].mapText.bot = drawManager:CreateText(math.floor(pos.x),math.floor(pos.y)-15,0xFFFFFFFF,math.floor(100*v.health/v.maxHealth).."% HP")
                    elseif missingMonitor.side.heroes[v.handle].mapText.top.x ~= math.floor(pos.x) or missingMonitor.side.heroes[v.handle].mapText.top.y ~= math.floor(pos.y)-30 then
                        missingMonitor.side.heroes[v.handle].mapText.top:SetPosition(math.floor(pos.x),math.floor(pos.y)-30)
                        missingMonitor.side.heroes[v.handle].mapText.bot:SetPosition(math.floor(pos.x),math.floor(pos.y)-15)
                    end
                elseif missingMonitor.side.heroes[v.handle].mapText.top then
                    missingMonitor.side.heroes[v.handle].mapText.top:Destroy()
                    missingMonitor.side.heroes[v.handle].mapText.bot:Destroy()
                    missingMonitor.side.heroes[v.handle].mapText.top = nil
                    missingMonitor.side.heroes[v.handle].mapText.bot = nil
                end

                --Miss timer
                local delta = GetGameTime() - lastseenList[v.handle]
                local minutes = math.floor(delta/60)
                local seconds = delta%60
                local ssText
                if minutes > 0 then
                        ssText = string.format("Missing: "..minutes..":%02d",seconds)
                else
                        ssText = string.format("Missing: %02d",seconds)
                end
                missingMonitor.side.heroes[v.handle].missTime:SetText(ssText)

                --ETA timer
                local distance = GetDistance2D(v,me)
                local proximity = distance/500 - delta
                local proxText
                if proximity > 0 then
                        local proxMin = math.floor(proximity/60)
                        local proxSec = proximity%60
                        if minutes > 0 then
                                proxText = string.format("ETA: "..proxMin..":%02d",proxSec)
                        else
                                proxText = string.format("ETA: %02d",proxSec)
                        end
                else
                        proxText = "   Careful"
                end
                missingMonitor.side.heroes[v.handle].etaTime:SetText(proxText)
            end
        end
    end
end

function SideTick()
    local pos = Vector()
    local _x
    local _y
    local center = {x = drawManager.screenWidth/2 , y = drawManager.screenHeight/2}
    enemies = entityList:FindEntities({type=TYPE_HERO,team=TEAM_ENEMY,alive=true})
    for i,v in ipairs(enemies) do
        if v:ScreenPosition(pos) and v.replicatingModel == -1 and not v.illusion and v.visible then
            if pos.x < 0 or pos.x > drawManager.screenWidth or pos.y < location.sideview.t or pos.y > drawManager.screenHeight - location.sideview.b then
                local slope = (pos.y - center.y) / (pos.x - center.x)
                if (pos.x - center.x < 0 and slope < (drawManager.screenHeight/2-location.sideview.t)/(drawManager.screenWidth/2) and slope > -(drawManager.screenHeight/2-location.sideview.b)/(drawManager.screenWidth/2)) or (pos.x - center.x >= 0 and slope > -(drawManager.screenHeight/2-location.sideview.t)/(drawManager.screenWidth/2) and slope < (drawManager.screenHeight/2-location.sideview.b)/(drawManager.screenWidth/2)) then
                    if pos.x < 0 then
                        _x = location.sideview.w
                        _y = math.floor(center.y + slope * (_x - center.x))
                    else
                        _x = drawManager.screenWidth - location.sideview.w
                        _y = math.floor(center.y + slope * (_x - center.x))
                    end
                else
                    if pos.y < location.sideview.t then
                        _y = location.sideview.t
                        _x = math.floor(center.x + (_y-center.y)/slope)
                    else
                        _y = drawManager.screenHeight - location.sideview.b
                        _x = math.floor(center.x + (_y-center.y)/slope)
                    end
                end
                if _x and _y then
                    if sideView[v.handle] then
                        sideView[v.handle] = MantainSideBox(v,_x,_y,sideView[v.handle])
                    else
                        sideView[v.handle] = CreateSideBox(v,_x,_y)
                    end
                elseif sideView[v.handle] then
                    if sideView[v.handle].border then
                        sideView[v.handle].border:Destroy()
                        sideView[v.handle].border = nil
                    end
                    if sideView[v.handle].name then
                        sideView[v.handle].name:Destroy()
                        sideView[v.handle].name = nil
                    end
                    if sideView[v.handle].hp then
                        sideView[v.handle].hp:Destroy()
                        sideView[v.handle].hp = nil
                    end
                    if sideView[v.handle].mana then
                        sideView[v.handle].mana:Destroy()
                        sideView[v.handle].mana = nil
                    end
                    if sideView[v.handle].distance then
                        sideView[v.handle].distance:Destroy()
                        sideView[v.handle].distance = nil
                    end
                end
            else
                if sideView[v.handle] then
                    if sideView[v.handle].border then
                        sideView[v.handle].border:Destroy()
                        sideView[v.handle].border = nil
                    end
                    if sideView[v.handle].name then
                        sideView[v.handle].name:Destroy()
                        sideView[v.handle].name = nil
                    end
                    if sideView[v.handle].hp then
                        sideView[v.handle].hp:Destroy()
                        sideView[v.handle].hp = nil
                    end
                    if sideView[v.handle].mana then
                        sideView[v.handle].mana:Destroy()
                        sideView[v.handle].mana = nil
                    end
                    if sideView[v.handle].distance then
                        sideView[v.handle].distance:Destroy()
                        sideView[v.handle].distance = nil
                    end
                    sideView[v.handle] = nil
                end
            end
        elseif sideView[v.handle] then
            if sideView[v.handle].border then
                sideView[v.handle].border:Destroy()
                sideView[v.handle].border = nil
            end
            if sideView[v.handle].name then
                sideView[v.handle].name:Destroy()
                sideView[v.handle].name = nil
            end
            if sideView[v.handle].hp then
                sideView[v.handle].hp:Destroy()
                sideView[v.handle].hp = nil
            end
            if sideView[v.handle].mana then
                sideView[v.handle].mana:Destroy()
                sideView[v.handle].mana = nil
            end
            if sideView[v.handle].distance then
                sideView[v.handle].distance:Destroy()
                sideView[v.handle].distance = nil
            end
        end
    end
end

function RoshanTick()
    --Roshan monitoring
    if deathTick and RoshAlive() then
            deathTick = nil
    end

    if deathTick then
        local minutes = math.floor(tickDelta/60)
        local seconds = tickDelta%60
        roshBox.text:SetText(string.format("Roshan: %02d:%02d",9-minutes,59-seconds))
    elseif roshBox.text.text ~= "Roshan: Alive" then
        roshBox.text:SetText("Roshan: Alive")
    end
end

function RuneTick()
    --Rune monitoring
    local runes = entityList:FindEntities({classId=CDOTA_Item_Rune})
    if #runes == 0 then
            if minimapRune then
                minimapRune:Destroy()
                minimapRune = nil
            end
            runeBox.bmp:Destroy()
            runeBox.bmp = drawManager:CreateRectM(location.rune.x,location.rune.y+1,28,14,"NyanUI/items/bottle_empty")
            runeBox.text:SetText("No Rune")
            return 
    end
    if  runeBox.text.text ~= "No Rune" then
            return
    end
    local rune = runes[1]
    local runeType = rune.runeType
    filename = ""
    if runeType == RUNETYPE_DOUBLEDAMAGE then
            runeMsg = "DD"
            filename = "doubledamage"
    elseif runeType == RUNETYPE_HASTE then
            runeMsg = "Haste"
            filename = "haste"
    elseif runeType == RUNETYPE_ILLUSION then
            runeMsg = "Illu"
            filename = "illusion"
    elseif runeType == RUNETYPE_INVISIBILITY then
            runeMsg = "Invis"
            filename = "invis"
    elseif runeType == RUNETYPE_REGENERATION then
            runeMsg = "Reg"
            filename = "regen"
    else
            runeMsg = "???"
    end
    if not mnimapRune then
        local runeMinimap = MapToMinimap(rune)
        local size = 20
        minimapRune = drawManager:CreateRectM(runeMinimap.x-size/2,runeMinimap.y-size/2,size,size,"/NyanUI/minirunes/"..filename)
        if rune.x == -2272 then
                runeMsg = runeMsg .. " TOP"
        else
                runeMsg = runeMsg .. " BOT"
        end
        runeBox.text:SetText(runeMsg)
        runeBox.bmp:Destroy()
        runeBox.bmp = drawManager:CreateRectM(location.rune.x,location.rune.y,16,16,"/NyanUI/runes/"..filename)
    end
end

--Function returns if two tables are same
function CompareTables(t1,t2)
    if #t1 ~= #t2 then return false end
    for i,v in ipairs(t1) do
        if t2[i] ~= v then
            return false
        end
    end
    return true
end

--Function returns x,y coordinates of a point's minimap equilavent
function MapToMinimap(x, y)
        if y == nil then
                _x = x.x - MapLeft
                _y = x.y - MapBottom
        else
                _x = x - MapLeft
                _y = y - MapBottom
        end
        
        local scaledX = math.min(math.max(_x * MinimapMapScaleX, 0), location.minimap.w)
        local scaledY = math.min(math.max(_y * MinimapMapScaleY, 0), location.minimap.h)
        
        local screenX = location.minimap.px + scaledX
        local screenY = drawManager.screenHeight - scaledY - location.minimap.py
        
        return { x = math.floor(screenX), y = math.floor(screenY) }
end

--Function returns whether roshan is alive or not
function RoshAlive()
        local entities = entityList:FindEntities({classId=CDOTA_Unit_Roshan})
        tickDelta = GetGameTime()-deathTick
        if #entities > 0 and tickDelta > 15 then
                local rosh = entities[1]
                if rosh and rosh.alive then
                        return true
                end
        end
        return false
end

function DeInit()
    if init then
        deathTick = nil

        roshBox = {}

        runeBox = {}

        init = false

        minimapRune = nil

        runeMsg = nil

        heroCount = 0

        missingMonitor = {}

        sideView = {}

        collectgarbage("collect")

        init = false
    end
end

function DrawInit()
    if not init then
        roshBox = {}
        roshBox.inside = drawManager:CreateRect(location.rosh.x,location.rosh.y,95,18,0x000000FF)
        roshBox.inBorder = drawManager:CreateRect(location.rosh.x-1,location.rosh.y-1,97,20,0x000000A0,true)
        roshBox.outBorder = drawManager:CreateRect(location.rosh.x-2,location.rosh.y-2,99,22,0x00000050,true)
        roshBox.bmp = drawManager:CreateRectM(location.rosh.x,location.rosh.y,16,16,"NyanUI/miniheroes/roshan")
        roshBox.text = drawManager:CreateText(location.rosh.x+20,location.rosh.y+3,0xFFFFFFFF,"Roshan: Alive")

        runeBox = {}
        runeBox.inside = drawManager:CreateRect(location.rune.x,location.rune.y,95,18,0x000000FF)
        runeBox.inBorder = drawManager:CreateRect(location.rune.x-1,location.rune.y-1,97,20,0x000000A0,true)
        runeBox.outBorder = drawManager:CreateRect(location.rune.x-2,location.rune.y-2,99,22,0x00000050,true)
        runeBox.bmp = drawManager:CreateRectM(location.rune.x,location.rune.y+1,28,14,"NyanUI/items/bottle_empty")
        runeBox.text = drawManager:CreateText(location.rune.x+20,location.rune.y+3,0xFFFFFFFF,"No Rune")

        minimapRune = nil

        missingMonitor = {}
        missingMonitor.miniMap = {}
        missingMonitor.side = {}

        missingMonitor.side.inside = drawManager:CreateRect(location.ssMonitor.x,location.ssMonitor.y,location.ssMonitor.w,5*location.ssMonitor.h,0x000000FF)
        missingMonitor.side.inBorder = drawManager:CreateRect(location.ssMonitor.x-1,location.ssMonitor.y-1,location.ssMonitor.w+2,5*location.ssMonitor.h+2,0x000000A0,true)
        missingMonitor.side.outBorder = drawManager:CreateRect(location.ssMonitor.x-2,location.ssMonitor.y-2,location.ssMonitor.w+4,5*location.ssMonitor.h+4,0x00000050,true)
        missingMonitor.side.heroes = {}

        sideView = {}

        init = true
    end
end

function IsInScreen(vec)
    local w,h = drawManager.screenWidth,drawManager.screenHeight
    return vec.x < w and vec.y < h and vec.x > 0 and vec.y > 0
end


function CreateSideBox(hero,x,y)
    _table = {}
    _x = x-location.sideview.w/2
    _y = y-location.sideview.h/2
    _table.border = drawManager:CreateRect(_x,_y,location.sideview.w,location.sideview.h,0xFFFFFF80,true)
    _table.name = drawManager:CreateText(_x+3,_y,0xFFFFFF80,hero.name)
    _table.hp = drawManager:CreateText(_x+3,_y+15,0xFFFFFF80,math.floor(hero.health).." / "..math.floor(hero.maxHealth))
    _table.mana = drawManager:CreateText(_x+3,_y+30,0xFFFFFF80,math.floor(hero.mana).." / "..math.floor(hero.maxMana))
    if me then
        _table.distance = drawManager:CreateText(_x+3,_y+45,0xFFFFFF80,"Distance: "..math.floor(GetDistance2D(me,hero)))
    end
    return _table
end


function MantainSideBox(hero,x,y,_table)
    if _table and _table.border then
        _x = x-location.sideview.w/2
        _y = y-location.sideview.h/2
        _table.border:SetPosition(_x,_y,location.sideview.w,location.sideview.h)
        _table.name:SetPosition(_x+3,_y)
        --_table.name:SetText(hero.name)
        _table.hp:SetPosition(_x+3,_y+15)
        _table.hp:SetText(math.floor(hero.health).." / "..math.floor(hero.maxHealth))
        _table.mana:SetPosition(_x+3,_y+30)
        _table.mana:SetText(math.floor(hero.mana).." / "..math.floor(hero.maxMana))
        if me and not _table.distance then
            _table.distance = drawManager:CreateText(_x+3,_y+45,0xFFFFFF80,"Distance: "..math.floor(GetDistance2D(me,hero)))
        elseif me and _table.distance then
            _table.distance:SetPosition(_x+3,_y+45)
            _table.distance:SetText("Distance: "..math.floor(GetDistance2D(me,hero)))
        elseif _table.distance then
            _table.distance:Destroy()
            _table.distance = nil
        end
        return _table
    end
end


function FireEvent( name )
    if name == "dota_roshan_kill" then
            deathTick = GetGameTime()
    end
end

function Close()
    deathTick = nil
end

function GetDistance2D(a,b)
    return math.sqrt(math.pow(a.x-b.x,2)+math.pow(a.y-b.y,2))
end

do
    local w,h = drawManager.screenWidth,drawManager.screenHeight
    if w == 0 and h == 0 then
            print("AiO GUI Helper cannot detect your screen resolutions.\nPlease switch to the Borderless Window mode.")
            script:Unload()
    end
    for i,v in ipairs(ResTable) do
            if v[1] == w and v[2] == h then
                    location = v[3]
                    break
            elseif i == #ResTable then
                    print(w.."x"..h.." resolution is unsupported by AiO GUI Helper.")
                    script:Unload()
            end
    end
end


MinimapMapScaleX = location.minimap.w / MapWidth
MinimapMapScaleY = location.minimap.h / MapHeight

script:RegisterEvent(EVENT_TICK,Tick)
script:RegisterEvent(EVENT_DOTA,FireEvent)
script:RegisterEvent(EVENT_CLOSE,Close)
script:RegisterEvent(EVENT_START,Close)