return function(luma,mui)
local eztask = luma:import "eztask"
local lmath  = luma:import "lmath"
local class  = luma:import "class"
local gel    = luma:import "gel"

local text_box=gel.class.image:extend()

function text_box:__tostring()
	return "text_box"
end

function text_box:new()
	text_box.super.new(self)
	
	self:set("reactive",true)
	:set("background_opacity",0)
	:set("image",mui.layout.texture)
	:set("image_opacity",mui.layout.text_box.unfocused.opacity)
	:set("image_color",mui.layout.text_box.unfocused.color)
	:set("image_scale",gel.enum.scale_mode.slice)
	:set("rect_offset",mui.layout.text_box.unfocused.rect_offset)
	:set("slice_center",mui.layout.text_box.unfocused.slice_center)
	
	self.text_element=gel.new("text")
	:set("name","text_element")
	:set("visible",true)
	:set("background_opacity",mui.layout.text_box.unfocused.container.opacity)
	:set("background_color",mui.layout.text_box.unfocused.container.color)
	:set("text","Textbox")
	:set("text_color",mui.layout.text_box.default_text_color)
	:set("text_opacity",1)
	:set("text_size",mui.layout.text_box.default_text_size)
	:set("font",mui.layout.font.regular)
	:set("text_alignment",gel.enum.text_alignment)
	:set("text_wrapped",true)
	:set("clip",true)
	:set("selectable",true)
	:set("editable",true)
	:set("position",mui.layout.text_box.unfocused.container.position)
	:set("size",mui.layout.text_box.unfocused.container.size)
	:set("parent",self)
	
	self.text           = self.text_element.text
	self.text_color     = self.text_element.text_color
	self.text_opacity   = self.text_element.text_opacity
	self.text_size      = self.text_element.text_size
	self.font           = self.text_element.font
	self.text_alignment = self.text_element.text_alignment
	self.text_wrapped   = self.text_element.text_wrapped
	self.multiline      = self.text_element.multiline
	
	self.text_element.focused:attach(function(_,focused)
		if focused then
			self.rect_offset.value=mui.layout.text_box.focused.rect_offset
			self.slice_center.value=mui.layout.text_box.focused.slice_center
			self.image_opacity.value=mui.layout.text_box.focused.opacity
			self.image_color.value=mui.layout.text_box.focused.color
		else
			self.rect_offset.value=mui.layout.text_box.unfocused.rect_offset
			self.slice_center.value=mui.layout.text_box.unfocused.slice_center
			self.image_opacity.value=mui.layout.text_box.unfocused.opacity
			self.image_color.value=mui.layout.text_box.unfocused.color
		end
	end)
end

function text_box:delete()
	text_box.super.delete(self)
end

return text_box
end