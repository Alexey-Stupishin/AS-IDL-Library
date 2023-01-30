function asu_download_goes_xrs_by_date, date, loc_dir = loc_dir, sat = sat ; , sec = sec
compile_opt idl2

t = asu_extract_time(date + ' 00:00:00', out_style = 'UTC_EXT')
y = string(t.year,FORMAT='(I04)')
m = string(t.month,FORMAT='(I02)')
d = string(t.day,FORMAT='(I02)')

if n_elements(sat) eq 0 then sat = '17'
if ~isa(sat, 'STRING') then sat = asu_compstr(sat)

path = 'https://data.ngdc.noaa.gov/platforms/solar-space-observing-satellites/goes/goes'
base1m = path + sat + '/l2/data/xrsf-l2-avg1m_science'
file1m = 'sci_xrsf-l2-avg1m_g' + sat + '_d' + y + m + d + '_v2-1-0.nc'
path1m = base1m + '/' + y + '/' + m + '/' + file1m  

if n_elements(loc_dir) eq 0 then loc_dir = GETENV('IDL_TMPDIR')
if not file_test(loc_dir, /directory) then file_mkdir, loc_dir
 
aria2_urls_rand, path1m, loc_dir

return, loc_dir + path_sep() + file1m

end
