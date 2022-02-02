function ass_slit_data2grid, data, grids

szg = size(grids.x_grid)
szd = size(data)
if szd[0] eq 2 then szd[3] = 1
stratned = dblarr(szg[1], szg[2], szd[3])

nans = where(grids.x_grid lt 0 or grids.x_grid ge szd[1] or grids.y_grid lt 0 or grids.y_grid ge szd[2], count)

for k = 0, szd[3]-1 do begin
    strt = bilinear(data[*, *, k], grids.x_grid, grids.y_grid)
    if count gt 0 then begin
        strt(nans) = !values.f_nan
    endif
    stratned[*, *, k] = strt
endfor

return, stratned

end
