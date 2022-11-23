function asu_get_sequence_juldates, ind

n = n_elements(ind)
jd0 = asu_anytim2julday(ind[0].date_obs)
jde = asu_anytim2julday(ind[n-1].date_obs)
return, asu_linspace(jd0, jde, n)

end
