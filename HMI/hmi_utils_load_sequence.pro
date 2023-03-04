function hmi_utils_load_sequence, t1, t2, reportfile, dataset, segment

ssw_jsoc_time2data, anytim(t1), anytim(t2), index, urls, /urls_only, ds = dataset, segment = segment, count = count

end
