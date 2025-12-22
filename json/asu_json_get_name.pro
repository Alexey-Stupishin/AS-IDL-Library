function asu_json_get_name, field, nocase = nocase, lower = lower

hcase = 'U'
if n_elements(nocase) ne 0 && nocase ne 0 then hcase = 'N'
if n_elements(lower) ne 0 && lower ne 0 then hcase = 'L'

case hcase of
    'U': f = strupcase(field)
    'L': f = strlowcase(field)
    else: f = field
endcase

return, f

end
