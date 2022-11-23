function asu_get_safe_json_key, hashvar, field, default

if hashvar.HasKey(field) then begin
    value = hashvar[field]
endif else begin
    value = default
endelse    

return, value

end
