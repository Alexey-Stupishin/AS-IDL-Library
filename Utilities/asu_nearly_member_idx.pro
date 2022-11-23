function asu_nearly_member_idx, test, in, tol = tol

if n_elements(tol) eq 0 then tol = 1d-3

idxs = intarr(n_elements(test))
cnt = 0
for k = 0, n_elements(in)-1 do begin
    idx = where(abs(test - in[k])/max(abs(in)) le tol, /NULL)
    if idx ne !NULL then begin
        idxs[cnt] = k
        cnt++
    endif
endfor    

idxs = idxs[0:cnt-1]

return, idxs

end
