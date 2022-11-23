function asu_least_mean_weighted, M = M, F = F, w = w
compile_opt idl2

if n_elements(M) eq 0 then unit_test = 1

ww = diag_matrix(w)
Mt = transpose(M)

MtW = Mt##ww
MtWM = MtW##M
MtWMi = la_invert(MtWM)
MtWf = MtW##transpose(F)
res = MtWMi##MtWf 

return, transpose(res)

end
