--
-- classic
--
-- Copyright (c) 2014, rxi
--
-- This module is free software; you can redistribute it and/or modify it under
-- the terms of the MIT license. See LICENSE for details.
--

local object={}

object.__index=object

function object:new() end

function object:extend()
	local class={}
	for k,v in pairs(self) do
		if k:sub(1,2)=="__" then
			class[k]=v
		end
	end
	class.__index=class
	class.super=self
	setmetatable(class,self)
	return class
end

function object:implement(...)
	for i=1,select("#") do
		local class=select(i,...)
		for k,v in pairs(class) do
			if self[k]==nil and type(v)=="function" then
				self[k]=v
			end
		end
	end
end

function object:is(class_type)
	local class=self.__index
	while class do
		if class==class_type then
			return true
		end
		class=class.super
	end
	return false
end

function object:__tostring()
	return "object"
end

function object:__call(...)
	local new_object=setmetatable({},self)
	new_object:new(...)
	return new_object
end

return object