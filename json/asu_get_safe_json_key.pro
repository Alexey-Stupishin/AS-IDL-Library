function asu_get_safe_json_key, hashvar, field, default, nocase = nocase, lower = lower

f = asu_json_get_name(field, nocase = nocase, lower = lower)

if hashvar.HasKey(f) then begin
    value = hashvar[f]
endif else begin
    value = default
endelse    

return, value

end
