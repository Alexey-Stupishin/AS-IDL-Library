pro asu_gxm_nm_resample, context, xarc

n = n_elements(xarc)
n_freq = n_elements(context.freqs)
right = dblarr(n, n_freq)
left = dblarr(n, n_freq)

for k = 0, n_freq-1 do begin
    right[*, k] = interpol(context.right[*, k], context.points, xarc)
    left[*, k] =  interpol(context.left[*, k],  context.points, xarc)
endfor

from = 0
idx = where(xarc lt context.range[0], count)
if count gt 0 then from = max(idx)+1
to = n-1
idx = where(xarc gt context.range[1], count)
if count gt 0 then to = min(idx)-1

context.resample.Add, {right:right, left:left, from:from, to:to, xarc:xarc}

end
 