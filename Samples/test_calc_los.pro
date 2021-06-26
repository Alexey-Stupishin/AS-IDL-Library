pro test_calc_los

H  = [   0,    1,  1.2,  1.5,    2,    3,    4,    5,  10,  15]*1e8
B  = [2500, 2000, 1950, 1900, 1800, 1600, 1400, 1200, 700, 450]
Th = [  40,   35,   30,   25,   20,   25,   30,   35,  40,  45]
T  = [0.01, 0.01,    1,    2,    2,    2,    2,    2,   2,   2]*1e6
D  = 3e15/T
freqs = asu_linspace(4, 18, 100)*1e9

taus = 10^asu_linspace(-2, 1, 208)

rc = reo_calculate_los(H, B, Th, T, D, freqs $
                      , harmonics = [2, 3, 4], taus = taus $
                      , totFlux = totFlux, totTau = totTau $
                      , depth = depth, profHeight = profHeight, profFlux = profFlux, profHarm = profHarm $
                      ;, dll_location = dll_location $
                      , freefree = 0 $
                      , cycloCalc_LaplasMethod_Use = 0 $
                      )

end
