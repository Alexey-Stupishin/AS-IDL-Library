function asu_gxm_nm_residual_pol, obs, calc, from, to

sz = size(obs)

r = 0
for k = 0, sz[2]-1 do begin
    r += sqrt(total((obs[from:to,k]-calc[from:to,k]))^2)/total(obs[from:to,k])
endfor

return, r

end

function asu_gxm_nm_residual, context, modscansR, modscansL

resample = context.resample[0]

rR = asu_gxm_nm_residual_pol(resample.right, modscansR, resample.from, resample.to) 
rL = asu_gxm_nm_residual_pol(resample.left,  modscansL, resample.from, resample.to)

return, (rR+rL)*0.5d/n_elements(context.freqs)

end
