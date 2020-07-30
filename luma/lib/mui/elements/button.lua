return function(luma,mui)
local eztask = luma:import "eztask"
local lmath  = luma:import "lmath"
local class  = luma:import "class"
local gel    = luma:import "gel"

local button=gel.class.image:extend()

function button:__tostring()
	return "button"
end

function button:new()
	button.super.new(self)
	
	self.selected_color     = eztask.property.new(mui.layout.button.selected.color)
	self.selected_opacity   = eztask.property.new(mui.layout.button.selected.opacity)
	self.unselected_color   = eztask.property.new(mui.layout.button.unselected.color)
	self.unselected_opacity = eztask.property.new(mui.layout.button.unselected.opacity)
	
	self.update_appearance = eztask.signal.new()
	
	self:set("reactive",true)
	:set("background_opacity",0)
	:set("image",mui.layout.texture)
	:set("image_opacity",self.unselected_opacity.value)
	:set("image_color",self.unselected_color.value)
	:set("image_scale",gel.enum.scale_mode.slice)
	:set("rect_offset",mui.layout.button.unselected.rect_offset)
	:set("slice_center",mui.layout.button.unselected.slice_center)
	
	self.container=gel.new("element")
	:set("name","container")
	:set("visible",true)
	:set("position",mui.layout.button.unselected.container.position)
	:set("size",mui.layout.button.unselected.container.size)
	:set("parent",self)
	
	self.update_appearance:attach(function()
		if self.selected.value then
			self:set("rect_offset",mui.layout.button.selected.rect_offset)
			:set("slice_center",mui.layout.button.selected.slice_center)
			:set("image_opacity",self.selected_opacity.value)
			:set("image_color",self.selected_color.value)
			
			self.container:set("position",mui.layout.button.selected.container.position)
			:set("size",mui.layout.button.selected.container.size)
		else
			self:set("rect_offset",mui.layout.button.unselected.rect_offset)
			:set("slice_center",mui.layout.button.unselected.slice_center)
			:set("image_opacity",self.unselected_opacity.value)
			:set("image_color",self.unselected_color.value)
			
			self.container:set("position",mui.layout.button.unselected.container.position)
			:set("size",mui.layout.button.unselected.container.size)
		end
	end)
	
	self.selected:attach(self.update_appearance)
	self.selected_color:attach(self.update_appearance)
	self.selected_opacity:attach(self.update_appearance)
	self.unselected_color:attach(self.update_appearance)
	self.unselected_opacity:attach(self.update_appearance)
end

function button:delete()
	button.super.delete(self)
end

return button
end