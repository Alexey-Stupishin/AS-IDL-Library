;
; This code provides chromospheric models above different details on photosphere (from Quiet Sun inter-network to sunspot umbra).
; Based on: Fontenla et al., The Astrophysical Journal, 707:482–502, 2009 December 10
;    ADS: 2009ApJ...707..482F
;    DOI: 10.1088/0004-637X/707/1/482
;
; v 1.1.21.924 (rev.470)
; 
; Call:
; length = asu_get_fontenla2009(model, H, T, Nel, Np = np, Nh = Nh, name = name, Fontenla2009 = Fontenla2009)
; 
; Call examples:
; 1. length = asu_get_fontenla2009(7, H, T, Nel)
; 2. length = asu_get_fontenla2009('QS network', H, T, Nel, name = name)
; 3. length = asu_get_fontenla2009('Umbra', H, T, Nel, name = name)
; 4. restore, '<some_path>' + path_sep() + 'Fontenla2009.sav'
;    length = asu_get_fontenla2009('h', H, T, Nel, Np = np, Nh = Nh, name = name, Fontenla2009 = Fontenla2009)
; 
; Parameters description (see also Comments section below):
; 
; Parameters required (in):
;   (in)      model   (string or integer)   required model (see comment #1)
;   
; Parameters required (out):
;   (out)     H       (double array)        heigths above photosphere (cm), heretheafter see comment #2 regarding arrays length
;   (out)     T       (double array)        electron temperatures at corresponding heights (K)
;   (out)     Nel     (double array)        electron density at corresponding heights (cm^{-3})
;  
; Parameters optional (in):
;   (in)      Fontenla2009 (structure)      structure with models data, which was preliminary loaded. If omitted,
;                                           structure will be loaded from the file 'Fontenla2009.sav', which should
;                                           be placed at the same location as this code placed. 
;  
; Parameters optional (out):
;   (out)     Np      (double array)        proton density at corresponding heights (cm^{-3})
;   (out)     Nh      (double array)        hydrogen density at corresponding heights (cm^{-3})
;   (out)     name    (string)              full name of the model (see comment #1)
;   
; Return value:
;   length of heights (H) and another corresponding arrays. 
;     Zero in the case of problems (no appropriate model is found. Info message "Wrong Fontenla Model" will be displayed in this case). 
;
; Comments:
;   1. According cited Fontenla paper (p.485), the are 7 models (listed as 'full name' (model#, 'short name', 'Fontenla model letter')):
;     1.1. 'QS inter-network'           (1, 'QSINW',    'b')
;     1.2. 'QS network lane'            (2, 'QSNWL',    'd')
;     1.3. 'Enhanced network'           (3, 'EnhNW',    'f')
;     1.4. 'Plage (that is not facula)' (4, 'Plage',    'h')
;     1.5. 'Facula (very bright plage)' (5, 'Facula',   'p')
;     1.6. 'Penumbra'                   (6, 'Penumbra', 'r')
;     1.7. 'Umbra'                      (7, 'Umbra',    's')
;     (и ежели вы меня спросите, что такое первые три, и в чем разница между четвертой и пятой, то не ожидайте
;      быстрого ответа, и вообще никакого не ожидайте, проще будет просто заткнуть уши).
;
;     According to the table above, parameter 'model' can be either:
;       * the number from 1 to 7 (first value in the parentheses), or
;       * the short name (second value in the parentheses), or
;       * the full name, as in the previous list (first 6 symbols are enough), or, at least,
;       * the Fontenla model letter (third value in the parentheses).
;     All string comparisons are case-insensitive.
;      
;   2. All data arrays (H, N, Nel, Np, Nh) are of the same length (= return value). Arrays undefined in the case of problems.
;   
;   3. Maximum heigth is approximately 2e5 km = 200 Mm = 2e10 cm. It is quite enough for bremsstrahlung radiation calculation.
;      User can extend these arrays to the upper corona according to the h(is/er) desires.  
;   
; (c) Alexey G. Stupishin, Saint Petersburg State University, Saint Petersburg, Russia, 2021
;     mailto:agstup@yandex.ru
;
;--------------------------------------------------------------------------;
;     \|/     Set the Controls for the Heart of the Sun           \|/      ;
;    --O--        Pink Floyd, "A Saucerful Of Secrets", 1968     --O--     ;
;     /|\                                                         /|\      ;  
;--------------------------------------------------------------------------;
;                                                              
function asu_get_fontenla2009, model, H, T, Nel, Np = np, Nh = Nh, name = name, Fontenla2009 = Fontenla2009

if n_elements(Fontenla2009) eq 0 then begin
    dirpath = file_dirname((ROUTINE_INFO('asu_get_fontenla2009', /source, /functions)).path, /mark)
    restore, dirpath + 'Fontenla2009.sav'
endif

names = ['QS inter-network', 'QS network lane', 'Enhanced network', $
         'Plage (that is not facula)', 'Facula (very bright plage)', 'Penumbra', 'Umbra']
short = ['QSINW', 'QSNWL', 'EnhNW', 'Plage', 'Facula', 'Penumbra', 'Umbra']
modnames = ['b', 'd', 'f', 'h', 'p', 'r', 's']

if isa(model, /NUMBER) then begin
    idx = model-1
endif else begin
    idx = where(strlowcase(model) eq strlowcase(short), count)
    if count eq 0 then begin
        idx = where(strcmp(names, model, 6, /FOLD_CASE), count)
        if count eq 0 then begin
            idx = where(strcmp(modnames, model, 1, /FOLD_CASE), count)
            if count eq 0 then idx = -1
        endif    
    endif
endelse

if idx lt 0 or idx gt 6 then begin
    message, 'Wrong Fontenla Model', /info
    return, 0
endif

H = transpose(Fontenla2009.H[idx, 0:Fontenla2009.Length[idx]-1])*1d5
T = transpose(Fontenla2009.T[idx, 0:Fontenla2009.Length[idx]-1])
Nel = transpose(Fontenla2009.Nel[idx, 0:Fontenla2009.Length[idx]-1])
Np = transpose(Fontenla2009.Np[idx, 0:Fontenla2009.Length[idx]-1])
NH = transpose(Fontenla2009.NH[idx, 0:Fontenla2009.Length[idx]-1])
name = names[idx]

return, n_elements(H)

end
