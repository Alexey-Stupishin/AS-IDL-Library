function hmi_utils_load_segment_sequence, t1, t2, dataset, segment, xrange, yrange, cache_dir = cache_dir, time_window = time_window

ssw_jsoc_time2data, anytim(t1), anytim(t2), index_all, urls, /urls_only, ds = dataset, segment = segment, count = count

if count eq 0 then return, !NULL

if not keyword_set(cache_dir) then cache_dir = GETENV('IDL_TMPDIR') 
if not keyword_set(time_window) then time_window = 720d

t0 = anytim(index_all[0].date_obs)
rc = gx_box_jsoc_get_content(t0, dataset, segment, index0, data0, cache_dir = cache_dir, time_window = time_window, loc_file = loc_file)

shifts = [0d, 0d]
dynamics = replicate({file:'', t:0, corr_first:shifts, corr_prev:shifts, rot_first:shifts, rot_prev:shifts}, count)

index_prev = index0
data_prev = data0
dynamics[0].t = t0
dynamics[0].file = loc_file
for i = 1, count-1 do begin
    ti = anytim(index_all[i].date_obs)
    dynamics[i].t = ti
    dynamics[i].file = loc_file
    rc = gx_box_jsoc_get_content(ti, dataset, segment, index, data, cache_dir = cache_dir, time_window = time_window, loc_file = loc_file)
    
    hmi_utils_get_maps_shifts, index0, data0, index, data, xrange, yrange, shifts_corr, shifts_rot    
    dynamics[i].corr_first = double(shifts_corr)
    dynamics[i].rot_first = double(shifts_rot)
    
    hmi_utils_get_maps_shifts, index_prev, data_prev, index, data, xrange, yrange, shifts_corr, shifts_rot    
    dynamics[i].corr_prev = double(shifts_corr)
    dynamics[i].rot_prev = double(shifts_rot)
    
    index_prev = index
    data_prev = data
endfor

nf = n_elements(dynamics)
nx = xrange[1]-xrange[0]+1
ny = yrange[1]-yrange[0]+1
all_c0 = dblarr(nx, ny, nf)
all_cp = dblarr(nx, ny, nf)
all_r0 = dblarr(nx, ny, nf)
all_rp = dblarr(nx, ny, nf)
xind = indgen(nx) + xrange[0]
yind = indgen(ny) + yrange[0]

ccum = [0d, 0d]
rcum = [0d, 0d]
for i = 0, n_elements(dynamics)-1 do begin
    read_sdo_silent, dynamics[i].file, index, data
    corr0 = dynamics[i].corr_first
    rot0 = dynamics[i].rot_first
    ccum += dynamics[i].corr_prev
    rcum += dynamics[i].rot_prev
    all_c0[*, *, i] = data[xind+floor(corr0[0]), yind+floor(corr0[1])]
    all_r0[*, *, i] = data[xind+floor(rot0[0]), yind+floor(rot0[1])]
    all_cp[*, *, i] = data[xind+floor(ccum[0]), yind+floor(ccum[1])]
    all_rp[*, *, i] = data[xind+floor(rcum[0]), yind+floor(rcum[1])]
end

save, filename = 's:\temp\shifts.sav', all_c0, all_r0, all_cp, all_rp

return, dynamics

end
