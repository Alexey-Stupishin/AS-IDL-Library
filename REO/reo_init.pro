function reo_init, dll_location = dll_location, alt_dll_location = alt_dll_location, version_info = version_info, _extra = _extra

if not keyword_set(dll_location) then dll_location = reo_get_dll_location()
setenv, 'reo_dll_location=' + dll_location

value = bytarr(2)
if not keyword_set(alt_dll_location) then begin
    alt_dll_location = reo_get_dll_location(libname = 'MWGRTransfer64.dll')
    if not file_test(alt_dll_location, /EXECUTABLE) then begin
        alt_dll_location = 0
        value[1] = 1
    endif
endif 
    
nextra = n_tags(_extra)
n = nextra + 1 
parameterMap = replicate({itemName:'',itemvalue:0d},n+1)
nParameters = 0;
if nextra gt 0 then begin
    keys = strlowcase(tag_names(_extra))
    for i = 0, nextra-1 do begin
        parameterMap[nParameters].itemName = asu_subst_map_name(keys[i])
        parameterMap[nParameters].itemValue = _extra.(i)
        nParameters = nParameters + 1
    endfor
endif
parameterMap[nParameters].itemName = '!____idl_map_terminator_key___!';
  
data_ptr = CALL_EXTERNAL(dll_location, 'reoInitialize', parameterMap, alt_dll_location, VALUE = value, /UL64_VALUE)

if arg_present(version_info) then begin
    b = bytarr(512)
    b(*) = 32B
    version_info = STRING(b)
    rcv = CALL_EXTERNAL(dll_location, 'reoLibraryVersion', version_info)
endif

return, data_ptr

end

