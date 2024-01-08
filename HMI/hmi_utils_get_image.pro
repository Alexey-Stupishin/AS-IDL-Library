pro hmi_utils_get_image, filename, win, windim, out_value = out_value
compile_opt idl2

read_sdo, filename, index, data
;read_sdo, filename, index0, data0
;hmi_prep, index0, data0, index, data
;data = data > (-6000d) < 6000d

if n_elements(out_value) ne 0 then begin
    sz = size(data)
    h_grid0 = (findgen(sz[1])-index.CRPIX1)*index.CDELT1 + index.CRVAL1
    h_grid = dblarr(sz[1], sz[2])
    for k = 0, sz[2]-1 do begin
        h_grid[*, k] = h_grid0
    endfor
    v_grid0 = (findgen(sz[2])-index.CRPIX2)*index.CDELT2 + index.CRVAL2
    v_grid = dblarr(sz[1], sz[2])
    for k = 0, sz[1]-1 do begin
        v_grid[k, *] = v_grid0
    endfor
    sq_grid = h_grid^2 + v_grid^2 
    Rctr = index.RSUN_OBS^2
    excl = where(sq_grid gt Rctr-1, count)
    if count gt 0 then data[excl] = out_value 
end

asu_fits2image, index, data, win, windim

end
