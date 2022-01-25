function asu_get_file_sequence_data, path, fromfile, tofile, ind = ind, err = err

flist = asu_get_file_sequence(path, fromfile, tofile, err = err)
ind = !NULL

if err gt 0 then return, !NULL

read_sdo_silent, flist.ToArray(), ind, data, /silent, /use_shared, /hide

return, data

end         
