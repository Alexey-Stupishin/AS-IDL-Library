pro asu_create_f2009

seq = ['b', 'd', 'f', 'h', 'p', 'r', 's']
names = ['QS inter-network', 'QS network lane', 'Enhanced network', $
         'Plage (that is not facula)', 'Facula (very bright plage)', 'Penumbra', 'Umbra']
short = ['QSINW', 'QSNWL', 'EnhNW', 'Plage', 'Facula', 'Penumbra', 'Umbra']

length   = dblarr(7)
vH   = dblarr(7, 90)
vDH  = dblarr(7, 90)
vT   = dblarr(7, 90)
vNNe = dblarr(7, 90)
vNP  = dblarr(7, 90)
vNH  = dblarr(7, 90)
vNHI = dblarr(7, 90)
for k = 0,n_elements(seq)-1 do begin
    fn = 's:\SSW\packages\gx_simulator\userslib\chromo\fontenla_' + seq[k] +'_v3.sav'
    restore, fn
    n_el = where(temp gt 0)
    length[k] = n_elements(n_el)
    vH[k, *]   = H
    vDH[k, *]   = DH
    vT[k, *]   = TEMP
    vNNE[k, *]   = NNE
    vNP[k, *]   = NP
    vNH[k, *]   = NH
    vNHI[k, *]   = NHI
endfor    

Fontenla2009 = {Names:names, Models:seq, Short:short, Length:length, H:vH, DH:vDH, T:vT, Nel:vNNE, Np:vNP, NH:vNH, NHI:vNHI}

save, filename = 'c:\temp\Fontenla2009.sav', Fontenla2009 

end
