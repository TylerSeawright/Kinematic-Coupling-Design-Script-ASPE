% KC_TRANSFORM_INPUTS.m
% This function transforms the inputs to new Csys from HTM T. 

function [kc_B, tl_B, T_A_B] = KC_TRANSFORM_INPUTS(kc_A, tl_A)

% Initialize new systems
kc_B = kc_A; tl_B = tl_A;

% Solve transformation from arbitrary positions to solution space. All
% balls on XY plane, third ball on x axis, coupling centroid at origin.
% orientTriangle(Ball Centers, triangle incenter)
T_A_B = orientTriangle(kc_A.Pct, kc_A.C);

% Apply transformation.
kc_B.Pct = data_transform(T_A_B, kc_A.Pct')';
kc_B.Ld.P_loc = data_transform(T_A_B, kc_A.Ld.P_loc')';
kc_B.Ld.P = data_transform(Tform(T_A_B(1:3,4),0),kc_A.Ld.P')';
for j = 1:3
    kc_B.Preld{j}.P_loc = data_transform(T_A_B, kc_A.Preld{j}.P_loc')';
    kc_B.Preld{j}.P = data_transform(Tform(T_A_B(1:3,4),0),kc_A.Preld{j}.P')';
end
tl_B.FL_loc = data_transform(T_A_B, tl_A.FL_loc);
tl_B.F_L = data_transform(Tform(T_A_B(1:3,4),0),tl_A.F_L);
tl_B.B_tol = data_transform(T_A_B, tl_A.B_tol);
tl_B.V_tol = data_transform(T_A_B, tl_A.V_tol);

kc_B.C = incenter_solve(kc_B.Pct);

% Orientation defines the ball coordinate system orientation about Z axis on XY plane such that X
% axis points towards coupling centroid.
for i = 1:3
    kc_B.or(i) = atan2(kc_B.C(2) - kc_B.Pct(2,i), kc_B.C(1) - kc_B.Pct(1,i));
    if kc_B.or(i) < 0 % If orientation angle is negative, change to positive angle
        kc_B.or(i) = kc_B.or(i) + 2*pi; % Return negative angle as positive [0,2pi]
    end
end

kc_B.T_Vees = vee_plane_transform(kc_B.Pct, kc_B.Db, kc_B.Vg/2, kc_B.or, kc_B.Vreo);

end