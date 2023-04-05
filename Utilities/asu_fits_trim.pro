function asu_fits_trim, data, index, xrange, yrange, out_data, out_index
compile_opt idl2

asu_fits_arcsec2pixels_x, xrange, index, x, x_step = x_step
asu_fits_arcsec2pixels_y, yrange, index, y, y_step = y_step

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
out_index.CRVAL1 = 0
out_index.CRPIX1 = (x[0]-index.CRPIX1) + index.CRVAL1/index.CDELT1
out_index.CRVAL2 = 0
out_index.CRPIX2 = (y[0]-index.CRPIX2) + index.CRVAL2/index.CDELT2

return, 0

end
