function asu_get_hash, h, key, index, field

str = h[key, index]
names = tag_names(str)
idx = where(strlowcase(field) eq strlowcase(names))

return, str.(idx)

end
