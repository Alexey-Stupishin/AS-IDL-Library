function asm_bezier_normalize, solution, tlims

alpha = tlims[1] - tlims[0]
bta = tlims[0]

N = [[1,   bta,       bta^2,         bta^3] $
   , [0, alpha, 2*alpha*bta, 3*alpha*bta^2] $
   , [0,     0,     alpha^2, 3*alpha^2*bta] $
   , [0,     0,           0,       alpha^3] $
   ]
   
x = N ## solution[0:3]   
y = N ## solution[4:7]

return, {x_poly:transpose(x, [1, 0]), y_poly:transpose(y, [1, 0])}  

end
