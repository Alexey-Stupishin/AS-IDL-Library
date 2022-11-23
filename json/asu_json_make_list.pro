function asu_json_make_list, var, shift = shift 

baseshift = '    '
if n_elements(shift) eq 0 then shift = ''

if isa(var, 'LIST') then begin
    n = var.Count()
    str = strarr(n)
    for i = 0, n-1 do str[i] = asu_json_make_list(var[i])
    return, '[' + strjoin(str,',') + ']'
endif  

type=size(var,/type)
if type eq 10 or type eq 11 then message,'pointers and objects are not supported'

if n_elements(var) gt 1  then begin ;array
    n = n_elements(var)
    str = strarr(n)
    for i = 0, n-1 do str[i] = asu_json_make_list(var[i])
    return, '[' + strjoin(str,',') + ']'
endif

if type eq 7 then begin ;string
    return, '"' + var + '"'
endif
  
if type eq 8 then begin ;structure
    strlist = list()
    strlist.Add, shift + '{'
    shift0 = shift
    shift += baseshift
    
    tags = strlowcase(tag_names(var))
    n = n_elements(tags)
    str = strarr(n)
    for i = 0, n-1 do begin
        prefix = shift + '"' + tags[i] + '":'
        suffix = (i eq n-1 ? '' : ',')
        
        res = asu_json_make_list(var.(i), shift = shift + baseshift)
        if ~isa(res, 'LIST') then begin
            strlist.Add, prefix + strcompress(string(res), /remove_all) + suffix
        endif else begin
            nel = res.Count()
            strlist.Add, prefix
            for j = 0, nel - 1 do begin
                strlist.Add, shift + res[j] + (j eq nel-1 ? suffix : '')
            endfor
        endelse    
    endfor
    
    shift = shift0
    strlist.Add, shift + '}'
    return, strlist
endif

return, var

end