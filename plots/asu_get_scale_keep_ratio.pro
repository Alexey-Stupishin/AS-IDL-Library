function asu_get_scale_keep_ratio, winsize, xy_lb_dat, xy_rt_dat, newsize

imsize = [xy_rt_dat[0]-xy_lb_dat[0]+1, xy_rt_dat[1]-xy_lb_dat[1]+1]

cr  = dblarr(2)
cr[0] = double(imsize[0]-1)/double(winsize[0]-1)
cr[1] = double(imsize[1]-1)/double(winsize[1]-1)
coef = max(cr, imax)

newsize = lonarr(2)
newsize[imax] = winsize[imax]
newsize[1-imax] = long((imsize[1-imax]-1)/coef + 1)

return, coef

end
