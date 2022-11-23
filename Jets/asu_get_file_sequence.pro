function asu_get_file_sequence, path, fromfile, tofile, err = err

err = 0
files_in = list()

from = path + fromfile
infofrom = FILE_INFO(from)
to = path + tofile
infoto = FILE_INFO(to)
if ~infofrom.exists || ~infoto.exists then begin   
    err = 1
    return, files_in
endif    

ts = aia_date_from_filename(from, /q_anytim)
te = aia_date_from_filename(to, /q_anytim)
tims = minmax([ts, te]) 

files_in_all = file_search(filepath('*.fits', root_dir = path))
foreach file_in, files_in_all, i do begin
    tf = aia_date_from_filename(file_in, /q_anytim)
    if tf ge tims[0] && tf le tims[1] then files_in.Add, file_in
endforeach

if files_in.Count() le 2 then begin
    err = 2
    return, files_in
endif    

return, files_in

end
