pro test_mfo_box_lines

;sourcefile = 'c:\11312_hmi.M_720s.20111010_085818.W121N24CR.CEA.NAS_750.sav'
sourcefile = 'g:\BIGData\UData\SDOBoxes\12533_hmi.M_720s.20160428_094643.E177S2CR.CEA.POT.sav';
restore, sourcefile

asu_box_get_coord, box, boxdata
;mfodata = {  sst_version:'20200228' $
;           , bx:transpose(data.by, [1, 0, 2]), by:transpose(data.bx, [1, 0, 2]), bz:transpose(data.bz, [1, 0, 2]) $
;           , ic:transpose(box.base.ic, [1, 0]), magn_src:magnetogram, cont_src:continuum, model_mask:transpose(model_mask, [1, 0]) $
;           , obstime:box.index.date_obs, fileid:fileid $
;           , x_box:transpose(boxdata.y_box, [1, 0]), y_box:transpose(boxdata.x_box, [1, 0]) $
;           , dkm:boxdata.dkm, dx_arc:boxdata.dy*boxdata.rsun, dy_arc:boxdata.dx*boxdata.rsun $
;           , x_cen:boxdata.y_cen, y_cen:boxdata.x_cen, R_arc:boxdata.rsun $
;           , lon_cen:boxdata.lon_cen, lat_cen:boxdata.lat_cen $
;           , vcos:vcos $
;           , lon_hg:transpose(boxdata.lon_hg, [1, 0]), lat_hg:transpose(boxdata.lat_hg, [1, 0]) $
;           , input_x:input_coords.y, input_y:input_coords.x $
;           , aia_ids:aia.ids, aia_data:aia.data, aia_size:aia.size, aia_center:aia.center, aia_step:aia.step, aia_RSun:aia.RSun $
;           , version_info:version_info $
;                  }

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

dx_arc = boxdata.dx*boxdata.rsun
dy_arc = boxdata.dy*boxdata.rsun

device, decomposed = 0
loadct, 0, /silent

x_arc = indgen(sz(1))*dx_arc
y_arc = indgen(sz(2))*dy_arc
;implot, bytscl(box.bz[*,*,0]), x_arc, y_arc, /iso, xtitle = 'arcsec', ytitle = 'arcsec'
tvplot, bytscl(box.bz[*,*,0]), x_arc, y_arc, /iso, xtitle = 'arcsec', ytitle = 'arcsec'

device, decomposed = 1
for i = 0, nLines-1 do begin
    x = coords[0, linesPos[i]:(linesPos[i]+linesLength[i]-1)]*dx_arc
    y = coords[1, linesPos[i]:(linesPos[i]+linesLength[i]-1)]*dy_arc
    oplot, x, y, color = '00FF00'x
endfor

end
