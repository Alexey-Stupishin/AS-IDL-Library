function asu_find_symm_center, v

n = n_elements(v)
nres = 2*n-1

res = dblarr(nres)
w = dblarr(3*n-2)
w[n-1:2*n-2] = reverse(v)

for k = 0, nres-1 do begin
    res[k] = total(v*w[2*n-2-k:3*n-3-k])
end 

;for k = -n+1, n-1 do begin
;    res[k+n-1] = 0
;    for t = max([0, k]), min([n-1, n+k-1]) do begin
;        res[k+n-1] += v[t] * v[n-1+k-t]
;    endfor
;endfor

m = max(res, im)

return, fix(im/2)

end
