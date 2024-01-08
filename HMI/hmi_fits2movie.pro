pro hmi_fits2movie, fitsdir, windim = windim, visdir = visdir, fps = fps, img_name = img_name, video_name = video_name, out_value = out_value, xrange = xrange, yrange = yrange 
compile_opt idl2

if n_elements(windim) eq 0 then windim = [1000, 1000]
if n_elements(visdir) eq 0 then visdir = fitsdir + path_sep() + 'visual'
if n_elements(fps) eq 0 then fps = 5
if n_elements(img_name) eq 0 then img_name = 'img'
if n_elements(video_name) eq 0 then video_name = 'video'

file_mkdir, visdir
files_in_all = file_search(filepath('*.fits', root_dir = fitsdir))

set_plot,'Z'
device, set_resolution = windim, set_pixel_depth = 24, decomposed = 0
!p.color = 0
!p.background = 255
!p.charsize=1.5

foreach fits, files_in_all, i do begin
    hmi_utils_get_image, fits, out_value = out_value, xrange = xrange, yrange = yrange
    outfile = visdir + path_sep() + img_name + string(i, FORMAT = '(I08)') + '.png'
    write_png, outfile, tvrd(true=1)
    erase
endforeach

to_filename = visdir + path_sep() + video_name + '.mp4'
hmi_mask = visdir + path_sep() + img_name + '%08d.png'
asu_make_movie_by_frames, hmi_mask, to_filename, fps = fps

end
