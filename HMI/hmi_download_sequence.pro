pro hmi_download_sequence, tstart, tstop, x, y, cadence, outdir, no_tracking = no_tracking

if n_elements(no_tracking) eq 0 then no_tracking = 0

xc = fix((x[1]+x[0])/2d)
yc = fix((y[1]+y[0])/2d)
wpix = fix((x[1]-x[0])/0.6d)
hpix = fix((y[1]-y[0])/0.6d)

config = {cadence:'', tstart:tstart, tstop:tstop, tref:tstart $
        , xc:asu_compstr(xc), yc:asu_compstr(yc), wpix:asu_compstr(wpix), hpix:asu_compstr(hpix)}

downloaded = hmi_utils_download_cutout(cadence, outdir, config, no_tracking = no_tracking) 

end
