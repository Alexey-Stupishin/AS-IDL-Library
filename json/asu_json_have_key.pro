function asu_json_have_key, hashvar, field, nocase = nocase, lower = lower

return, hashvar.HasKey(asu_json_get_name(field, nocase = nocase, lower = lower))

end
