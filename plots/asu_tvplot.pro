pro asu_tvplot, image, scale = scale, _extra =_extra
compile_opt idl2

sz = size(image)
xrange = [0, sz[1]-1]
yrange = [0, sz[2]-1]
plot, xrange, yrange, xst=5, yst=5, /nodata, _extra = _extra, xrange = xrange, yrange = yrange, xticks = 1, yticks = 1, xmargin = [0, 0], ymargin = [0, 0]

if n_elements(scale) gt 0 then tvscl, image else tv, image

end