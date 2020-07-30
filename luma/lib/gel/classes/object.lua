return function(luma,gel)
local eztask = luma:import "eztask"
local lmath  = luma:import "lmath"
local class  = luma:import "class"

local remove = table.remove
local insert = table.insert

-------------------------------------------------------------------------------

local object=class:extend()

function object:__tostring()
	return "object"
end

object.callbacks={}

-------------------------------------------------------------------------------

function object:new()
	self.children      = {}
	self.children_name = {}
	
	self.parent = eztask.property.new()
	self.name   = eztask.property.new(tostring(self))
	self.index  = eztask.property.new()
	
	self.child_added   = eztask.signal.new()
	self.child_removed = eztask.signal.new()
	
	self.parent: attach(object.callbacks.parent,self)
	self.name:   attach(object.callbacks.name,self)
	self.index:  attach(object.callbacks.index,self)
end

function object:delete()
	self.parent.value=nil
	for i=#self.children,1,-1 do
		self.children[i]:delete()
	end
	for _,atr in pairs(self) do
		local mt=getmetatable(atr)
		if
			mt==eztask.callback
			or mt==eztask.signal
			or mt==eztask.property
		then
			atr:detach()
		end
	end
end

function object:get_children(name)
	return self.children_name[name] or self.children
end

function object:get_child(name)
	if self.children_name[name] then
		return next(self.children_name[name])
	end
end

function object:set(property_name,value)
	self[property_name].value=value
	return self
end

-------------------------------------------------------------------------------

object.callbacks.parent=function(instance,new_parent,old_parent)
	local name=instance.name.value
	local index=instance.index.value
	if old_parent then
		if old_parent.children_name[name] then
			old_parent.children_name[name][instance]=nil
			if not next(old_parent.children_name[name]) then
				old_parent.children_name[name]=nil
			end
		end
		if old_parent.children[index]==instance then
			remove(old_parent.children,instance.index.value)
		end
		for i=instance.index.value,#old_parent.children do
			old_parent.children[i].index.value=i
		end
		old_parent.child_removed(instance)
	end
	if new_parent then
		local objects=new_parent.children_name[name] or {}
		objects[instance]=instance
		new_parent.children_name[name]=objects
		instance.index._value=#new_parent.children+1
		new_parent.children[instance.index.value]=instance
		new_parent.child_added(instance)
	end
end

object.callbacks.name=function(instance,new_name,old_name)
	local parent=instance.parent.value
	new_name=tostring(new_name or instance)
	instance.name._value=new_name
	if not parent then
		return
	end
	if old_name and parent.children_name[old_name] then
		parent.children_name[old_name][instance]=nil
		if not next(parent.children_name[old_name]) then
			parent.children_name[old_name]=nil
		end
	end
	if new_name then
		local objects=parent.children_name[new_name] or {}
		objects[instance]=instance
		parent.children_name[new_name]=objects
	end
end

object.callbacks.index=function(instance,new_index,old_index)
	if not instance.parent.value then
		instance.index._value=0
		return
	end
	local children=instance.parent.value.children
	new_index=lmath.clamp(new_index or #children,1,#children)
	instance.index._value=new_index
	if children[old_index]==instance then
		remove(children,old_index)
	else
		for i,child in ipairs(children) do
			if child==instance then
				remove(children,i);break
			end
		end
	end
	insert(children,new_index,instance)
	for i,child in ipairs(children) do
		child.index.value=i
	end
end

-------------------------------------------------------------------------------

return object
end