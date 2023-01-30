function asu_get_file_sequence_data, path, fromfile, tofile, ind = ind, err = err, cadence = cadence, jd_list = jd_list

flist = asu_get_file_sequence(path, fromfile, tofile, err = err)
ind = !NULL

if err gt 0 then return, !NULL

read_sdo_silent, flist.ToArray(), ind, data, /silent, /use_shared, /hide

aia_prep, ind, data, oind, odata

WIDGET_CONTROL, /HOURGLASS

med_data = 5
median_lim = 0.1

data_full = double(data > 1)
sz = size(data_full)
n_files = sz[3]

meds = dblarr(n_files)
for i = 0, n_files-1 do begin
   data_med = median(data_full[*, *, i], med_data)
   meds[i] = median(data_med)
;    data_full[*, *, i] = median(data_full[*, *, i], med_data)
;    meds[i] = median(data_full[*, *, i])
endfor
mmeds = median(meds)

dmax = 1d + median_lim
dmin = 1d/dmax
for i = 0, n_files-1 do begin
    if meds[i]/mmeds ge dmin && mmeds/meds[i] le dmax then begin
        data_full[*,*,i] = data_full[*,*,i]/meds[i]*mmeds
    endif
endfor

dlim = minmax(sigrange(data_full))
data_full = data_full > dlim[0] < dlim[1]

data_full = comprange(data_full, 2, /global)
cadence = (anytim(ind[sz[3]-1].date_obs) - anytim(ind[0].date_obs)) / (sz[3]-1)
jd_list = asu_get_sequence_juldates(ind)

;mlim = max(abs(dlim))
;data_full[0,0,*] = -mlim
;data_full[0,1,*] =  mlim
;data_full /= mlim

;data_full = asu_apply_contrast(data_full, contrast = 0.4)

return, data_full

end         
