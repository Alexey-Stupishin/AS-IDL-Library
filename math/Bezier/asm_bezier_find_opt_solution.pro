function asm_bezier_find_opt_solution_resid, tstack, dists

s = 0d
for k = 0, n_elements(tstack)-1 do begin
    s += dists[tstack[k], k]^2
endfor

return, s

end

function asm_bezier_find_opt_solution_step, tstack, depth, nroots, troots, dists

if depth eq n_elements(nroots) - 1 then return, 1

nextdepth = depth+1

if nroots[nextdepth] gt 1 then begin
    stophere = 1
endif

smach = machar(/double)
resid_opt = smach.xmax
tstack_opt = !NULL
for k = 0, nroots[nextdepth]-1 do begin
    if troots[k, nextdepth] ge troots[tstack[depth], depth] then begin
        tstack[nextdepth] = k
        res = asm_bezier_find_opt_solution_step(tstack, nextdepth, nroots, troots, dists)
        if res then begin
            s = asm_bezier_find_opt_solution_resid(tstack, dists)
            if s lt resid_opt then begin
                resid_opt = s
                tstack_opt = tstack
            endif     
        endif    
    endif    
endfor

if tstack_opt ne !NULL then begin
    tstack = tstack_opt
    return, 1
endif

return, 0

end

function asm_bezier_find_opt_solution, nroots, troots, dists, tstack

s = 0

ndata = n_elements(nroots)
tstack = intarr(ndata)
depth = 0
res = asm_bezier_find_opt_solution_step(tstack, depth, nroots, troots, dists)
    
for k = 0, ndata-1 do begin
    s += dists[tstack[k], k]^2
endfor

return, s

end
