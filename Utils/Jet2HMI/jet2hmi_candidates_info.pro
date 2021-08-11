pro jet2hmi_candidates_info, fncsv

; fncsv = 'g:\BIGData\UData\Jets\HMI\Take_1\jets4hmi\20100916_235930_20100917_005930_57_-511_500_500\objects_m2\171.csv'    
res = read_ascii(fncsv, template = jet2hmi_load_csv_template(), data_start = 1, header = header, count = count)

info = replicate({tstart:'', tmax:'', tend:'', maxcard:0L, jet_aspect:0d, max_aspect:0d, l2w_aspect:0d, speed:0d, length:0d, width:0d, x:[0, 0], y:[0, 0]}, count)

for i = 0, count-1 do begin
    info[i].tstart = res.tstart[i]
    info[i].tmax = res.tmax[i]
    info[i].tend = res.tend[i]
    info[i].N = res.N[i]
    info[i].duration = res.duration[i]
    info[i].maxcard = res.maxcard[i]
    info[i].jet_aspect = res.jet_aspect[i]
    info[i].max_aspect = res.max_aspect[i]
    info[i].l2w_aspect = res.l2w_aspect[i]
    info[i].speed = res.speed[i]
    info[i].length = res.length[i]
    info[i].width = res.width[i]
    info[i].x = [res.xfrom[i], res.xto[i]]
    info[i].y = [res.yfrom[i], res.yto[i]]
endfor

end

