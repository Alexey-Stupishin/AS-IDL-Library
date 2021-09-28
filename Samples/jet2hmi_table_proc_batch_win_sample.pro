pro jet2hmi_table_proc_batch_win_sample

;config_path = 'g:\BIGData\UData\Jets\HMI\Take_2_full\hmi_conf'
;jets_path = 'g:\BIGData\UData\Jets\HMI\Take_1\jets4hmi'
;data_path = 'g:\BIGData\UData\Jets\HMI\Take_2_full\hmi_data'
;sav_file = 's:\University\Work\Jets\Jets+HMI\v2_full\table4hmi_full.sav'

config_path = 'g:\BIGData\UData\Jets\HMI\Take_20150918'
jets_path = 'g:\BIGData\UData\Jets\HMI\Take_20150918'
data_path = 'g:\BIGData\UData\Jets\HMI\Take_20150918\hmi_data'
sav_file = 'g:\BIGData\UData\Jets\HMI\Take_20150918\table4hmi_full.sav'

wavelng = '171'

res = jet2hmi_table_proc_batch(config_path = config_path, wavelng, jets_path, data_path)

openw, U, 's:\University\Work\Jets\Jets+HMI\v2_full\table4hmi_full.csv', /GET_LUN
printf, U, 'ID', 'N det', 'T max', 'Max. cardinality', 'X from', 'X to', 'Y from', 'Y to', 'Bmax', $
     FORMAT = '(%"%s, %s, %s, %s, %s, %s, %s, %s, %s")'

outlist = list()

for occ = 0, res.Count()-1 do begin
    rocc = res[occ]
    detail = rocc.res
    
    seq = intarr(detail.Count())
    for det = 0, detail.Count()-1 do begin
        content = detail[det]
        seq[content.config.ndet-1] = det
    endfor
    
    for detseq = 0, n_elements(seq)-1 do begin
        content = detail[seq[detseq]]
        hdr = ''
        if detseq eq 0 then hdr = content.id
        
        xf = dblarr(2)
        yf = dblarr(2)
        x_fov = content.config.x_fov
        xf[0] = x_fov[0]
        xf[1] = x_fov[1]
        y_fov = content.config.y_fov
        yf[0] = y_fov[0]
        yf[1] = y_fov[1]

        x = content.csvinfo.x
        y = content.csvinfo.y
        printf, U, hdr, content.config.ndet, content.csvinfo.tmax, content.csvinfo.maxcard, x[0], x[1], y[0], y[1], fix(content.config.Bmax) $
              , FORMAT = '(%"%s, %d, %s, %d, %d, %d, %d, %d, %d")'
              
        outlist.Add, {id:content.id, ndet:content.config.ndet, tmax:content.csvinfo.tmax, x:xf, y:yf, csvfile:rocc.csvfile, savfile:rocc.savfile, wavelng:wavelng}      
    endfor
endfor 

s = outlist[0]
soutlist = replicate(s, outlist.Count())
for i = 0, outlist.Count()-1 do begin
    soutlist[i] = outlist[i]
endfor

save, filename = sav_file, soutlist

close, U
FREE_LUN, U

end
