function asu_model_dipole_point, rx, ry, depth, mu

B = {X:0d, Y:0d, Z:0d}

rxy = sqrt(rx^2 + ry^2);
r = sqrt(rxy^2 + depth^2);
cost = depth/r;
sint = rxy/r;
B.Z = mu/r^3 * (3*cost^2 - 1);
if rxy ne 0 then begin
    Btr = mu/r^3 * (3*cost*sint);
    B.X = Btr * rx/rxy;
    B.Y = Btr * ry/rxy;
end

return, B

end
