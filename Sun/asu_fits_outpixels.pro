function asu_fits_outpixels, data, index, solar_r, safe_arc = safe_arc, count = count

if n_elements(safe_arc) eq 0 then safe_arc = 0.1

sz = size(data)
outs = dblarr(sz[1], sz[2])

lons = dblarr(sz[1], sz[2])
lats = dblarr(sz[1], sz[2])

lons1 = (indgen(sz[1]) - index.CRPIX1)*index.CDELT1 + index.CRVAL1
lats1 = (indgen(sz[2]) - index.CRPIX2)*index.CDELT2 + index.CRVAL2

for k = 0, sz[2]-1 do lons[*, k] = lons1
for k = 0, sz[1]-1 do lats[k, *] = lats1

dists = lons^2 + lats^2

return, where(dists gt (solar_r-safe_arc)^2, count)

end
