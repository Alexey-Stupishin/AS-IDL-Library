function reo_uninit, ptr

dll_location = getenv('reo_dll_location')
vptr = ulong64(ptr)
returnCode = CALL_EXTERNAL(dll_location, 'reoUninitialize', vptr, /UNLOAD)

return, returnCode 

end
