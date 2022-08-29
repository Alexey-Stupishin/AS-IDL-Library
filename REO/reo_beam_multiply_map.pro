function reo_beam_multiply_map, ptr, fluxmap, multmap, freq, pos, _extra = _extra 

dll_location = getenv('reo_dll_location')

vptr = ulong64(ptr)
vmap = double(transpose(fluxmap, [1, 0]))
vfreq = double(freq)
vpos = long(pos)

vmode = 3L
vck = double(0)
vbk = double(0)
vscanlimpos = 0L

value = bytarr(8)
value[2:5] = 1 ; freq to nBeam

n = n_tags(_extra)
if n gt 0 then begin
    keys = strlowcase(tag_names(_extra))
    for i = 0, n-1 do begin
        case keys[i] of
            'mode': begin 
                vmode = long(_extra.(i))
            end
            'beam_c': begin 
                vck = double(_extra.(i))
            end
            'beam_b': begin 
                vbk = double(_extra.(i))
            end
            else:
        endcase
    endfor
endif

returnCode = CALL_EXTERNAL(dll_location, 'reoBeamMultiply', vptr, vmap, vfreq, vpos, $
                           vmode, long(n_elements(vck)), vck, vbk, VALUE = value, /CDECL)

multmap = double(transpose(vmap, [1, 0]))

return, returnCode 

end
