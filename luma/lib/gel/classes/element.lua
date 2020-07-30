return function(luma,gel)
local eztask = luma:import "eztask"
local lmath  = luma:import "lmath"
local class  = luma:import "class"

-------------------------------------------------------------------------------

local element=gel.class.object:extend()

function element:__tostring()
	return "element"
end

element.callbacks={}

-------------------------------------------------------------------------------

function element:new()
	element.super.new(self)
	
	self.redraw=true
	
	self.visible      = eztask.property.new(true)
	self.position     = eztask.property.new(lmath.udim2.new())
	self.size         = eztask.property.new(lmath.udim2.new())
	self.rotation     = eztask.property.new(0)
	self.anchor_point = eztask.property.new(lmath.vector2.new())
	self.clip         = eztask.property.new(false)
	self.reactive     = eztask.property.new(false)
	
	--Read only
	self.gui               = eztask.property.new()
	self.absolute_cframe   = eztask.property.new(lmath.cframe.new())
	self.absolute_size     = eztask.property.new(lmath.vector2.new())
	self.absolute_position = eztask.property.new(lmath.vector2.new())
	self.absolute_rotation = eztask.property.new(self.rotation.value)
	self.targeted          = eztask.property.new(false)
	self.selected          = eztask.property.new(false)
	
	--Ugly callbacks!
	self.child_added:   attach(element.callbacks.child_added,self)
	self.child_removed: attach(element.callbacks.child_removed,self)
	self.absolute_size: attach(element.callbacks.absolute_size,self)
	self.index:         attach(element.callbacks.index,self)
	self.visible:       attach(element.callbacks.visible,self)
	self.parent:        attach(element.callbacks.parent,self)
	self.gui:           attach(element.callbacks.gui,self)
	self.targeted:      attach(element.callbacks.targeted,self)
	self.position:      attach(element.callbacks.position,self)
	self.rotation:      attach(element.callbacks.rotation,self)
	self.anchor_point:  attach(element.callbacks.anchor_point,self)
	self.size:          attach(element.callbacks.size,self)
end

function element:delete()
	element.super.delete(self)
end

function element:draw_begin() end
function element:draw_end() end
function element:draw() end

function element:render(clip_parent)
	if not self.visible.value then
		return
	end
	self:draw_begin(clip_parent)
	if self.redraw or not self.clip.value then
		for _,child in ipairs(self.children) do
			if child.render then
				child:render(
					self.clip.value and self
					or clip_parent
				)
			end
		end
		self.redraw=false
	end
	self:draw_end(clip_parent)
end

function element:append_draw()
	if not self.parent.value then
		return
	end
	if not self.parent.value.append_redraw then
		return
	end
	self.parent.value:append_redraw()
end

function element:append_redraw()
	if self.redraw then
		return
	end
	self.redraw=true
	self:append_draw()
end

function element:update_transformation(redraw)
	local append_redraw = "nodraw"
	
	local parent = self.parent.value
	local size   = self.size.value
	local pos    = self.position.value
	local rot    = self.rotation.value
	local anchor = self.anchor_point.value
	
	local parent_abs_size
	local parent_abs_rot
	local parent_abs_cframe
	
	if parent and parent:is(element) then
		parent_abs_size   = parent.absolute_size.value
		parent_abs_rot    = parent.absolute_rotation.value
		parent_abs_cframe = parent.absolute_cframe.value
	elseif self.gui.value then
		parent_abs_size   = self.gui.value.resolution.value
		parent_abs_rot    = 0
		parent_abs_cframe = lmath.cframe.new(
			self.gui.value.resolution.value.x*0.5,
			self.gui.value.resolution.value.y*0.5
		)
	else
		parent_abs_size   = lmath.vector2.new()
		parent_abs_rot    = 0
		parent_abs_cframe = lmath.cframe.new()
	end
	
	local absolute_size=lmath.vector2.new(
		size.x_offset+size.x_scale*parent_abs_size.x,
		size.y_offset+size.y_scale*parent_abs_size.y
	)
	local absolute_cframe=(
		parent_abs_cframe
		*lmath.cframe.new(
			-parent_abs_size.x*0.5
			+pos.x_offset+pos.x_scale*parent_abs_size.x,
			-parent_abs_size.y*0.5
			+pos.y_offset+pos.y_scale*parent_abs_size.y
		)
		*lmath.cframe.from_euler(0,0,rot)
		*lmath.cframe.new(
			absolute_size.x*0.5-absolute_size.x*anchor.x,
			absolute_size.y*0.5-absolute_size.y*anchor.y
		)
	)
	local absolute_position=(
		absolute_cframe
		*lmath.vector3.new(
			-absolute_size.x*0.5,
			-absolute_size.y*0.5
		)
	)
	
	if self.absolute_size.value~=absolute_size then
		self.absolute_size.value=absolute_size
		append_redraw=true
	end
	
	self.absolute_cframe.value   = absolute_cframe
	self.absolute_rotation.value = parent_abs_rot+rot
	self.absolute_position.value = lmath.vector2.new(
		absolute_position.x,
		absolute_position.y
	)
	
	for _,child in ipairs(self.children) do
		if child.update_transformation then
			child:update_transformation(append_redraw)
		end
	end
	
	if redraw~="nodraw" then
		self:append_draw()
	end
end

--Mouse ID=1, Touch ID=2,3,4...
function element:append_cursor(x,y,id,key,state)
	local debounce=false
	
	local absolute_cframe = self.absolute_cframe.value
	local absolute_size   = self.absolute_size.value
	
	local relative_point=(
		(
			absolute_cframe
			*lmath.cframe.new(
				-absolute_size.x*0.5,
				-absolute_size.y*0.5
			)
		):inverse()
		*lmath.vector3.new(x,y)
	)
	
	local in_bound=(
		relative_point.x>=0
		and relative_point.y>=0
		and relative_point.x<absolute_size.x
		and relative_point.y<absolute_size.y
	)
	
	self.targeted.value=in_bound
	
	if in_bound and self.gui.value then
		self.gui.value.targeted_elements[self]=self
		if key then
			self.selected.value=state
		end
		debounce=self.reactive.value
	end
	
	if in_bound or not self.clip.value then
		for i=#self.children,1,-1 do
			local child=self.children[i]
			if
				child
				and child.append_cursor
				and child:append_cursor(x,y,id,key,state)
			then
				break
			end
		end
	end
	
	return debounce
end

-------------------------------------------------------------------------------

element.callbacks.child_added=function(instance)
	instance:append_redraw()
end

element.callbacks.child_removed=function(instance)
	instance:append_redraw()
end

element.callbacks.absolute_size=function(instance)
	instance:append_redraw()
end

element.callbacks.index=function(instance)
	instance:append_draw()
end

element.callbacks.visible=function(instance)
	instance:append_draw()
end

element.callbacks.targeted=function(instance,targeted)
	if not instance.gui.value then
		return
	end
	if not targeted then
		instance.selected.value=false
		instance.gui.value.targeted_elements[instance]=nil
	end
end

element.callbacks.parent=function(instance,new_parent,old_parent)
	instance.selected.value=false
	if new_parent then
		if new_parent:is(gel.class.gui) then
			instance.gui.value=new_parent
		elseif new_parent:is(element) then
			instance.gui.value=new_parent.gui.value
		else
			instance.gui.value=nil
		end
		instance:update_transformation()
	else
		instance.gui.value=nil
	end
end

element.callbacks.gui=function(instance,new_gui,old_gui)
	instance.selected.value=false
	if old_gui then
		old_gui.targeted_elements[instance]=nil
	end
	for _,child in ipairs(instance.children) do
		if child.gui then
			child.gui.value=new_gui
		end
	end
	if new_gui then
		instance:update_transformation()
	end
end

element.callbacks.position=function(instance)
	instance:update_transformation()
end

element.callbacks.rotation=function(instance)
	instance:update_transformation()
end
element.callbacks.anchor_point=function(instance)
	instance:update_transformation()
end

element.callbacks.size=function(instance)
	instance:update_transformation()
end

-------------------------------------------------------------------------------

return element
end