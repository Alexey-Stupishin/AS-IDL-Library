function asu_least_mean_weighted, M, F, ww

        M = [[1,2,3],[4,5,6]]
        ww = [10,1,1]
        f = [15,30,10]

w = diag_matrix(ww)
Mt = transpose(M)

MtW = Mt#w
MtWM = MtW#M
MtWMi = la_invert(MtWM)
MtWf = MtW#f

res = MtWMi#MtWf 

        ff = M#res

return, res

end
