return function(luma,mui)
local eztask = luma:import "eztask"
local lmath  = luma:import "lmath"
local class  = luma:import "class"
local gel    = luma:import "gel"

local radio_button=gel.class.element:extend()

function radio_button:__tostring()
	return "radio_button"
end

function radio_button:new()
	radio_button.super.new(self)
	
	self.marked = eztask.property.new(false)
	
	self.update_appearance = eztask.signal.new()
	
	self:set("reactive",true)
	:set("size",lmath.udim2.new(
		0,mui.layout.radio_button.unselected.frame.sprite_size.x,
		0,mui.layout.radio_button.unselected.frame.sprite_size.y
	))
	
	self.frame=gel.new("image")
	:set("name","frame")
	:set("visible",true)
	:set("size",lmath.udim2.new(
		0,mui.layout.radio_button.unselected.frame.sprite_size.x,
		0,mui.layout.radio_button.unselected.frame.sprite_size.y
	))
	:set("background_opacity",0)
	:set("rect_offset",mui.layout.radio_button.unselected.frame.rect_offset)
	:set("image",mui.layout.texture)
	:set("image_color",mui.layout.radio_button.unselected.frame.color)
	:set("image_opacity",mui.layout.radio_button.unselected.frame.opacity)
	:set("parent",self)
	
	self.mark=gel.new("image")
	:set("name","mark")
	:set("visible",true)
	:set("anchor_point",lmath.vector2.new(0.5,0.5))
	:set("position",lmath.udim2.new(0.5,0,0.5,0))
	:set("size",lmath.udim2.new(
		0,mui.layout.radio_button.unselected.mark.sprite_size.x,
		0,mui.layout.radio_button.unselected.mark.sprite_size.y
	))
	:set("background_opacity",0)
	:set("rect_offset",mui.layout.radio_button.unselected.mark.rect_offset)
	:set("image",mui.layout.texture)
	:set("image_color",mui.layout.radio_button.unselected.mark.color)
	:set("image_opacity",mui.layout.radio_button.unselected.mark.opacity)
	:set("parent",self.frame)
	
	self.label=gel.new("text")
	:set("visible",true)
	:set("size",lmath.udim2.new(
		1,-mui.layout.radio_button.unselected.frame.sprite_size.x-5,
		0,mui.layout.radio_button.unselected.frame.sprite_size.y
	))
	:set("anchor_point",lmath.vector2.new(0,0.5))
	:set("position",lmath.udim2.new(
		0,mui.layout.radio_button.unselected.frame.sprite_size.x+5,
		0.5,0
	))
	:set("background_opacity",0)
	:set("text","Radio Button")
	:set("font",mui.layout.font.regular)
	:set("text_alignment",gel.enum.text_alignment.center_left)
	:set("text_size",mui.layout.radio_button.unselected.label.text_size)
	:set("text_color",mui.layout.radio_button.unselected.label.text_color)
	:set("text_opacity",mui.layout.radio_button.unselected.label.text_opacity)
	:set("parent",self.frame)
	
	self.text           = self.label.text
	self.text_color     = self.label.text_color
	self.text_opacity   = self.label.text_opacity
	self.text_size      = self.label.text_size
	self.font           = self.label.font
	self.text_alignment = self.label.text_alignment
	self.text_wrapped   = self.label.text_wrapped
	self.multiline      = self.label.multiline
	
	self.update_appearance:attach(function()
		if self.marked.value then
			self.frame:set("rect_offset",mui.layout.radio_button.selected.frame.rect_offset)
			:set("image_color",mui.layout.radio_button.selected.frame.color)
			:set("image_opacity",mui.layout.radio_button.selected.frame.opacity)
			
			self.mark:set("rect_offset",mui.layout.radio_button.selected.mark.rect_offset)
			:set("image_color",mui.layout.radio_button.selected.mark.color)
			:set("image_opacity",mui.layout.radio_button.selected.mark.opacity)
			
			self.label:set("text_size",mui.layout.radio_button.selected.label.text_size)
			:set("text_color",mui.layout.radio_button.selected.label.text_color)
			:set("text_opacity",mui.layout.radio_button.selected.label.text_opacity)
			
			if self.parent.value then
				for _,neighbor in pairs(self.parent.value.children) do
					if neighbor:is(radio_button) and neighbor~=self then
						neighbor.marked.value=false
					end
				end
			end
		else
			self.frame:set("rect_offset",mui.layout.radio_button.unselected.frame.rect_offset)
			:set("image_color",mui.layout.radio_button.unselected.frame.color)
			:set("image_opacity",mui.layout.radio_button.unselected.frame.opacity)
			
			self.mark:set("rect_offset",mui.layout.radio_button.unselected.mark.rect_offset)
			:set("image_color",mui.layout.radio_button.unselected.mark.color)
			:set("image_opacity",mui.layout.radio_button.unselected.mark.opacity)
			
			self.label:set("text_size",mui.layout.radio_button.unselected.label.text_size)
			:set("text_color",mui.layout.radio_button.unselected.label.text_color)
			:set("text_opacity",mui.layout.radio_button.unselected.label.text_opacity)
		end
	end)
	
	self.marked:attach(self.update_appearance)
	
	self.selected:attach(function(_,selected)
		if selected then
			self.marked.value=not self.marked.value
		end
	end)
end

function radio_button:delete()
	radio_button.super.delete(self)
end

return radio_button
end