function asu_read_csv_table, filename
compile_opt idl2

isOK = query_csv(filename, info)

data = dblarr(info.lines, info.nfields)
arr = read_csv(filename)
tags = tag_names(arr)

n_digits = strlen(tags[0]) - 5
format = '(%"FIELD%0' + asu_compstr(n_digits) + 'd")'

for k = 1, info.nfields do begin
    fieldname = strcompress(string(k, format = format))
    idx = where(tags eq fieldname, count)
    t = arr.(idx)
    data[*, k-1] = t
endfor

return, data

end
