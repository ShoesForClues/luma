return function(lumi,gel)
local texture={loaded={}}

function texture.load(source)
	if not gel.backend then
		return
	end
	texture.loaded[source]=(
		texture.loaded[source]
		or gel.backend.texture.load(source)
	)
	return source
end

function texture.delete(id)
	if not gel.backend then
		return
	end
	gel.backend.texture.delete(texture.loaded[id])
	texture.loaded[id]=nil
end

function texture.get_texture_size(id)
	if not gel.backend then
		return 0,0
	end
	return gel.backend.texture.get_texture_size(
		texture.loaded[id]
	)
end

return texture
end