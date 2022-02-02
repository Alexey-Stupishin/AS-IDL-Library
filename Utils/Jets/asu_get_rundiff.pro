function asu_get_rundiff, data

med_data = 5
median_lim = 0.1

data_full = double(data > 1)
sz = size(data_full)
n_files = sz[3]

meds = dblarr(n_files)
for i = 0, n_files-1 do begin
    data_med = median(data_full[*, *, i], med_data)
    meds[i] = median(data_med)
endfor
mmeds = median(meds)

dmax = 1d + median_lim
dmin = 1d/dmax
for i = 0, n_files-1 do begin
    if meds[i]/mmeds ge dmin && mmeds/meds[i] le dmax then begin
        data_full[*,*,i] = data_full[*,*,i]/meds[i]*mmeds
    endif
endfor

run_diff = data_full[*,*,1:*] - data_full[*,*,0:-2]

rdlim = minmax(sigrange(run_diff))
rd = run_diff > rdlim[0] < rdlim[1]
flim = max(abs(rdlim))
rd = rd / flim
rd[0, 0, *] =  1d
rd[0, 1, *] = -1d

return, rd

end
