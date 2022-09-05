function asu_atm_barometric, H, T, NT, Tmin = Tmin

if n_elements(Tmin) eq 0 then Tmin = 3d5

NTx = dblarr(n_elements(H)) + NT
idx = where(T gt Tmin, /NULL)
if idx ne !NULL then begin
    i0 = idx[0]
    H0 = H[i0]
    NTx[i0:-1] = NT*exp(-(H[i0:-1]-H0)/T[i0:-1] /4.5e3)
end

D = NTx/T

return, D

end