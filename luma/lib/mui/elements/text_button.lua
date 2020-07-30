return function(luma,mui)
local eztask = luma:import "eztask"
local lmath  = luma:import "lmath"
local class  = luma:import "class"
local gel    = luma:import "gel"

local text_button=mui.class.button:extend()

function text_button:__tostring()
	return "text_button"
end

function text_button:new()
	text_button.super.new(self)
	
	self.selected_text_color     = eztask.property.new(mui.layout.text_button.selected.text_color)
	self.selected_text_opacity   = eztask.property.new(mui.layout.text_button.selected.text_opacity)
	self.unselected_text_color   = eztask.property.new(mui.layout.text_button.unselected.text_color)
	self.unselected_text_opacity = eztask.property.new(mui.layout.text_button.unselected.text_opacity)
	
	self.text_element=gel.new("text")
	:set("name","text_element")
	:set("visible",true)
	:set("size",lmath.udim2.new(1,0,1,0))
	:set("background_opacity",0)
	:set("text","Button")
	:set("text_color",mui.layout.text_button.unselected.text_color)
	:set("text_opacity",mui.layout.text_button.unselected.text_opacity)
	:set("text_size",mui.layout.text_button.unselected.text_size)
	:set("font",mui.layout.font.regular)
	:set("text_alignment",gel.enum.text_alignment.center)
	:set("text_wrapped",false)
	:set("parent",self.container)
	
	self.text           = self.text_element.text
	self.text_color     = self.text_element.text_color
	self.text_opacity   = self.text_element.text_opacity
	self.text_size      = self.text_element.text_size
	self.font           = self.text_element.font
	self.text_alignment = self.text_element.text_alignment
	self.text_wrapped   = self.text_element.text_wrapped
	
	self.update_appearance:attach(function()
		if self.selected.value then
			self.text_element:set("text_color",self.selected_text_color.value)
			:set("text_opacity",self.selected_text_opacity.value)
		else
			self.text_element:set("text_color",self.unselected_text_color.value)
			:set("text_opacity",self.unselected_text_opacity.value)
		end
	end)
	
	self.selected_text_color:attach(self.update_appearance)
	self.selected_text_opacity:attach(self.update_appearance)
	self.unselected_text_color:attach(self.update_appearance)
	self.unselected_text_opacity:attach(self.update_appearance)
end

function text_button:delete()
	text_button.super.delete(self)
end

return text_button
end