function asu_hash_to_case, h, lower = lower

keys = h.Keys()
hnew = hash()
for i = 0, n_elements(keys)-1 do begin
    val = h[keys[i]]
    s = n_elements(lower) ne 0 && lower ne 0 ? strlowcase(keys[i]) : strupcase(keys[i]) 
    hnew[s] = val
end

return, hnew

end
