function test_calc_model, H, Temp, Dens, Bph, freqs, harmonics, freefree

dirpath = file_dirname((ROUTINE_INFO('test_calc_model', /source, /functions)).path, /mark)
filename = dirpath + 'dipole_18Mm_2500G_1arc_largeFOV.sav' 
restore, filename ; GX-box

visstep = 1
posangle = 0

;B = sqrt(BX^2 + BY^2 + BZ^2)
;factor = Bph/max(B)
;BX *= factor
;BY *= factor
;BZ *= factor

box = {BX:BX, BY:BY, BZ:BZ, modstep:modstep}

ptr = reo_prepare_calc_map( $
      box, visstep $ ; GX-модель и шаг радиокарты 
    , M, base $ результат: размер и смещение радиокарты
    , posangle = posangle $  
    , freefree = freefree $
    , /model $
    , version_info = version_info $ ; когда, где и в какой версии библиотеки мы работаем - для контроля
    , cycloMap_nThreadsInitial = 1 $
    , Debug_AtPoint_ZoneTrace_i = 0 $
    , Debug_AtPoint_ZoneTrace_j = 249 $
    , Debug_AtPoint_ZoneTrace_GyroLayerProfile = 1 $
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
          ptr, FluxR-FluxR[0, 0], freq, scanR $
        )
    rcl = reo_convolve_map( $
          ptr, FluxL-FluxL[0, 0], freq, scanL $
        )
       
    spMaxR[i] = max(scanR)        
    spTotR[i] = total(scanR)*visstep        
    spMaxL[i] = max(scanL)        
    spTotL[i] = total(scanL)*visstep        
endfor

rc = reo_uninit(ptr)

return, {freqs:freqs, maxR:spMaxR, maxL:spMaxL, fluxR:spTotR, fluxL:spTotL}
    
end