function pipeline_aia_movie_hmi, work_dir, obj_dir, vis_data_dir, cadence, files_in, hmi_vis_data_dir_wave, config, fps = fps

if n_elements(fps) eq 0 then fps = 5

windim = [800, 800]

prefix = pipeline_aia_get_vis_prefix(config)

if files_in.Count() eq 0 then return, 0

read_sdo_silent, files_in.toArray(), ind_seq, data3

idx = where(abs(data3) gt 6000, count)
if count gt 0 then data3[idx] = 0
foreach file_in, files_in, i do begin
    data = data3[*,*,i]
    index = ind_seq[i]
    
    asu_solar_par, index.date_obs, solar_r = solar_r
    outs = asu_fits_outpixels(data, index, solar_r, safe_arc = 0.1, count = count)
    if count gt 0 then begin
        data[outs] = 0
        data3[*,*,i] = data
    endif    
endforeach    
hmi_lim = minmax(data3)

set_plot,'Z'
device,set_resolution = windim, set_pixel_depth = 24, decomposed =0
!p.color = 0
!p.background = 'FFFFFF'x
!p.charsize = 1.5
loadct, 0

ctrl = 0.
n_files = n_elements(files_in)
foreach file_in, files_in, i do begin
    data = data3[*,*,i]
    index = ind_seq[i]
    
    jtitle = str_replace(str_replace(index.date_obs, 'T', ' '), 'Z', '')
        
    if double(i)/n_files*100d gt ctrl then begin
        message, 'Preparing movie , ' + strcompress(ctrl,/remove_all) + '%',/info
        ctrl += 5 
    endif
    outfile =  work_dir + path_sep() + hmi_vis_data_dir_wave + path_sep() + prefix + "_hmi" + string(i, FORMAT = '(I05)') + '.png'
    erase
    
    data[0, 0] = hmi_lim[0]
    data[0, 1] = hmi_lim[1]
    data = data>hmi_lim[0]<hmi_lim[1]
    sz = size(data)
    asu_fits_pixels2arcsec_x, dindgen(sz[1]), index, x
    asu_fits_pixels2arcsec_y, dindgen(sz[2]), index, y
    
    implot,comprange(data,2,/global),x,y,/iso,title = jtitle
       
    write_png, outfile, tvrd(true=1)
endforeach

filename = work_dir + path_sep() + vis_data_dir + path_sep() + prefix + '_m' + strcompress(long(cadence),/remove_all) + '.mp4'
pipeline_aia_make_movie_by_frames, prefix, work_dir + path_sep() + hmi_vis_data_dir_wave, filename, fps = fps, instrument = 'hmi'

return, files_in.Count()

end
