function hmi_utils_download_cutout, cadence, save_dir, config, no_tracking = no_tracking

if n_elements(no_tracking) eq 0 then no_tracking = 0

if n_elements(cadence) eq 0 then cadence = 720
case cadence of
    720: ds = 'hmi.M_720s'
     45: ds = 'hmi.M_45s'
   else: message, 'wrong dataset value: ' + strcompress(string(n_segment), /remove_all)  
endcase

file_mkdir, save_dir
downloaded = sdo_utils_download_cutout([], config, ds, save_dir, no_tracking = no_tracking)

return, downloaded

end
