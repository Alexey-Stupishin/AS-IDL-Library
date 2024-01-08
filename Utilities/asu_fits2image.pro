pro asu_fits2image, index, data, win, windim
compile_opt idl2

xstep = index.CDELT1
ystep = index.CDELT2
xshift = -index.CRPIX1*index.CDELT1 + index.CRVAL1 
yshift = -index.CRPIX2*index.CDELT2 + index.CRVAL2 

sz = size(data)
x = indgen(sz[1])
y = indgen(sz[2])

x = indgen(sz[1])*xstep+xshift
y = indgen(sz[2])*ystep+yshift

;win = window(dimensions = windim)

title = str_replace(index.t_obs, '_TAI', '')
title = str_replace(str_replace(title, 'T', ' '), 'Z', '')

dimage = image(data, x, y, /CURRENT, TITLE = title, FONT_SIZE = 16)
xax = axis('X', LOCATION=[x[0],y[0]], target = dimage)
xax.tickdir = 1
yax = axis('Y', LOCATION=[x[0],y[0]], target = dimage)
yax.tickdir = 1

end
