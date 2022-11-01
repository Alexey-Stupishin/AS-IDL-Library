pro test_gxboxlines2

if !VERSION.OS_FAMILY ne 'Windows' then begin
    ppath = '/home/stupishin/'
    ext = '.so'
endif else begin
    ppath = 's:\'
    ext = '.dll'
end
dll_path = ppath + 'GX_SIMULATOR'  + path_sep() + 'nlfff' + path_sep() + 'source' + path_sep() + 'binaries' + path_sep() + 'WWNLFFFReconstruction' + ext

;restore, ppath + 'gx_models' + path_sep() + '2012-07-12' + path_sep() + 'hmi.M_720s.20120712_044626.W82S16CR.CEA.NAS.sav'
restore, ppath + 'GX_SIMULATOR'  + path_sep() + 'benchmark' + path_sep() + 'hmi.M_720s.20160220_165811.E34N4CR.CEA.NAS.sav'

chromo_level = 1000

for reduce_passed = 0, 3 do begin
    t0 = systime(/seconds)    
    non_stored = gx_box_calculate_lines(dll_path, box, maxLength = 1000000d $
                                      , status = status, physLength = physLength, avField = avField, startIdx = startIdx, endIdx = endIdx $
                                      , nLines = nLines, nPassed = nPassed $
                                      , coords = coords, linesPos = linesPos, linesLength = linesLength $
                                      , chromo_level = chromo_level, reduce_passed = reduce_passed)
    message, 'info ' + asu_sec2hms(systime(/seconds)-t0, /issecs), /info
    message, 'reduce = ' + asu_compstr(reduce_passed), /info
    message, 'nLines+non_stored = ' + asu_compstr(nLines+non_stored), /info
    message, 'totLength = ' + asu_compstr(double(total(linesLength))), /info
    message, 'nPassed = ' + asu_compstr(nPassed), /info
    idx = where(status and 1, count1) ; processed
    message, 'processed(0) = ' + asu_compstr(count1), /info
    idx = where(status and 2, count2) ; passed voxels
    message, 'passed(1) = ' + asu_compstr(count2), /info
    idx = where(status and 4, count4) ; voxels of closed lines
    message, 'closed(2) = ' + asu_compstr(count4), /info
    idx = where(status and 8, count8) ; seed voxels
    message, 'seeds(3) = ' + asu_compstr(count8), /info
    
    idx=where((status and 4L) eq 4L)
    oidx=where(((status and 2L) eq 2l) and ((status and 4L) eq 0))
        
    message, ' ', /info
endfor
                           
end