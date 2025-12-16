function aia_utils_download_cutout, wave, save_dir, config, transform = transform
compile_opt idl2

swave = strcompress(wave, /remove_all)

ds = 'aia.lev1_euv_12s'
if (swave eq '1600') || (swave eq '1700') then begin
    ds = 'aia.lev1_uv_24s'
endif

file_mkdir, save_dir
downloaded = sdo_utils_download_cutout(swave, config, ds, save_dir, segment = 'image', transform = transform)

return, downloaded
  
end

