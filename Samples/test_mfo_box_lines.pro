pro mfo_box_lines_aia, aia_data, aia_index, line_res, boxdata, rotator = rotator

sz = size(aia_data)
x = (dindgen(sz[1])-(sz[1]-1)/2d)*aia_index.cdelt1 + aia_index.xcen
y = (dindgen(sz[2])-(sz[2]-1)/2d)*aia_index.cdelt2 + aia_index.ycen

device, decomposed = 0
aia_lct_silent, wave = 171, /load
implot, comprange(double(aia_data), 2, /global), x, y, /iso

device, decomposed = 1
for i = 0, line_res.nLines-1 do begin
    line = asu_gxbox_get_line(line_res, i, boxdata, rotator = rotator)
    oplot, line[0,*], line[1,*], color = '00FF00'x
endfor

end    

;-----------------------------------------------------------------------    
pro test_mfo_box_lines

aiafits = 's:\University\Work\11312_for_2022\20111010_080000_20111010_100000_-95_285_267_267\aia_data\171\aia.lev1_euv_12s_mod.2011-10-10T085813Z.3.image.fits'   
sourcefile = 's:\University\Work\11312_for_2022\HMI_wide\11312_hmi.M_720s.20111010_085818.W116N26CR.CEA.NAS.sav';
iz = 2
porosity = 15

restore, sourcefile

asu_box_get_coord, box, boxdata

;----------------------------------------------
; example of using seeds
sz = size(box.bz)
inputSeeds = dblarr(3, sz[1]*sz[2]*sz[3])

cnt = 0
for ix = 0, sz[1]-1, porosity do begin
    for iy = 0, sz[2]-1, porosity do begin
        inputSeeds[*, cnt++] = [ix, iy, iz] 
    endfor
endfor
inputSeeds = inputSeeds[*, 0:cnt-1] 

;----------------------------------------------
t0 = systime(/seconds)
nLines = asu_gxbox_calc_lines(box, inputSeeds, line_res)
message, strcompress(string(systime(/seconds)-t0,format="('processed in ',g0,' seconds')")), /cont
print, "stored lines: ", nLines
print, "non-stored lines: ", line_res.nonStored

window, 0
device, decomposed = 0
loadct, 0, /silent

x_arc = dindgen(sz(1))*boxdata.dx*boxdata.rsun
y_arc = dindgen(sz(2))*boxdata.dy*boxdata.rsun
implot, bytscl(box.bz[*,*,0]), x_arc, y_arc, /iso, xtitle = 'arcsec', ytitle = 'arcsec'

device, decomposed = 1
for i = 0, nLines-1 do begin
    line = asu_gxbox_get_line(line_res, i, boxdata)
    oplot, line[0,*], line[1,*], color = '00FF00'x
endfor

rotator = asu_gxbox_get_rotator(boxdata)

if asu_gxbox_get_aia(box, 171, aia_data, aia_index) then begin
    window, 1
    mfo_box_lines_aia, aia_data, aia_index, line_res, boxdata, rotator = rotator
endif    

read_sdo_silent, aiafits, aia_index, aia_data, /use_shared, /uncomp_delete, /hide, /silent
window, 2
mfo_box_lines_aia, aia_data, aia_index, line_res, boxdata, rotator = rotator

end
