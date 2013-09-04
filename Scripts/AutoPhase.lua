require("libs.Utils")

function Tick( tick )
    if PlayingGame() and SleepCheck() then
        if not me:IsChanneling() and not me.invisible then
            if me:SafeCastItem("item_phase_boots") then
                Sleep(1000)
            end
        end
   	end
end

script:RegisterEvent(EVENT_TICK,Tick)