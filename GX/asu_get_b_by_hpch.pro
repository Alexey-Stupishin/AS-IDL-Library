function asu_get_B_by_HPCH, hpc, height, box, Br = Br
compile_opt idl2

LOS = asu_get_BLOS_by_HPC(hpc, box, /Mm, coords = coords, rotator = rotator)
if LOS eq !NULL then return, !NULL

if height lt min(LOS.heights) || height gt max(LOS.heights) then return, !NULL

B = dblarr(3)
B[0] = interpol(LOS.B[0,*], LOS.heights, height)
B[1] = interpol(LOS.B[1,*], LOS.heights, height)
B[2] = interpol(LOS.B[2,*], LOS.heights, height)

Br = dblarr(3)
Br[0] = interpol(LOS.Br[0,*], LOS.heights, height)
Br[1] = interpol(LOS.Br[1,*], LOS.heights, height)
Br[2] = interpol(LOS.Br[2,*], LOS.heights, height)

N2 = interpol(indgen(n_elements(LOS.heights)), LOS.heights, height)
N0 = interpol(coords[0,*], indgen(n_elements(LOS.heights)), N2)
N1 = interpol(coords[1,*], indgen(n_elements(LOS.heights)), N2)

return, B

end
