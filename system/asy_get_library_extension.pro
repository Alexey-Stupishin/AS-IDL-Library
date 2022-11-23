function asy_get_library_extension

if !VERSION.OS_FAMILY ne 'Windows' then begin
    return, '.so'
endif else begin
    return, '.dll'
end

end
