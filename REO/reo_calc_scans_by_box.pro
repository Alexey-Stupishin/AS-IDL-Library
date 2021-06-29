function reo_calc_scans_by_box, box, visstep, H, Temp, Dens, freqs, harmonics, freefree, posangle = posangle, model = model

ptr = reo_prepare_calc_map( $
      box, visstep $ ; GX-модель и шаг радиокарты 
    , M, base $ результат: размер и смещение радиокарты
    , posangle = posangle $  
    , freefree = freefree $
    , model = model $
    , version_info = version_info $ ; когда, где и в какой версии библиотеки мы работаем - для контроля
;    , cycloMap_nThreadsInitial = 1 $
;    , Debug_AtPoint_ZoneTrace_i = 0 $
;    , Debug_AtPoint_ZoneTrace_j = 249 $
;    , Debug_AtPoint_ZoneTrace_GyroLayerProfile = 1 $
    , dll_location = 's:\Projects\Physics104_291\ProgramD64\agsGeneralRadioEmission.dll' $
    )

print, version_info

n = n_elements(freqs)
spMaxR = dblarr(n)
spTotR = dblarr(n)
spMaxL = dblarr(n)
spTotL = dblarr(n)
for i = 0, n-1 do begin
    freq = freqs[i]
    rc = reo_calculate_map( $
          ptr, H, Temp, Dens, freq $
        , harmonics = harmonics $
        , FluxR = FluxR $
        , FluxL = FluxL $
        )

    rcr = reo_convolve_map( $
          ptr, FluxR-min(FluxR), freq, scanR $
        )
    rcl = reo_convolve_map( $
          ptr, FluxL-min(FluxL), freq, scanL $
        )
       
    spMaxR[i] = max(scanR)        
    spTotR[i] = total(scanR)*visstep        
    spMaxL[i] = max(scanL)        
    spTotL[i] = total(scanL)*visstep        
endfor

rc = reo_uninit(ptr)

return, {freqs:freqs, maxR:spMaxR, maxL:spMaxL, fluxR:spTotR, fluxL:spTotL}
    
end