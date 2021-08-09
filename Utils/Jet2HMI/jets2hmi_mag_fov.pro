function jets2hmi_mag_fov, data, index, center, params, xfov, yfov

xfov = lonarr(2)
yfov = lonarr(2)

idx = where(finite(data,/nan))
data[idx] = 0 
idx = where(abs(data) gt params.Bmaxlim)
data[idx] = 0

wcs0 = FITSHEAD2WCS(index[0]) 
wcs2map, data, wcs0, map
map2wcs, map, wcs0 
data = map.data
  
data = rotate(data, 2)

source = data

md = median(data, params.smed)
data = smooth(md, params.ssmth)

xpc = fix(index.crpix1+center.x/index.cdelt1)
ypc = fix(index.crpix2+center.y/index.cdelt2)

sz = size(data)
xs = fix(xpc + [-params.dsize, params.dsize]) ; pixels
if xs[0] lt 0 then xs[0] = 0
if xs[1] gt sz[1]-1 then xs[1] = sz[1]-1
ys = fix(ypc + [-params.dsize, params.dsize]) ; pixels
if ys[0] lt 0 then ys[0] = 0
if ys[1] gt sz[2] then ys[1] = sz[2]

idx = where(abs(data) le params.Bminlim)
data[idx] = 0

while xs[0] gt 0 do begin
    xt = xs[0] - params.exstep
    if xt lt 0 then xt = 0
    field = data[xt:xs[0], *]
    idx = where(field ne 0, count)
    if count eq 0 then break
    xs[0] = xt
endwhile    

while ys[0] gt 0 do begin
    yt = ys[0] - params.exstep
    if yt lt 0 then yt = 0
    field = data[*, yt:ys[0]]
    idx = where(field ne 0, count)
    if count eq 0 then break
    ys[0] = yt
endwhile    

while xs[1] lt sz[1]-1 do begin
    xt = xs[1] + params.exstep
    if xt gt sz[1]-1 then xt = sz[1]-1
    field = data[xs[1]:xt, *]
    idx = where(field ne 0, count)
    if count eq 0 then break
    xs[1] = xt
endwhile    

while ys[1] lt sz[2]-1 do begin
    yt = ys[1] + params.exstep
    if yt gt sz[2]-1 then yt = sz[2]-1
    field = data[*, ys[1]:yt]
    idx = where(field ne 0, count)
    if count eq 0 then break
    ys[1] = yt
endwhile    

select = data[xs[0]:xs[1], ys[0]:ys[1]]
idx = where(select ne 0, count)
if count eq 0 then begin
    return, 0 
endif

ids = array_indices(select, idx)
qhull, ids, qh
pos = qh[0,*]

xfov[0] = max([0,       min(ids[0, pos])+xs[0]-params.exlim])
xfov[1] = min([sz[1]+1, max(ids[0, pos])+xs[0]+params.exlim])
yfov[0] = max([0,       min(ids[1, pos])+ys[0]-params.exlim])
yfov[1] = min([sz[2]+1, max(ids[1, pos])+ys[0]+params.exlim])

return, 1 

end
