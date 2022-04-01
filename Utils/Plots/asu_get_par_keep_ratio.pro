pro asu_get_par_keep_ratio, winsize, datsize, newsize, coef, win_range, dat_range, x = x, y = y

coef = asu_get_scale_keep_ratio(winsize, [0, 0], datsize-1, newsize)
delta = round((winsize-newsize)/2d)
dat_range = lonarr(2, 2)
win_range = lonarr(2, 2)
for dir = 0, 1 do begin
    dat_range[dir, 0] = 0
    dat_range[dir, 1] = datsize[dir]-1
    win_range[dir, 0] = delta[dir]
    win_range[dir, 1] = newsize[dir]-1 + delta[dir]
endfor

;x = (indgen(datsize[0]) - delta[0])/coef
;y = (indgen(datsize[1]) - delta[1])/coef
x = indgen(datsize[0])/coef + delta[0]
y = indgen(datsize[1])/coef + delta[1]

end
