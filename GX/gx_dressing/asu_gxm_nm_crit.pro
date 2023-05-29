function asu_gxm_nm_crit, x, f, context

sum = total(asu_gxm_nm_get_deviation(x) ge context.tolerance)
return, sum eq 0

end
