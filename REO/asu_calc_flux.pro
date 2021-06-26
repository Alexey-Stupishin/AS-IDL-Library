function asu_calc_flux, emissivity, absorbtion, depth, area, RSun = RSun

tau = 0
Jy = 0
if emissivity gt 0 then begin
    if n_elements(RSun) eq 0 then RSun = 960d
    coef = (RSun/6.96d10)^2 * 2.35d-11 * 1d23
    tau = absorbtion*depth
    S = emissivity/absorbtion*(1-exp(-tau))
    Jy = S * area * coef
endif

return, {k:absorbtion, j:emissivity, Jy:Jy, tau:tau}

end
