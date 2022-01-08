; IDL Wrapper to:
;   
;   
; v 
; 
; NB! Beta-version! But nearly ready to enduser... (and only under Windows 64-bit, sorry...)
; 
; Call:
; Parameters description:
; 
; Parameters required (in):
;   (in)      ptr             (ULONG64)                                   Pointer to the data structure (see reo_prepare_calc_map.pro)
;         H, T, D - height profiles
;   (in)      H               (n*nmask-elements fload/double array)        cm   Heights above the photosphere, in ascending order  
;   (in)      T               (n*nmask-elements fload/double array)         K   Corresponding temperatures (non-negative, no greater 10^8)
;   (in)      D               (n*nmask-elements fload/double array)    cm^{-3}  Corresponding electron densities (non-negative)
;                                                                         Note: all 3 arrays should be of the same length
;   (in) ................................
;   
; Return code:
;       0     no errors
;   < 200   initialization errors (perhaprs reo_prepare_calc_map was not called before)
;     201   zero length atmosphere data
;     202   heights are not in asceding order
;     203   temperature(s) are negative or exceed 100 MK
;     204   density(ies) are negative
;
; (c) Alexey G. Stupishin, Saint Petersburg State University, Saint Petersburg, Russia, 2017-2021
;     mailto:agstup@yandex.ru
;
;--------------------------------------------------------------------------;
;     \|/     Set the Controls for the Heart of the Sun           \|/      ;
;    --O--        Pink Floyd, "A Saucerful Of Secrets", 1968     --O--     ;
;     /|\                                                         /|\      ;  
;--------------------------------------------------------------------------;
;                                              
                                              
;----------------------------------------------------------------------------------------------
function reo_set_atmosphere_mask, ptr $
                          , H, T, D, Lmask $
                          , masksN, mask $
                          , _extra = _extra

dll_location = getenv('reo_dll_location')

vptr = ulong64(ptr)

sz = size(H)
maxH = long(sz[1])
nmasks = long(sz[2])
vLmask = long(Lmask)
vH = double(H)
vT = double(T)
vD = double(D)
sz = size(mask)
N = lonarr(2)
N[0] = sz[1]
N[1] = sz[2]
vmasksN = long(masksN)
vmask = long(transpose(mask, [1, 0]))

value = bytarr(11)
value[2:3] = 1 ;

parameterMap = {itemName:'!____idl_map_terminator_key___!', itemvalue:0d}

returnCode = CALL_EXTERNAL(  dll_location, 'reoSetAtmosphereMask', vptr, parameterMap $     ; 0-1
                           , nmasks, maxH, Lmask, vH, vT, vD $                              ; 2-7    
                           , vmasksN, N, vmask $                                            ; 8-10
                           , VALUE = value, /CDECL)

return, returnCode

end
