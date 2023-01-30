pro mfo_box_nlfff, box, out_dir, prefix, lib_location = lib_location $
                 , sst_post = sst_post, aia = aia, boxdata = boxdata, input_coords = input_coords $
                 , _extra = _extra

if not keyword_set(lib_location) then begin
    lib_location = asu_gxbox_get_library_location()
endif
  
message, 'Performing NLFFF extrapolation (can take some minutes, or tens of minutes) ...', /cont
t0 = systime(/seconds)
  
return_code = gx_box_make_nlfff_wwas_field(lib_location, box, version_info = version_info, _extra = _extra)
  
message, strcompress(string(systime(/seconds)-t0,format="('NLFFF extraplolation performed in ',g0,' seconds')")), /cont
  
print, version_info
filename = box.id
if strlen(prefix) gt 0 then filename = prefix + '_' + filename
save, file = filepath(filename+".sav", root_dir = out_dir), box
if n_elements(sst_post) ne 0 then begin
    filename += sst_post
    asu_box_create_mfodata, mfodata, box, box, aia, boxdata, filename, version_info = version_info, input_coords = input_coords
    NLFFF_filename = filepath(filename+".sav", root_dir = out_dir)
    save, file = NLFFF_filename, mfodata 
    message, 'Box structure (NLFFF) saved to ' + NLFFF_filename,/cont
endif

end
    