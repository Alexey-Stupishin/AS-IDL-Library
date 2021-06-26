function asu_calc_ff, freq, T, N, depth = depth, area = area, RSun = RSun

CLn = (T lt 8.92e5 ? 17.72d + 1.5d*alog(T) : 24.57d + alog(T)) - alog(freq)
k0 = 9.775d-3 * N^2 * T^(-1.5d) * CLn * 1.14d ; 1.14 - protons + Helium
n2 = 1d - 8.06d7 * N * freq^(-2)
k = 0
j = 0
if n2 gt 0 then begin
    n2s = sqrt(n2)
    k = k0 * freq^(-2) / n2s
    j = 1.536d-37 * T * k0 * n2s
endif

if n_elements(depth) eq 1 && n_elements(area) eq 1 then begin
    ret = asu_calc_flux(j, k, depth, area, RSun = RSun)
endif else begin    
    ret = {k:k, j:j}
endelse    

return, ret

end
