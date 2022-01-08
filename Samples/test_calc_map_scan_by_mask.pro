pro test_calc_map_scan_fill_by_mask, Hf, Tf, Df, dh, addT, NT, H, Temp, Dens

length = n_elements(Hf)
n_add = n_elements(addT)
H = dblarr(length+n_add)
H[0:-(n_add+1)] = Hf
Temp = dblarr(length+n_add)
Temp[0:-(n_add+1)] = Tf
Dens = dblarr(length+n_add)
Dens[0:-(n_add+1)] = Df
for k = 0, n_add-1 do begin
    H[-(n_add-k)] = H[-(n_add-k+1)] + dh[k]
    Temp[-(n_add-k)] = addT[k]
    Dens[-(n_add-k)] = NT/Temp[-(n_add-k)]
endfor

end

;--------------------------------------------------------------------------------------
pro test_calc_map_scan_by_mask
dirpath = file_dirname((ROUTINE_INFO('test_calc_map_scan_by_mask', /source)).path, /mark)
filename = dirpath + '12470_hmi.M_720s.20151218_125809.W86N13CR.CEA.NAS_1000.sav' 
restore, filename ; GX-box

visstep = 0.5 ; arcsec - шаг видимой сетки радиокарты
posangle = 0 ; позиционный угол: 
freq = 10e9 ; Hz - частота

ptr = reo_prepare_calc_map( $
      box, visstep $ ; GX-модель и шаг радиокарты 
    , M, base $ результат: размер и смещение радиокарты
    , posangle = posangle $  
    , freefree = 1 $ ; consider free-free
    , arcbox = arcbox $ ; вернет границы радиокарты в угл. секундах
    , field = field $ ; вернет полное поле на фотосфере, как мы видим его с Земли
    
    , dll_location = 's:\Projects\Physics104_291\ProgramD64\agsGeneralRadioEmission.dll' $
;    , dll_location = 's:\Projects\IDL\ASlibrary\REO\agsGeneralRadioEmission.dll' $
        
    , version_info = version_info $ ; когда, где и в какой версии библиотеки мы работаем - для контроля
    )

if ptr eq 0 then begin ; что-то пошло не так ...
    message, 'Prepare Library Problem', /cont
    return
endif

print, version_info

;---------------------------------------------------------------------------------------
; Построение маски с учетом поля и излучения в континууме ------------------------------

model_mask = reo_get_model_mask(ptr, box.base.Bz, box.base.ic)

; для тени
umbra = model_mask eq 7
length = asu_get_fontenla2009(7, Hf, Tf, Df)
test_calc_map_scan_fill_by_mask, Hf, Tf, Df, [1e7, 1e8, 3e9], [1e6, 2e6, 2e6], 1e16, H, Temp, Dens

rc = reo_calculate_map( $
      ptr, H, Temp, Dens, freq $
    , viewMask = umbra $
    , FluxR = FluxRu $
    , FluxL = FluxLu $
    )
    
if max(FluxRu) gt 0 then begin    
    cR = contour(alog10(FluxRu), RGB_TABLE = 0, N_LEVELS=30, ASPECT_RATIO=1.0, window_title = 'Right map (umbra)', /FILL)
endif
rcr = reo_convolve_map(ptr, FluxRu, freq, scanRu)
if max(FluxLu) gt 0 then begin    
    cL = contour(alog10(FluxLu), RGB_TABLE = 0, N_LEVELS=30, ASPECT_RATIO=1.0, window_title = 'Left map (umbra)', /FILL)
end
rcr = reo_convolve_map(ptr, FluxLu, freq, scanLu)

xarc = asu_linspace(arcbox[0, 0], arcbox[1, 0], n_elements(scanRu))
pR = plot(xarc, scanRu, '-k2', window_title = 'Right scan', name = 'umbra')
pL = plot(xarc, scanLu, '-k2', window_title = 'Left scan', name = 'umbra')
    
; для полутени
penumbra = model_mask eq 6
length = asu_get_fontenla2009(6, Hf, Tf, Df)
test_calc_map_scan_fill_by_mask, Hf, Tf, Df, [1e7, 1.5e8, 3e9], [2e6, 3e6, 3e6], 1e16, H, Temp, Dens

rc = reo_calculate_map( $
      ptr, H, Temp, Dens, freq $
    , viewMask = penumbra $
    , FluxR = FluxRp $
    , FluxL = FluxLp $
    )

FluxR = FluxRu + FluxRp    
FluxL = FluxLu + FluxLp
if max(FluxRp) gt 0 then begin    
    cR = contour(alog10(FluxRp), RGB_TABLE = 0, N_LEVELS=30, ASPECT_RATIO=1.0, window_title = 'Right map (penumbra)', /FILL)
endif
rcr = reo_convolve_map(ptr, FluxR, freq, scanRup)
pRu = plot(xarc, scanRup, '-g2', OVERPLOT = pR, name = 'u+p')
if max(FluxLp) gt 0 then begin    
    cL = contour(alog10(FluxLp), RGB_TABLE = 0, N_LEVELS=30, ASPECT_RATIO=1.0, window_title = 'Left map (penumbra)', /FILL)
endif
rcr = reo_convolve_map(ptr, FluxL, freq, scanLup)
pLu = plot(xarc, scanLup, '-g2', OVERPLOT = pL, name = 'u+p')

; для факелов
facula = model_mask eq 5 
length = asu_get_fontenla2009(5, Hf, Tf, Df)
test_calc_map_scan_fill_by_mask, Hf, Tf, Df, [1e7, 1.6e8, 3e9], [2e6, 3e6, 3e6], 1e16, H, Temp, Dens

rc = reo_calculate_map( $
      ptr, H, Temp, Dens, freq $
    , viewMask = facula $
    , FluxR = FluxRx $
    , FluxL = FluxLx $
    )
if max(FluxRx) gt 0 then begin    
    cR = contour(alog10(FluxRx), RGB_TABLE = 0, N_LEVELS=30, ASPECT_RATIO=1.0, window_title = 'Right map (facula)', /FILL)
endif
if max(FluxLx) gt 0 then begin    
    cL = contour(alog10(FluxLx), RGB_TABLE = 0, N_LEVELS=30, ASPECT_RATIO=1.0, window_title = 'Left map (facula)', /FILL)
endif
FluxR = FluxR + FluxRx    
FluxL = FluxL + FluxLx
rcr = reo_convolve_map(ptr, FluxR, freq, scanRCm)
rcr = reo_convolve_map(ptr, FluxL, freq, scanLCm)
pRf = plot(xarc, scanRCm, '-r2', OVERPLOT = pR, name = 'u+p+f')
pLf = plot(xarc, scanLCm, '-r2', OVERPLOT = pL, name = 'u+p+f')

gLegR = legend(target = [pR, pRu, pRf], /AUTO_TEXT_COLOR)
gLegL = legend(target = [pL, pLu, pLf], /AUTO_TEXT_COLOR)

rc = reo_uninit(ptr)
    
end