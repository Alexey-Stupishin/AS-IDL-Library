function asu_fits_outpixels, data, index, solar_r, safe_arc = safe_arc, count = count

if n_elements(safe_arc) eq 0 then safe_arc = 0.1

sz = size(data)
outs = dblarr(sz[1], sz[2])

lons = dblarr(sz[1], sz[2])
lats = dblarr(sz[1], sz[2])

asu_fits_pixels2arcsec_x, dindgen(sz[1]), index, lons1
asu_fits_pixels2arcsec_y, dindgen(sz[2]), index, lats1

for k = 0, sz[2]-1 do lons[*, k] = lons1
for k = 0, sz[1]-1 do lats[k, *] = transpose(lats1)

dists = lons^2 + lats^2

return, where(dists gt (solar_r-safe_arc)^2, count)

end
