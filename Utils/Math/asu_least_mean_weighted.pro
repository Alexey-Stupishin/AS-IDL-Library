function asu_least_mean_weighted, M = M, F = F, w = w
compile_opt idl2

unit_test = 0

if n_elements(M) eq 0 then unit_test = 1

if unit_test then begin
    M = [[1,2,3],[4,5,6]]
    w = [10,1,1]
    f = [15,30,10]
endif

ww = diag_matrix(ww)
Mt = transpose(M)

MtW = Mt#ww
MtWM = MtW#M
MtWMi = la_invert(MtWM)
MtWf = MtW#f
res = MtWMi#MtWf 

if unit_test then ff = M#res

return, res

end
