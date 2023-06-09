function asu_read_csv_table, filename

isOK = query_csv(filename, info)

data = dblarr(info.lines, info.nfields)
arr = read_csv(filename)
tags = tag_names(arr)

n_col_form = 'FIELD%0' + asu_compstr(ceil(alog10(info.nfields))) + 'd'

for k = 1, info.nfields do begin
    fieldname = strcompress(string(k, format = '(%"' + n_col_form + '")'))
    idx = where(tags eq fieldname, count)
    t = arr.(idx)
    data[*, k-1] = t
endfor

return, data

end
