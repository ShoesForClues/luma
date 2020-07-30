--[[
Graphic Elements Library

MIT License

Copyright (c) 2020 Shoelee

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
]]

--[[
TODO:
- Fix memory leak after deleting objects
- Finish textbox input
- Cleanup gui object implementation
]]

return {__llib__=function(luma,src)
local eztask = luma:import "eztask"
local class  = luma:import "class"
local lmath  = luma:import "lmath"

-------------------------------------------------------------------------------

local gel={
	_version = {0,5,8},
	enum     = {},
	class    = {},
	backend  = nil
}

-------------------------------------------------------------------------------

--Enums
gel.enum.scale_mode={
	stretch = "stretch",
	slice   = "slice",
	tile    = "tile"
}

gel.enum.filter_mode={
	nearest  = "nearest",
	bilinear = "bilinear",
	bicubic  = "bicubic"
}

gel.enum.text_alignment={
	top_left      = "top_left",
	top_center    = "top_center",
	top_right     = "top_right",
	center_left   = "center_left",
	center        = "center",
	center_right  = "center_right",
	bottom_left   = "bottom_left",
	bottom_center = "bottom_center",
	bottom_right  = "bottom_right"
}

-------------------------------------------------------------------------------

--Load modules
gel.font    = luma.require(src..".modules.font")    (luma,gel)
gel.texture = luma.require(src..".modules.texture") (luma,gel)

--Load classes
gel.class.object   = luma.require(src..".classes.object")   (luma,gel)
gel.class.gui      = luma.require(src..".classes.gui")      (luma,gel)
gel.class.element  = luma.require(src..".classes.element")  (luma,gel)
gel.class.frame    = luma.require(src..".classes.frame")    (luma,gel)
gel.class.image    = luma.require(src..".classes.image")    (luma,gel)
gel.class.text     = luma.require(src..".classes.text")     (luma,gel)
gel.class.viewport = luma.require(src..".classes.viewport") (luma,gel)

-------------------------------------------------------------------------------

--Wrap all class methods to backend
for class_name,class_ in pairs(gel.class) do
	for atr_name,atr in pairs(class_) do
		if type(atr)=="function" and atr_name:sub(1,2)~="__" then
			class_[atr_name]=function(instance,...)
				if 
					gel.backend
					and gel.backend.class[class_name]
					and gel.backend.class[class_name][atr_name]
				then
					return
						atr(instance,...),
						gel.backend.class[class_name][atr_name](instance,...)
				else
					return atr(instance,...)
				end
			end
		end
	end
end

-------------------------------------------------------------------------------

function gel.new(class_name,...)
	return gel.class[class_name](...)
end

function gel:init(backend)
	gel.backend=backend(luma,gel)
end

-------------------------------------------------------------------------------

return gel
end}