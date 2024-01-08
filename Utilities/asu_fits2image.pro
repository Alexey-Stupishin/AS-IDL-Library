pro asu_fits2image, index, data, xrange = xrange, yrange = yrange
compile_opt idl2

xstep = index.CDELT1
ystep = index.CDELT2
xshift = -index.CRPIX1*index.CDELT1 + index.CRVAL1 
yshift = -index.CRPIX2*index.CDELT2 + index.CRVAL2 

sz = size(data)
x = indgen(sz[1])*xstep+xshift
y = indgen(sz[2])*ystep+yshift

if n_elements(xrange) eq 2 then begin
    xcut = intarr(2)
    if x[0] ge xrange[0] then begin
        xcut[0] = 0
    endif else begin
        m = min(abs(x - xrange[0]), idx)
        xcut[0] = idx
    endelse
    if x[-1] le xrange[1] then begin
        xcut[1] = sz[1] - 1
    endif else begin
        m = min(abs(x - xrange[1]), idx)
        xcut[1] = idx
    endelse
    data = data[xcut[0]:xcut[1], *]
    x = x[xcut[0]:xcut[1]]
end 

if n_elements(yrange) eq 2 then begin
    ycut = intarr(2)
    if y[0] ge yrange[0] then begin
        ycut[0] = 0
    endif else begin
        m = min(abs(y - yrange[0]), idx)
        ycut[0] = idx
    endelse
    if y[-1] le yrange[1] then begin
        ycut[1] = sz[2] - 1
    endif else begin
        m = min(abs(y - yrange[1]), idx)
        ycut[1] = idx
    endelse
    data = data[*, ycut[0]:ycut[1]]
    y = y[ycut[0]:ycut[1]]
end

title = str_replace(str_replace(str_replace(index.t_obs, '_TAI', ''), 'T', ' '), 'Z', '')

device, decomposed = 0
tvplot, comprange(data,2,/global), x, y, /iso, TITLE = title

end
