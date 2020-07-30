--[[                                                    
Lua Modular Application

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

local luma={
	version = {0,9,6},
	modules = {}
}

-------------------------------------------------------------------------------

function luma.require(...)
	return
		luma.backend and luma.backend.require(...)
		or require(...)
end

function luma:import(source,name)
	assert(
		type(source)=="string" or name,
		"Cannot import with invalid name."
	)
	
	name=name or source:match("[^.]+$") or source
	
	if luma.modules[name] then
		return luma.modules[name]
	end
	
	local required,module_=pcall(luma.require,source)
	module_=required and module_ or source
	
	if type(module_)=="table" and module_.__llib__ then
		module_=module_.__llib__(luma,source,name)
	end
	
	luma.modules[name]=module_
	return module_
end

function luma:run(source,...)
	return luma:import("eztask").thread.new(
		type(source)=="function" and source
		or luma.require(source)
	)(luma,...)
end

-------------------------------------------------------------------------------

function luma:init(deps,backend)
	assert(deps,"Missing core dependencies.")
	assert(backend,"Missing backend module.")
	
	--Import dependencies
	local class  = luma:import( deps.class,  "class"  )
	local lmath  = luma:import( deps.lmath,  "lmath"  )
	local eztask = luma:import( deps.eztask, "eztask" )
	
	--Init backend modules
	backend=backend(luma)
	
	local runtime  = luma:import( backend.runtime,  "runtime"  )
	local graphics = luma:import( backend.graphics, "graphics" )
	local input    = luma:import( backend.input,    "input"    )
	
	--Setup scheduler
	eztask.tick=runtime.get_tick
	runtime.stepped:attach(eztask.step)
end

-------------------------------------------------------------------------------

return luma