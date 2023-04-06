function asu_fits_trim, data, index, xrange, yrange, out_data, out_index
compile_opt idl2

asu_fits_arcsec2pixels_x, xrange, index, x, step = x_step
asu_fits_arcsec2pixels_y, yrange, index, y, step = y_step

x[0] = ceil(x[0])
x[1] = floor(x[1])
y[0] = ceil(y[0])
y[1] = floor(y[1])

sz = size(data)

if x[0] lt 0 || x[1] ge sz[1] || y[0] lt 0 || y[1] ge sz[2] then begin
    return, -1
endif  

out_data = data[x[0]:x[1], y[0]:y[1]]

out_index = index
out_index.CRPIX1 = (x[1]-x[0]+1)*0.5d
out_index.CRVAL1 = ((x[0]+x[1])*0.5d - index.CRPIX1)*index.CDELT1 + index.CRVAL1 
out_index.XCEN = out_index.CRVAL1 
out_index.CRPIX2 = (y[1]-y[0]+1)*0.5d
out_index.CRVAL2 = ((y[0]+y[1])*0.5d - index.CRPIX2)*index.CDELT2 + index.CRVAL2
out_index.YCEN = out_index.CRVAL2

return, 0

end
