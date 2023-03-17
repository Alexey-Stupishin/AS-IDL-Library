pro asu_load_aia_multiwave, tstart, tstop, x, y, outdir, waves = waves

file_mkdir, outdir

if n_elements(waves) eq 0 then waves = '94,131,171,193,211,304,335'

xp = x/0.6
yp = y/0.6
xc = fix((x[1]+x[0])/2d)
yc = fix((y[1]+y[0])/2d)
wpix = fix(x[1]-x[0])
hpix = fix(y[1]-y[0])
config = {tstart:tstart, tstop:tstop, tref:tstart, xc:xc, yc:yc, wpix:wpix, hpix:hpix}
lims = aia_utils_download_cutout(waves, outdir, config)

pipeline_aia_get_input_files, config, outdir, files_in
files_in_array = files_in.ToArray()
read_sdo_silent, files_in_array, ind, data, /silent, /use_shared, /hide

n = n_elements(ind)
jd = dblarr(n)
for k = 0, n-1 do begin
    ;print, ind[k].wavelnth, ' ', ind[k].t_obs
    jd[k] = asu_anytim2julday(ind[k].t_obs)    
endfor

idx = sort(jd)

xstep = ind[0].CDELT1
ystep = ind[0].CDELT2
xshift = x[0] 
yshift = y[0] 
sz = size(data)
xp = findgen(sz[1])*xstep+xshift
yp = findgen(sz[2])*ystep+yshift

if sz[1] gt sz[2] then begin
    ;xr = min([max([500, sz[1]+100]), 1400])
    xr = 1500
    yr = fix(double(sz[2])/sz[1]*xr)+150
endif else begin
    ;yr = min([max([200, sz[2]+250]), 1000])
    yr = 1000
    xr = max([fix(double(sz[1])/sz[2]*yr), 500])
endelse    

set_plot, 'Z'
device, set_resolution = [xr, yr], set_pixel_depth = 24, decomposed =0
!p.color = 0
!p.background = 255
!p.charsize=1.5
aia_lct_silent,wave = 171,/load

for k = 0, n-1 do begin
    indk = ind[idx[k]] 
    old_file = files_in_array[idx[k]]
    prefix = 'aia_' + string(k, format = '(I05)')
    new_file = outdir + path_sep() + prefix + '_' + asu_compstr(indk.wavelnth) + '_' + file_basename(old_file)
    file_move, old_file, new_file
    implot,comprange(data[*,*,idx[k]],2,/global),xp,yp,/iso,title = asu_compstr(indk.wavelnth) + ', ' + indk.t_obs 
    write_png, outdir + path_sep() + prefix + '.png', tvrd(true=1)
endfor

end
