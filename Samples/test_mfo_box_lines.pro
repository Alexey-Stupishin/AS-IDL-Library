pro test_mfo_box_lines

sourcefile = 'c:\11312_hmi.M_720s.20111010_085818.W121N24CR.CEA.NAS_750.sav'
restore, sourcefile

anchor_function = 'gx_box_calculate_lines'
resolve_routine, anchor_function, /compile_full_file, /either
dll_location = file_dirname((ROUTINE_INFO(anchor_function, /source, /functions)).path, /mark) + 'WWNLFFFReconstruction.dll'

maxLength = 1000000L

;----------------------------------------------
; example of using seeds
sz = size(box.bz)
inputSeeds = dblarr(3, sz[1]*sz[2]*sz[3])
iz = 2
porosity = 6

cnt = 0
for ix = 0, sz[1]-1, porosity do begin
    for iy = 0, sz[2]-1, porosity do begin
        inputSeeds[*, cnt++] = [ix, iy, iz] 
    endfor
endfor
inputSeeds = inputSeeds[*, 0:cnt-1] 

;----------------------------------------------
t0 = systime(/seconds)
nonStored = gx_box_calculate_lines(dll_location, box $
                        , coords = coords, linesPos = linesPos, linesLength = linesLength, nLines = nLines $
                        , inputSeeds = inputSeeds $
                        , maxLength = maxLength $
                        )

message, strcompress(string(systime(/seconds)-t0,format="('processed in ',g0,' seconds')")), /cont
print, "stored lines: ", nLines
print, "non-stored lines: ", nonStored

device, decomposed = 0
loadct, 0, /silent

implot, bytscl(box.bz[*,*,0]), /iso

device, decomposed = 1
for i = 0, nLines-1 do begin
    x = coords[0, linesPos[i]:(linesPos[i]+linesLength[i]-1)]
    y = coords[1, linesPos[i]:(linesPos[i]+linesLength[i]-1)]
    oplot, x, y, color = '00FF00'x
endfor

end
