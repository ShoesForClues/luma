return function(luma,gel)
local eztask = luma:import "eztask"
local lmath  = luma:import "lmath"
local class  = luma:import "class"

local floor = math.floor
local ceil  = math.ceil

-------------------------------------------------------------------------------

local text=gel.class.frame:extend()

function text:__tostring()
	return "text"
end

text.callbacks={}

-------------------------------------------------------------------------------

function text:new()
	text.super.new(self)
	
	self.font              = eztask.property.new()
	self.text              = eztask.property.new("")
	self.text_color        = eztask.property.new(lmath.color3.new(1,1,1))
	self.text_opacity      = eztask.property.new(0)
	self.text_size         = eztask.property.new(12)
	self.text_scaled       = eztask.property.new(false)
	self.text_wrapped      = eztask.property.new(false)
	self.multiline         = eztask.property.new(false)
	self.text_alignment    = eztask.property.new(gel.enum.text_alignment.center)
	self.text_filter       = eztask.property.new(gel.enum.filter_mode.bilinear)
	self.focused           = eztask.property.new(false)
	self.selectable        = eztask.property.new(false)
	self.editable          = eztask.property.new(false)
	self.cursor_start      = eztask.property.new(0)
	self.cursor_end        = eztask.property.new(0)
	self.highlight_opacity = eztask.property.new(0.5)
	self.highlight_color   = eztask.property.new(lmath.color3.new(0,0.2,1))
	
	self.font:              attach(text.callbacks.font,self)
	self.text:              attach(text.callbacks.text,self)
	self.text_color:        attach(text.callbacks.text_color,self)
	self.text_opacity:      attach(text.callbacks.text_opacity,self)
	self.text_size:         attach(text.callbacks.text_size,self)
	self.text_scaled:       attach(text.callbacks.text_scaled,self)
	self.text_wrapped:      attach(text.callbacks.text_wrapped,self)
	self.multiline:         attach(text.callbacks.multiline,self)
	self.text_alignment:    attach(text.callbacks.text_alignment,self)
	self.text_filter:       attach(text.callbacks.text_filter,self)
	self.focused:           attach(text.callbacks.focused,self)
	self.cursor_start:      attach(text.callbacks.cursor_start,self)
	self.cursor_end:        attach(text.callbacks.cursor_end,self)
	self.highlight_opacity: attach(text.callbacks.highlight_opacity,self)
	self.highlight_color:   attach(text.callbacks.highlight_color,self)
	self.selected:          attach(text.callbacks.selected,self)
	self.gui:               attach(text.callbacks.gui,self)
	self.focused:           attach(text.callbacks.focused,self)
end

function text:delete()
	text.super.delete(self)
	
	if self.focused_text_event then
		self.focused_text_event:detach()
		self.focused_text_event=nil
	end
	
	if self.cursor_drag then
		self.cursor_drag:detach()
	end
	
	if
		self.gui.value
		and self.gui.value.focused_text.value==self
	then
		self.gui.value.focused_text.value=nil
	end
end

function text:draw()
	text.super.draw(self)
end

function text:get_cursor_position(x,y) --Fucky wucky mess
	local text_     = self.text.value
	local font_     = self.font.value
	local ts        = self.text_size.value
	local w,h       = self.absolute_size.value:unpack()
	local wrapped   = self.text_wrapped.value
	local alignment = self.text_alignment.value
	
	local fs=gel.font.get_font_height(font_,ts)
	local tw,th,tl=gel.font.get_text_wrap(text_,font_,ts,wrapped and w)
	local tx,ty=0,0
	
	if alignment==gel.enum.text_alignment.top_center then
		tx,ty=floor(w/2-tw/2),0
	elseif alignment==gel.enum.text_alignment.top_right then
		tx,ty=w-tw,0
	elseif alignment==gel.enum.text_alignment.center_left then
		tx,ty=0,floor(h/2-th/2)
	elseif alignment==gel.enum.text_alignment.center then
		tx,ty=floor(w/2-tw/2),floor(h/2-th/2)
	elseif alignment==gel.enum.text_alignment.center_right then
		tx,ty=w-tw,floor(h/2-th/2)
	elseif alignment==gel.enum.text_alignment.bottom_left then
		tx,ty=0,h-th
	elseif alignment==gel.enum.text_alignment.bottom_center then
		tx,ty=floor(w/2-tw/2),h-th
	elseif alignment==gel.enum.text_alignment.bottom_right then
		tx,ty=w-tw,h-th
	end
	
	local rx,ry=( --Get localized coordinates
		(
			self.absolute_cframe.value
			*lmath.cframe.new(
				-self.absolute_size.value.x*0.5,
				-self.absolute_size.value.y*0.5
			)
		):inverse()
		*lmath.vector3.new(x,y)
	):unpack()
	rx,ry=lmath.clamp(rx-tx,0,tw),lmath.clamp(ry-ty,0,th)
	
	local cx,cy=0,wrapped and lmath.round(ry/th*(#tl-1))+1 or 1
	local line=wrapped and tl[cy] or text_
	local lw=gel.font.get_text_width(line,font_,ts)
	
	if
		alignment==gel.enum.text_alignment.top_center
		or alignment==gel.enum.text_alignment.center
		or alignment==gel.enum.text_alignment.bottom_center
	then
		rx=lmath.clamp(rx-(tw/2-lw/2),0,lw)
	elseif
		alignment==gel.enum.text_alignment.top_right
		or alignment==gel.enum.text_alignment.center_right
		or alignment==gel.enum.text_alignment.bottom_right
	then
		rx=lmath.clamp(rx-(tw-lw),0,lw)
	else
		rx=lmath.clamp(rx,0,lw)
	end
	
	for i=1,line:len() do
		local lw_=gel.font.get_text_width(line:sub(1,i),font_,ts)
		if lw_>=rx then
			local cw=gel.font.get_text_width(line:sub(i,i),font_,ts)
			cx=i-lmath.round((lw_-rx)/cw)
			break
		end
	end
	
	local cursor_position=cx
	if wrapped then
		for l=1,cy-1 do
			cursor_position=cursor_position+tl[l]:len()
		end
	end
	
	return cursor_position
end

-------------------------------------------------------------------------------

text.callbacks.font=function(instance)
	instance:append_draw()
end

text.callbacks.text=function(instance)
	instance:append_draw()
end

text.callbacks.text_color=function(instance)
	instance:append_draw()
end

text.callbacks.text_opacity=function(instance)
	instance:append_draw()
end

text.callbacks.text_size=function(instance)
	instance:append_draw()
end

text.callbacks.text_scaled=function(instance)
	instance:append_draw()
end

text.callbacks.text_wrapped=function(instance)
	instance:append_draw()
end

text.callbacks.multiline=function(instance)
	instance:append_draw()
end

text.callbacks.text_alignment=function(instance)
	instance:append_draw()
end

text.callbacks.text_filter=function(instance)
	instance:append_draw()
end

text.callbacks.focused=function(instance)
	instance:append_draw()
end

text.callbacks.cursor_start=function(instance)
	instance:append_draw()
end

text.callbacks.cursor_end=function(instance)
	instance:append_draw()
end

text.callbacks.highlight_color=function(instance)
	instance:append_draw()
end

text.callbacks.highlight_opacity=function(instance)
	instance:append_draw()
end

text.callbacks.selected=function(instance,selected)
	if instance.cursor_drag then
		instance.cursor_drag:detach()
		instance.cursor_drag=nil
	end
	if not instance.selectable.value then
		return
	end
	
	local x,y=instance.gui.value.cursor_position.value:unpack()
	
	if selected then
		instance.focused.value=selected and instance.selectable.value
		instance.cursor_start.value=instance:get_cursor_position(x,y)
		instance.cursor_end.value=instance.cursor_start.value
		instance.cursor_drag=instance.gui.value.cursor_position:attach(function(_,cursor_position)
			instance.cursor_end.value=instance:get_cursor_position(cursor_position.x,cursor_position.y)
		end)
	else
		instance.cursor_end.value=instance:get_cursor_position(x,y)
	end
end

text.callbacks.gui=function(instance,new_gui,old_gui)
	if instance.focused_text_event then
		instance.focused_text_event:detach()
		instance.focused_text_event=nil
	end
	if
		old_gui
		and old_gui.focused_text.value==instance
	then
		old_gui.focused_text.value=nil
	end
	if new_gui then
		instance.focused_text_event=new_gui.focused_text:attach(function(_,element)
			instance.focused.value=(element==instance)
		end)
	end
end

text.callbacks.focused=function(instance,focused)
	if not instance.gui.value then
		return
	end
	if focused then
		instance.gui.value.focused_text.value=instance
	elseif instance.gui.value.focused_text.value==instance then
		instance.gui.value.focused_text.value=nil
	end
end

-------------------------------------------------------------------------------

return text
end