function asu_apply_contrast, rd, contrast = contrast

if n_elements(contrast) eq 0 then contrast = 1.5

sz = size(rd)
signs = dblarr(sz[1], sz[2], sz[3])
signs[*, *, *] = 1d
idx = where(rd lt 0, count)
if count gt 0 then begin
    signs(idx) = -1d
endif

return, abs(rd)^contrast * signs

end
