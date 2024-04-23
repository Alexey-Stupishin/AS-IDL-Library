function sst_to_box_ext, lng, depth
    m = 2^(depth-1)
    n = ceil(double(lng)/m)
    return, n*m + 1
end

pro sst_to_box

date_obs = '2018-09-30T09:22:00'
fpath = 'g:\BIGData\Work\ISSI\12723\Process\Trim\Potential\'
ID = 'HMI+SST_combtrim'
continuum = 'g:\BIGData\Work\ISSI\12723\Sources\HMI\hmi.Ic_noLimbDark_720s.20180930_092400_TAI.continuum.fits'
magnetogram = 'g:\BIGData\Work\ISSI\12723\Sources\HMI\hmi.M_720s.20180930_092400_TAI.magnetogram.fits'

t0 = systime(/seconds)

restore, fpath + ID + '.sav' 
factor = 1
depth = 6
z_factor = 0.5

sz = size(BX)
naxis1 = sz[1]
naxis2 = sz[2]

data = dblarr(naxis1, naxis2, 3)
data[*, *, 0] = absB
data[*, *, 1] = incl
data[*, *, 2] = azim

foo = get_sun(date_obs, he_lon = crln_obs, he_lat = crlt_obs)

i0 = {naxis:2, cdelt1:cdelt1, crval1:crval1, crpix1:crpix1, naxis1:naxis1, cdelt2:cdelt2, crval2:crval2, crpix2:crpix2, naxis2:naxis2, crlt_obs:crlt_obs, crln_obs:crln_obs, crota2:0, date_obs:date_obs $
    , wcsname:'Helioprojective-cartesian', ctype1:'HPLN-TAN', ctype2:'HPLN-TAN', cunit1:'arcsec', cunit2:'arcsec'}

wcs0 = FITSHEAD2WCS( i0 )

;trying to correct position bug
wcs2map,data[*,*,0], wcs0, map
map2wcs, map,wcs0

;index0 = i0
;data0 = data
;save, filename = 'c:\Temp\sst_box_data_index_data3.sav', index0, data0, wcs0

;Calculating reference point in Carrington  coordinate system
asu_solar_par, i0.date_obs, solar_r = solar_r
center_arcsec  = ([(i0.naxis1+1)/2d, (i0.naxis2+1)/2d]-[i0.crpix1, i0.crpix2])*[i0.CDELT1, i0.CDELT2] + [i0.crval1, i0.crval2]
wcs_convert_from_coord,wcs0,center_arcsec,'HG', lon, lat, /carrington

step_in_R = i0.CDELT1/solar_r /factor
dx_deg = step_in_R * 180d /!dpi 
dr = [step_in_R, step_in_R, step_in_R]

;Seting up the basemap projection as a WCS structure
n1 = sst_to_box_ext(fix(i0.naxis1*factor), depth)
n2 = sst_to_box_ext(fix(i0.naxis2*factor), depth)
wcs = WCS_2D_SIMULATE(n1, n2, cdelt = dx_deg, crval =[lon,lat],$
    type ='CR', projection = 'cea', date_obs = i0.date_obs)

;Converting field to spherical coordinates
hmi_b2ptr, i0, data, bptr, lonlat=lonlat

; remapping data to the basmap projection
bp = wcs_remap(bptr[*,*,0],wcs0, wcs, /ssaa)
bt = wcs_remap(bptr[*,*,1],wcs0, wcs, /ssaa)
br = wcs_remap(bptr[*,*,2],wcs0, wcs, /ssaa)

read_sdo, continuum, index, data, /uncomp_delete
wcs0 = FITSHEAD2WCS(index[0])
wcs2map,data, wcs0, map
map2wcs, map,wcs0
ic = wcs_remap(data, wcs0, wcs, /ssaa)

base = {bx:-bp, by:-bt, bz:br, ic:ic}

;save, filename='c:\temp\sst.sav', box

sz = size(bp)
size_pix = lonarr(3)
size_pix[0] = sz[1]
size_pix[1] = sz[2]
size_pix[2] = sst_to_box_ext(floor(max(size_pix[0:1])*z_factor), depth)

refmaps = obj_new('map')
box = {bx:dblarr(size_pix), by:dblarr(size_pix), bz:dblarr(size_pix) $
    , dr:dr, add_base_layer:0, base:base, index:wcs2fitshead(wcs, /structure), refmaps: ptr_new(refmaps), id:ID} 
box.bx[*,*,0] = base.bx
box.by[*,*,0] = base.by
box.bz[*,*,0] = base.bz

bx = base.bx
by = base.by
bz = base.bz
save, filename = 'c:\Temp\sst_box_data_index_remap.sav ', bx, by, bz

gx_box_add_refmap, box, continuum, id = 'Continuum'
gx_box_add_refmap, box, magnetogram, id = 'LOS_magnetogram'

message, 'prepare complete in ' + asu_sec2hms(systime(/seconds)-t0, /issecs), /info

t0 = systime(/seconds)
gx_box_make_potential_field, box, pbox
message, 'potential complete in ' + asu_sec2hms(systime(/seconds)-t0, /issecs), /info

asu_box_get_coord, box, boxdata
asu_box_aia_from_box, box, daia

ID += '_' + asu_compstr(sz[1]) + 'x' + asu_compstr(sz[2])

bndid = fpath + ID + '_BND'
box.id = id
save, filename = bndid + '.sav', box
bndid += '_sst'
asu_box_create_mfodata, mfodata, box, box, daia, boxdata, bndid
save, file = bndid + '.sav', mfodata

pbox = box
potid = fpath + ID + '_POT'
save, filename = potid + '.sav', box
potid += '_sst'
asu_box_create_mfodata, mfodata, box, box, daia, boxdata, potid
save, file = potid + '.sav', mfodata

end
