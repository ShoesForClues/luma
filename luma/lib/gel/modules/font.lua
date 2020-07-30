return function(lumi,gel)
local font={loaded={}}

function font.load(source,name)
	if not gel.backend then return end
	name=name or source:match("[^/]+$"):match("(.+)%..+")
	font.loaded[name]=(
		font.loaded[name]
		or gel.backend.font.load(source)
	)
	return name
end

function font.delete(name)
	if not gel.backend then return end
	gel.backend.font.delete(font.loaded[name])
	font.loaded[name]=nil
end

function font.get_font_height(name,font_size)
	if not gel.backend then return 0 end
	return gel.backend.font.get_font_height(
		font.loaded[name],
		font_size
	)
end

function font.get_text_width(text,name,font_size)
	if not gel.backend then return 0 end
	return gel.backend.font.get_text_width(
		text,
		font.loaded[name],
		font_size
	)
end

function font.get_text_wrap(text,name,font_size,wrap)
	if not gel.backend then return 0,0,{} end
	return gel.backend.font.get_text_wrap(
		text,
		font.loaded[name],
		font_size,wrap
	)
end

return font
end