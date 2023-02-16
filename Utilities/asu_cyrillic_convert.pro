pro asu_cyrillic_init
compile_opt idl2

common G_ASU_CYRILLIC, cyr_table

cyr_table = bytarr(256)
for k = 'E0'XB, 'F9'XB do begin 
    cyr_table[k] = k - '7F'XB
end
cyr_table['FA'XB] = '3C'XB
cyr_table['FB'XB] = '3E'XB
cyr_table['FC'XB] = '40'XB
cyr_table['FD'XB] = '5C'XB
cyr_table['FE'XB] = '5E'XB
cyr_table['FF'XB] = '3B'XB

for k = 'C0'XB, 'D9'XB do begin 
    cyr_table[k] = k - '7F'XB
end
cyr_table['DA'XB] = '23'XB
cyr_table['DB'XB] = '5B'XB
cyr_table['DC'XB] = '5D'XB
cyr_table['DD'XB] = '25'XB
cyr_table['DE'XB] = '22'XB
cyr_table['DF'XB] = '5F'XB

end

function asu_cyrillic_convert1, b
compile_opt idl2

common G_ASU_CYRILLIC, cyr_table

c = b
if cyr_table[b] ne 0 then c = cyr_table[b]

return, string(c)

end

function asu_cyrillic_convert, str
compile_opt idl2

res = string('!16')
b = byte(str)
for k = 0, n_elements(b)-1 do begin
    s = asu_cyrillic_convert1(b[k])
    res += s
endfor

res += string('!3')

return, res

end

function asu_lang_convert, iscyr, cyr, lat

if ~iscyr then return, lat

return, asu_cyrillic_convert(cyr)

end
