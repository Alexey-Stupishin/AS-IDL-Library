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
;filename = dirpath + '12470_hmi.M_720s.20151218_125809.W86N13CR.CEA.NAS_1000.sav' 
filename = 'g:\BIGData\UData\SDOBoxes_HMI_Select\12419\IDL\12419_hmi.M_720s.20150918_095819.E160N10CR.CEA.NAS.sav' 
restore, filename ; GX-box

length = asu_get_fontenla2009(7, Hf, Tf, Df)
test_calc_map_scan_fill_by_mask, Hf, Tf, Df, [1e7, 1e8, 3e9], [2e6, 3e6, 3e6], 3e15, H, Temp, Dens
ht = plot(H, Temp, /ylog, xrange = [0, 3e8])
hd = plot(H, Dens, /ylog, xrange = [0, 3e8])
;H =    [1,   1e8, 1.1e8, 2e10] ; cm - высота над фотосферой
;Temp = [1e4, 1e4, 2e6,   2e6] ; K - температуры на соответствующих высотах
;Dens = 3e15/Temp ; cm^{-3} - плотности электронов там же

visstep = 0.5 ; arcsec - шаг видимой сетки радиокарты
posangle = 0 ; позиционный угол: 
freq = 10e9 ; Hz - частота

ptr = reo_prepare_calc_map( $
      box, visstep $ ; GX-модель и шаг радиокарты 
    , M, base $ результат: размер и смещение радиокарты
    , posangle = posangle $  
    , freefree = 0 $ ; no free-free considered
    , arcbox = arcbox $ ; вернет границы радиокарты в угл. секундах
    , field = field $ ; вернет полное поле на фотосфере, как мы видим его с Земли
    , dll_location = 's:\Projects\Physics104_291\ProgramD64\agsGeneralRadioEmission.dll' $
    , version_info = version_info $ ; когда, где и в какой версии библиотеки мы работаем - для контроля
    )

if ptr eq 0 then begin ; что-то пошло не так ...
    message, 'Prepare Library Problem', /cont
    return
endif

print, version_info

Bph = sqrt(field.bx^2 + field.by^2 + field.bz^2)
cB = contour(Bph, RGB_TABLE = 0, N_LEVELS=30, ASPECT_RATIO=1.0, window_title = 'Photosphere Field', /FILL)

rc = reo_calculate_map( $
      ptr, H, Temp, Dens, freq $
    , harmonics = [2, 3] $
    , FluxR = FluxR $
    , FluxL = FluxL $
    , scanR = scanR $
    , scanL = scanL $
    )
    
cR = contour(alog10(FluxR), RGB_TABLE = 0, N_LEVELS=30, ASPECT_RATIO=1.0, window_title = 'Right map', /FILL)
cL = contour(alog10(FluxL), RGB_TABLE = 0, N_LEVELS=30, ASPECT_RATIO=1.0, window_title = 'Left map', /FILL)
xarc = asu_linspace(arcbox[0, 0], arcbox[1, 0], n_elements(scanR))         
pR = plot(xarc, scanR, window_title = 'Right scan')
pL = plot(xarc, scanL, window_title = 'Left scan')

;---------------------------------------------------------------------------------------
; Другое построение маски, с учетом поля и излучения в континууме ----------------------

model_mask = reo_get_model_mask(ptr, Bph, box.base.ic, cont = cont, used = used)

umbra = model_mask eq 7
length = asu_get_fontenla2009(7, Hf, Tf, Df)
test_calc_map_scan_fill_by_mask, Hf, Tf, Df, [1e7, 1e8, 3e9], [2e6, 3e6, 3e6], 3e15, H, Temp, Dens

rc = reo_calculate_map( $
      ptr, H, Temp, Dens, freq $
    , viewMask = umbra $
    , FluxR = FluxRu $
    , FluxL = FluxLu $
    )
cR = contour(alog10(FluxRu), RGB_TABLE = 0, N_LEVELS=30, ASPECT_RATIO=1.0, window_title = 'Right map (2 models)', /FILL)
cL = contour(alog10(FluxLu), RGB_TABLE = 0, N_LEVELS=30, ASPECT_RATIO=1.0, window_title = 'Left map (2 models)', /FILL)
    
penumbra = model_mask eq 6
length = asu_get_fontenla2009(7, Hf, Tf, Df)
test_calc_map_scan_fill_by_mask, Hf, Tf, Df, [1e7, 1e8, 3e9], [2e6, 3e6, 3e6], 3e15, H, Temp, Dens

rc = reo_calculate_map( $
      ptr, H, Temp, Dens, freq $
    , viewMask = penumbra $
    , FluxR = FluxRp $
    , FluxL = FluxLp $
    )
cR = contour(alog10(FluxRp), RGB_TABLE = 0, N_LEVELS=30, ASPECT_RATIO=1.0, window_title = 'Right map (2 models)', /FILL)
cL = contour(alog10(FluxLp), RGB_TABLE = 0, N_LEVELS=30, ASPECT_RATIO=1.0, window_title = 'Left map (2 models)', /FILL)

FluxR = FluxRu + FluxRp    
FluxL = FluxLu + FluxLp
rcr = reo_convolve_map(ptr, FluxR, freq, scanRCm)
rcr = reo_convolve_map(ptr, FluxL, freq, scanLCm)

cR = contour(alog10(FluxR), RGB_TABLE = 0, N_LEVELS=30, ASPECT_RATIO=1.0, window_title = 'Right map (2 models)', /FILL)
cL = contour(alog10(FluxL), RGB_TABLE = 0, N_LEVELS=30, ASPECT_RATIO=1.0, window_title = 'Left map (2 models)', /FILL)
xarc = asu_linspace(arcbox[0, 0], arcbox[1, 0], n_elements(scanRCm))         
pRC = plot(xarc, scanRCm, '-:g4', OVERPLOT = pR)
pLC = plot(xarc, scanLCm, '-:g4', OVERPLOT = pL)

penumbra = (model_mask ne 6) and (model_mask ne 7) 
length = asu_get_fontenla2009(7, Hf, Tf, Df)
test_calc_map_scan_fill_by_mask, Hf, Tf, Df, [1e7, 1e8, 3e9], [2e6, 3e6, 3e6], 3e15, H, Temp, Dens

rc = reo_calculate_map( $
      ptr, H, Temp, Dens, freq $
    , viewMask = penumbra $
    , FluxR = FluxRx $
    , FluxL = FluxLx $
    )
cR = contour(alog10(FluxRx), RGB_TABLE = 0, N_LEVELS=30, ASPECT_RATIO=1.0, window_title = 'Right map (2 models)', /FILL)
cL = contour(alog10(FluxLx), RGB_TABLE = 0, N_LEVELS=30, ASPECT_RATIO=1.0, window_title = 'Left map (2 models)', /FILL)
    
FluxR = FluxR + FluxRx    
FluxL = FluxL + FluxLx
rcr = reo_convolve_map(ptr, FluxR, freq, scanRCm)
rcr = reo_convolve_map(ptr, FluxL, freq, scanLCm)

cR = contour(alog10(FluxR), RGB_TABLE = 0, N_LEVELS=30, ASPECT_RATIO=1.0, window_title = 'Right map (2 models)', /FILL)
cL = contour(alog10(FluxL), RGB_TABLE = 0, N_LEVELS=30, ASPECT_RATIO=1.0, window_title = 'Left map (2 models)', /FILL)
xarc = asu_linspace(arcbox[0, 0], arcbox[1, 0], n_elements(scanRCm))         
pRC = plot(xarc, scanRCm, '-:b4', OVERPLOT = pR)
pLC = plot(xarc, scanLCm, '-:b4', OVERPLOT = pL)

rc = reo_uninit(ptr)
    
end