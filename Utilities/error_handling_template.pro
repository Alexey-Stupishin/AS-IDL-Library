pro error_handling_template, array_or_list, reportfile

openw, U, reportfile, /GET_LUN
ntot = isa(array_or_list, /ARRAY) ? n_elements(array_or_list) : array_or_list.Count()
ncrash = 0
tt = systime(/seconds)
foreach element, array_or_list, index_of_element do begin
    CATCH, err_status
    if err_status ne 0 then begin
        CALL_PROCEDURE, 'print_into_U', element, index_of_element, ntot
        printf, U, '  -> Error! ', !ERROR_STATE.MSG
        flush, U
        CATCH, /CANCEL
        ncrash++
        continue
    endif

    CALL_PROCEDURE, 'do_something', element, index_of_element
endforeach

stamp = asu_sec2hms(systime(/seconds)-tt, /issecs)
vntot = strcompress(string(ntot), /remove_all)
vncrash = strcompress(string(ncrash), /remove_all)
printf, U, '********* BATCH FINISHED SUCCESSFULLY, total ' + vntot + ' elements (' + vncrash + ' crashed) performed in ' + stamp
close, U
FREE_LUN, U

end
