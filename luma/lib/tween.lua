return {__llib__=function(luma,src)
local eztask = luma:import "eztask"
local lmath  = luma:import "lmath"
local easing = luma:import "easing"

local tween={
	_version={0,0,2},
	active={}
}

function tween.new(var,goal,duration,style)
	local ease_function=easing[style] or easing.linear
	
	if tween.active[var] then
		tween.active[var]:kill()
	end
	
	local _thread=eztask.thread.new(function(thread)
		local start=thread:tick()
		local start_value=var.value
		local change=var.value-goal
		
		while thread:tick()<start+duration do
			if type(start_value)=="number" then
				var.value=lmath.lerp(start_value,goal,ease_function(
					thread:tick(),0,1,duration
				))
			else
				var.value=start_value:lerp(goal,ease_function(
					thread:tick(),0,1,duration
				))
			end
			thread:sleep()
		end
		
		var.value=goal
	end)()
	
	local c=_thread.active:attach(function(callback)
		tween.active[var]=nil
		callback:detach()
	end)
	
	tween.active[var]=_thread
	
	return _thread
end

return tween
end}