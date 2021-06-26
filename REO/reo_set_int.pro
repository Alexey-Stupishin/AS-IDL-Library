function reo_set_int, ptr, name, val

dll_location = getenv('reo_dll_location')

value = bytarr(3)
value[2] = 1
returnCode = CALL_EXTERNAL(dll_location, 'reoSetInt', ulong64(ptr), name, long(val), VALUE = value)

return, returnCode  

end
