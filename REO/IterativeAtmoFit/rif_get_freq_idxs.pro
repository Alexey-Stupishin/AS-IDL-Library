function rif_get_freq_idxs, freqR, freqL, idxR, idxL

freqs = asu_nearly_uniq([freqR, freqL])
idxR = asu_nearly_member_idx(freqR, freqs)
idxL = asu_nearly_member_idx(freqL, freqs)

return, freqs

end
