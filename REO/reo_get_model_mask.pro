function reo_get_model_mask, ptr, Bph, baseIC, outIC, cont = cont, cmask = cmask

vBph = Bph
rc = reo_get_markup_scalar(ptr, baseIC, cont, cmask)
idx = where(cmask eq 0, count)
if count gt 0 then begin
    vBph[idx] = 10; conditional QS Bph
    cont[idx] = max(cont); conditional QS cont
endif
model_mask = decompose(vBph, cont); see Fontenla 2009. e.g. 7 - umbra, 6 - penumbra etc.

return, model_mask

end
