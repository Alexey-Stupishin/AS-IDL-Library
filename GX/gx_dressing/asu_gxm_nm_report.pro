pro asu_gxm_nm_report, sol, f = f, context = context, state = state

context.history.Add, {solution:sol, residual:f, deviation:asu_gxm_nm_get_deviation(sol)}

n = n_elements(context.history)
res = dblarr(n)
for k = 0, n-1 do res[k] = context.history[k].residual  

plot, res

print, ' '
print, '*********************************************'
print, asu_compstr(context.history[-1].residual)
print, '*********************************************'
print, ' '

end
