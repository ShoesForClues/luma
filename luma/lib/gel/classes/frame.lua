return function(luma,gel)
local eztask = luma:import "eztask"
local lmath  = luma:import "lmath"
local class  = luma:import "class"

-------------------------------------------------------------------------------

local frame=gel.class.element:extend()

function frame:__tostring()
	return "frame"
end

frame.callbacks={}

-------------------------------------------------------------------------------

function frame:new()
	frame.super.new(self)
	
	self.background_color   = eztask.property.new(lmath.color3.new(1,1,1))
	self.background_opacity = eztask.property.new(1)
	
	self.background_color:   attach(frame.callbacks.background_color,self)
	self.background_opacity: attach(frame.callbacks.background_opacity,self)
end

function frame:delete()
	frame.super.delete(self)
end

function frame:draw()
	frame.super.draw(self)
end

-------------------------------------------------------------------------------

frame.callbacks.background_color=function(instance)
	instance:append_draw()
end

frame.callbacks.background_opacity=function(instance)
	instance:append_draw()
end

return frame
end