% TOL_TRANSFORM.m
% This function transforms the input tolerances by HTM T. 
function tlo = TOL_TRANSFORM(tli, T)
    
    tlo = tli;

    Tr = [T(1:3,1:3), [0,0,0]';[0,0,0,1]];

    tlo.FL_loc = data_transform(T, tli.FL_loc);
    tlo.F_L = data_transform(Tr,tli.F_L);
    tlo.B_tol = data_transform(T, tli.B_tol);
    tlo.V_tol = data_transform(T, tli.V_tol);

end