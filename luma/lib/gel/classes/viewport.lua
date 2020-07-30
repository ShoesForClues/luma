return function(luma,gel)
local eztask = luma:import "eztask"
local lmath  = luma:import "lmath"
local class  = luma:import "class"

-------------------------------------------------------------------------------

local viewport=gel.class.frame:extend()

function viewport:__tostring()
	return "viewport"
end

viewport.callbacks={}

-------------------------------------------------------------------------------

function viewport:new()
	viewport.super.new(self)
	
	self.buffer         = eztask.property.new()
	self.buffer_color   = eztask.property.new(lmath.color3.new(1,1,1))
	self.buffer_opacity = eztask.property.new(1)
	self.buffer_filter  = eztask.property.new(gel.enum.filter_mode.nearest)
	
	self.buffer:         attach(viewport.callbacks.buffer,self)
	self.buffer_color:   attach(viewport.callbacks.buffer_color,self)
	self.buffer_opacity: attach(viewport.callbacks.buffer_opacity,self)
	self.buffer_filter:  attach(viewport.callbacks.buffer_filter,self)
end

function viewport:delete()
	viewport.super.delete(self)
end

function viewport:draw()
	viewport.super.draw(self)
end

-------------------------------------------------------------------------------

viewport.callbacks.buffer=function(instance)
	instance:append_draw()
end

viewport.callbacks.buffer_color=function(instance)
	instance:append_draw()
end

viewport.callbacks.buffer_opacity=function(instance)
	instance:append_draw()
end

viewport.callbacks.buffer_filter=function(instance)
	instance:append_draw()
end

return viewport
end