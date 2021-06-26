function reo_set_double, ptr, name, val

dll_location = getenv('reo_dll_location')

value = bytarr(3)
value[2] = 1
returnCode = CALL_EXTERNAL(dll_location, 'reoSetDouble', ulong64(ptr), name, double(val), VALUE = value)

return, returnCode  

end
