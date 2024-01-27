function asu_find_peaks, fit0, conv_win = conv_win, nearby_x_tol = nearby_x_tol, features = features, x_pos = x_pos
compile_opt idl2

extremums = !NULL
features = !NULL

default, nearby_x_tol, 2
default, x_pos, indgen(n_elements(fit0))

default, conv_win, [1,2,3,2,1]/9d

fit = n_elements(conv_win) gt 1 ? convol(fit0*1d, conv_win, /EDGE_TRUNCATE) : fit0
n_fit = n_elements(fit)

der = fit[1:-1] - fit[0:-2]

; find indices to check
leaps = der[0:-2] * der[1:-1]
idxs = where(leaps le 0, count)
if count eq 0 then return, !NULL

idxs = [0, idxs+1, n_fit-1]
n_idx = n_elements(idxs)

; remove first(s) and last(s), if ones
single_idx = where(leaps ge 0, leaps_count)
if leaps_count eq 1 then begin ; special case of single extremum
    from = single_idx[0]
    to = single_idx[0]
endif else begin
    from = 0
    while from lt n_idx-1 && idxs[from] eq from do begin
        from++
    endwhile
    to = n_idx - 1
    while to gt 0 && idxs[to] eq n_fit-1-(n_idx-1-to) do begin
        to--
    endwhile
endelse
if to lt from then return, !NULL
idxs = idxs[from:to]
n_idx = n_elements(idxs)

; find distances
distance = n_idx eq 1 ? !values.d_infinity : x_pos[idxs[1:-1]] - x_pos[idxs[0:-2]]
extremums = !NULL
features = !NULL

; loop by freq-closed clusters
from_idx = 0
while from_idx le n_idx-1 do begin
    ; define cluster
    to_idx = from_idx
    while to_idx lt n_idx-1 && distance[to_idx] le nearby_x_tol do to_idx++
    clust = idxs[from_idx:to_idx]
    
    ; what happens on left and right side of the cluster
    left_raise = fit[clust[0]] - fit[clust[0]-1] gt 0 ? 1 : -1
    right_fall = fit[clust[-1]+1] - fit[clust[-1]] lt 0 ? 1 : -1
    direction = left_raise + right_fall
    case 1 of
        direction gt 0: feat =  1 ; maximum-like
        direction lt 0: feat = -1 ; minimum-like
        else:           feat =  0 ; inflection-point-like, will be ignored
    endcase
    if feat ne 0 then begin ; add to the list, use one point from the cluster
        min_clust = min(fit[clust[0]:clust[-1]], i_min)
        max_clust = max(fit[clust[0]:clust[-1]], i_max)
        extremums = [extremums, (feat gt 0 ? i_max : i_min) + clust[0]]
        features = [features, (n_elements(clust) eq 1 ? 2 : 1) * feat]
    endif
    from_idx = to_idx + 1
endwhile

return, extremums

end

pro asu_find_peaks_unit_test

    fit = [1,2,1,2,1,2,1] ; firsts, lasts
    s = asu_find_peaks(fit, /conv_win, features = f) & print, s & print, f ; -> !NULL, !NULL
    s = asu_find_peaks(fit, features = f) & print, s & print, f ; -> !NULL, !NULL

    fit = [1,2,1,2,2,1,2] ; firsts, lasts
    s = asu_find_peaks(fit, /conv_win, features = f) & print, s & print, f ; -> !NULL, !NULL
    s = asu_find_peaks(fit, features = f) & print, s & print, f ; -> !NULL, !NULL

    fit = [1,2,1,3,2,1,2] ; firsts, lasts, single extremum
    s = asu_find_peaks(fit, /conv_win, features = f) & print, s & print, f ; -> [3], [2]
    s = asu_find_peaks(fit, features = f) & print, s & print, f ; -> [3], [2]

    fit = [1,2,1,2,3,3,3,2,1,2] ; firsts, lasts, wide single extremum
    s = asu_find_peaks(fit, /conv_win, features = f) & print, s & print, f ; -> [4], [2]
    s = asu_find_peaks(fit, features = f) & print, s & print, f ; -> [4], [2]

    fit = [1,2,1,2,3,4,5,6,5,6,7,9,9,4,3,5,4,5,3] ; firsts, lasts, wide single extremum, iflation before
    s = asu_find_peaks(fit, /conv_win, features = f) & print, s & print, f ; -> [9], [2]
    s = asu_find_peaks(fit, features = f) & print, s & print, f ; -> [9], [2]

end
