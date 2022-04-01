pro asu_set_hash, h, key, index, field, value

str = h[key, index]
names = tag_names(str)
idx = where(strlowcase(field) eq strlowcase(names))
str.(idx) = value
h[key, index] = str

end