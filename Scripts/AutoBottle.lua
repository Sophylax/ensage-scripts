require("libs.Utils")

function Tick( tick )
	if PlayingGame() and SleepCheck() then
		if not me.invisible and not me:IsChanneling() and me:DoesHaveModifier("modifier_fountain_aura_buff") and not me:DoesHaveModifier("modifier_bottle_regeneration") then
			if me:SafeCastItem("item_bottle") then
				Sleep(500)
			end
		end
	end
end

script:RegisterEvent(EVENT_TICK,Tick)