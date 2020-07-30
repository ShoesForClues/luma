return function(luma,gel)
local eztask = luma:import "eztask"
local lmath  = luma:import "lmath"
local class  = luma:import "class"

-------------------------------------------------------------------------------

local gui=gel.class.object:extend()

function gui:__tostring()
	return "gui"
end

gui.callbacks={}

-------------------------------------------------------------------------------

function gui:new()
	gui.super.new(self)
	
	self.targeted_elements = {}
	
	self.resolution      = eztask.property.new(lmath.vector2.new(0,0))
	self.cursor_position = eztask.property.new(lmath.vector2.new(0,0))
	self.focused_text    = eztask.property.new()
	
	self.cursor_pressed  = eztask.signal.new()
	self.cursor_released = eztask.signal.new()
	self.key_pressed     = eztask.signal.new()
	self.key_released    = eztask.signal.new()
	self.text_input      = eztask.signal.new()
	
	self.resolution:      attach(gui.callbacks.resolution,self)
	self.cursor_position: attach(gui.callbacks.cursor_position,self)
	self.cursor_pressed:  attach(gui.callbacks.cursor_pressed,self)
	self.cursor_released: attach(gui.callbacks.cursor_released,self)
	self.text_input:      attach(gui.callbacks.text_input,self)
	self.key_pressed:     attach(gui.callbacks.key_pressed,self)
end

function gui:draw()
	for _,child in pairs(self.children) do
		if child.render then
			child:render()
		end
	end
end

function gui:append_cursor(x,y,id,key,state)
	local resolution_x=self.resolution.value.x
	local resolution_y=self.resolution.value.y
	
	local cursor_x=lmath.clamp(x,0,resolution_x-1)
	local cursor_y=lmath.clamp(y,0,resolution_y-1)
	
	for _,element in pairs(self.targeted_elements) do
		local relative_point=(
			(
				element.absolute_cframe.value
				*lmath.cframe.new(
					-element.absolute_size.value.x*0.5,
					-element.absolute_size.value.y*0.5
				)
			):inverse()
			*lmath.vector3.new(x,y)
		)
		local in_bound=(
			relative_point.x>=0
			and relative_point.y>=0
			and relative_point.x<element.absolute_size.value.x
			and relative_point.y<element.absolute_size.value.y
		)
		if not in_bound then
			element.targeted.value=false
			self.targeted_elements[element]=nil
		end
	end
	
	for _,child in pairs(self.children) do
		if child.append_cursor then
			if child:append_cursor(
				cursor_x,
				cursor_y,
				id,
				key,
				state
			) then
				break
			end
		end
	end
end

-------------------------------------------------------------------------------

gui.callbacks.resolution=function(instance)
	for _,child in pairs(instance.children) do
		if child.update_transformation then
			child:update_transformation()
		end
	end
end

gui.callbacks.cursor_position=function(instance,position)
	instance:append_cursor(position.x,position.y,1)
end

gui.callbacks.cursor_pressed=function(instance,id,key,x,y)
	instance.focused_text.value=nil
	instance:append_cursor(x,y,1,key,true)
end

gui.callbacks.cursor_released=function(instance,id,key,x,y)
	instance:append_cursor(x,y,1,key,false)
end

gui.callbacks.text_input=function(instance,char_)
	local text_object=instance.focused_text.value
	if
		text_object
		and text_object.editable.value
	then
		local text=text_object.text.value
		local cursor_end=text_object.cursor_end.value
		text_object.text.value=(
			text:sub(0,cursor_end)..
			char_..
			text:sub(cursor_end+1,#text)
		)
		text_object.cursor_end.value=cursor_end+1
	end
end

gui.callbacks.key_pressed=function(instance,key)
	local text_object=instance.focused_text.value
	if not text_object or not text_object.editable.value then
		return
	end
	local text=text_object.text.value
	if key=="left" then
		text_object.cursor_end.value=lmath.clamp(
			text_object.cursor_end.value-1,
			0,
			#text
		)
	elseif key=="right" then
		text_object.cursor_end.value=lmath.clamp(
			text_object.cursor_end.value+1,
			0,
			#text
		)
	elseif key=="backspace" then
		text_object.text.value=(
			text:sub(0,lmath.clamp(text_object.cursor_end.value-1,0,#text))..
			text:sub(text_object.cursor_end.value+1,#text)
		)
		text_object.cursor_end.value=lmath.clamp(
			text_object.cursor_end.value-1,
			0,
			#text
		)
	elseif key=="tab" then
		text_object.text.value=(
			text:sub(0,text_object.cursor_end.value)..
			"\t"..
			text:sub(text_object.cursor_end.value+1,#text)
		)
		text_object.cursor_end.value=text_object.cursor_end.value+1
	elseif key=="return" and text_object.multiline.value then
		text_object.text.value=(
			text:sub(0,text_object.cursor_end.value)..
			"\n"..
			text:sub(text_object.cursor_end.value+1,#text)
		)
		text_object.cursor_end.value=text_object.cursor_end.value+1
	end
end

-------------------------------------------------------------------------------

return gui
end