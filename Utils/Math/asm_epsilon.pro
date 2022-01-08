function asm_epsilon

eps = 1.0d
eps1 = 1.5d

while eps1 gt 1d do begin
    eps /= 2d
    eps1 = eps + 1d
endwhile

return, eps

end
