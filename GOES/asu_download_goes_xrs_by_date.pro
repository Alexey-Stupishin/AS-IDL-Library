function asu_download_goes_xrs_by_date, date, loc_dir = loc_dir, sat = sat, sec = sec, version = version
compile_opt idl2

t = asu_extract_time(date + ' 00:00:00', out_style = 'UTC_EXT')
y = string(t.year,FORMAT='(I04)')
m = string(t.month,FORMAT='(I02)')
d = string(t.day,FORMAT='(I02)')

default, sat, '17'
if ~isa(sat, 'STRING') then sat = asu_compstr(sat)

cadence = n_elements(sec) ne 0 && sec ne 0 ? 'flx1s' : 'avg1m'

default, version, 'v2-2-0'
path = 'https://data.ngdc.noaa.gov/platforms/solar-space-observing-satellites/goes/goes'
basef = path + sat + '/l2/data/xrsf-l2-' + cadence + '_science'
srcf = 'sci_xrsf-l2-' + cadence + '_g' + sat + '_d' + y + m + d + '_' + version + '.nc'
path1m = basef + '/' + y + '/' + m + '/' + srcf  

default, loc_dir, GETENV('IDL_TMPDIR')
if not file_test(loc_dir, /directory) then file_mkdir, loc_dir
 
aria2_urls_rand, path1m, loc_dir, output = output

if output[-1] eq '(OK):download completed.' then begin
    locfile = loc_dir + path_sep() + srcf
    filedate = y + '-' + m + '-' + d
    return, {status:'OK', source:srcf, local:locfile, date:filedate, cadence:cadence}
endif else begin
    return, {status:'FAIL', output:output}
endelse        

end
