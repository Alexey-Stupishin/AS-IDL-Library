pro asu_json_save_list, var, filename
    
res = asu_json_make_list(var)

openw, UW, filename, /get_lun

n = res.Count()
for i = 0, n-1 do printf, UW, res[i]
close, UW
free_lun, UW
    
end
