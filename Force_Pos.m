function [kc_ld, kc_preld, error_msg] = Force_Pos(kc, ld, preld, tl, tg)
%% INITIALIZE INPUTS
kc_ld = kc; 
error_msg = zeros(1,3); % Store booleans of three error cases, separation, yield stress, shear stress

% Organize Material Data
mat1 = kc.Mball; mat2 = kc.Mvee;
E = [0,0]; v = [0,0]; sig_yield = [0,0];
E(1) = mat1(1); E(2) = mat2(1); % [N / m^2] Mod of Elasticity
v(1) = mat1(5); v(2) = mat2(5); % Poisson Ratio
sig_yield(1) = mat1(3); sig_yield(2) = mat2(3); % [Pa] Yield Strength
tau_yield(1) = mat1(4); tau_yield(2) = mat2(4); % [Pa] Shear Strength

% Apply tolerances if solving montecarlo or specific case.
if (tg.solve_montecarlo)
   kc_ld.Ld.P = normrnd(kc_ld.Ld.P, tl.F_L'/3);
   kc_ld.Ld.P_loc = normrnd(kc_ld.Ld.P_loc, tl.FL_loc'/3);   
elseif (tg.solve_specific)
   kc_ld.Ld.P = kc_ld.Ld.P + tl.F_L';
   kc_ld.Ld.P_loc = kc_ld.Ld.P_loc + tl.FL_loc';   
else
   kc_ld.Ld.P = kc_ld.Ld.P;
   kc_ld.Ld.P_loc = kc_ld.Ld.P_loc;   
end
%% CALCULATE Pc_avg and Pc_2_Pb
% Calculate vector from ball contact to ball center and average between ball contact points
Pc_avg = zeros(3,3); Pc_2_Pb = zeros(3,6);
for i = 1:2:6 
    j = (i+1)/2; 
    Pc_2_Pb(1:3,i) = kc.Pb(1:3,j) - kc.Pc(1:3,i); % Vector from ball contact to ball center 1
    Pc_2_Pb(1:3,i+1) = kc.Pb(1:3,j) - kc.Pc(1:3,i+1); % Vector from ball contact to ball center 2
    Pc_avg(1:3,j) = (kc.Pc(1:3,i+1) + kc.Pc(1:3,i))/2; % Average between ball contact points
end
%% ROTATE DATA INPUT TO MATCH SLOCUM CSYS
% Rotate data to match Slocum solution form
rot_ang_slo = -vec_ang(kc.Pb(1:3,1), [0,1,0]'); % Angle between ball 1 and Y axis about Z axis
T_slo = Tform(rot_ang_slo,3); % Rotation matrix between ball 1 vector and Y axis about Z axis
% Data to rotate
Pb_slo = data_transform(T_slo, kc.Pb(1:3,1:3)')'./1000;
Pc_avg_slo = data_transform(T_slo, Pc_avg')'./1000;
Pc_slo = data_transform(T_slo, kc.Pc(1:3,:)')'./1000;
Pc_2_Pb_slo = data_transform(T_slo, Pc_2_Pb')'./1000;
FL_loc_slo = data_transform(T_slo, ld.P_loc')'./1000;
F_L_slo = data_transform(T_slo, ld.P')';

if (tg.F_P_is_equal==0 || tg.F_P_is_equal==1)
    for j = 1:3
        F_P_slo(1:3,j) = preld{j}.P;
    end
elseif(tg.F_P_is_equal==2)
    for j = 1:3
        F_P(1:3,j) = preld{1}.P;
        F_P_loc(1:3,j) = preld{1}.P_loc./1000;
    end
    F_P_slo = data_transform(T_slo, F_P')';
    F_P_loc_slo = data_transform(T_slo, F_P_loc')';
end

C_slo = data_transform(T_slo, kc.C')'./1000;

%% SOLVE FORCE AT EACH BALL CONTACT (SI UNITS)
if(tg.F_P_is_equal==0 || tg.F_P_is_equal==1) % If 3 preloads are applied at balls
    [dc_slo, FBc_slo, clamp_separated] = ClampContactForce(Pc_slo(1:3,1:6)', Pc_2_Pb_slo', Pc_avg_slo, F_P_slo', F_L_slo', FL_loc_slo'); % Solve with preload and applied load
    [~, FBc_preload_slo, ~] =        ClampContactForce(Pc_slo(1:3,1:6)', Pc_2_Pb_slo', Pc_avg_slo, F_P_slo', zeros(1,3)', zeros(1,3)'); % Solve with only preload
    % dc_slo(3,:) = -dc_slo(3,:);
elseif (tg.F_P_is_equal==2) % If a single preload is applied to plate same as applied load
    [dc_slo, FBc_slo, clamp_separated] = ClampContactForce(Pc_slo(1:3,1:6)', Pc_2_Pb_slo', Pc_avg_slo, zeros(3), F_L_slo', FL_loc_slo'); % Solve with preload and applied load
    [~, FBc_preload_slo, ~] =        ClampContactForce(Pc_slo(1:3,1:6)', Pc_2_Pb_slo', Pc_avg_slo, zeros(3), F_P_slo(1:3,1)', F_P_loc_slo(1:3,1)'); % Solve with only preload
    % dc_slo(3,:) = -dc_slo(3,:);
    FBc_slo = FBc_slo + FBc_preload_slo; % Superposition combines reaction forces at the same points.
end
% FBc_slo,FBc_preload_slo
% Error Handling
if(clamp_separated) % Display error if nominal clamp separates
    error_msg(1) = 1;
    kc_ld.clamp_separation = 1;
    return
end
%% SOLVE CONTACT STRESSES AND DEFLECTIONS
[sig_load_slo,~,~,in_ball_disp_load, sig_tau_load_slo,Del_load_slo,~] = ContactStressElliptical2(min(sig_yield), dc_slo, [1,1].*([kc.Db(1), 2* kc.Rb2(1)] /(2* 1000)), kc.DV(1:2), E, v, FBc_slo, 0);
[sig_preload_slo,~,~,in_ball_disp_preload, sig_tau_preload_slo,Del_preload_slo,~] = ContactStressElliptical2(min(sig_yield), dc_slo, [1,1].*([kc.Db(1), 2* kc.Rb2(1)] /(2*1000)), kc.DV(1:2), E, v, FBc_preload_slo, 0);
Del_load_slo = Del_load_slo' * 1000; % Convert to mm and transpose
Del_preload_slo = Del_preload_slo' * 1000; % Convert units to mm and transpose

%% CHECK MATERIAL SAFETY FACTOR
% Check if contacts exceed yield stress
sy_clamp_sf = zeros(6,1);
st_clamp_sf = zeros(6,1);

for i = 1:6
    sy_clamp_sf(i) = kc.sigma(i)/sig_load_slo(i);
    st_clamp_sf(i) = kc.tau(i)/sig_tau_load_slo(i);
end

% ERROR HANDLING
% Check if contacts exceed compression stress limit
if(any(kc.sig_y_SF <= sy_clamp_sf)) 
    error_msg(2) = 1;
    return
end
% Check if contacts exceed shear stress limit
if(any(kc.sig_tau_SF <= st_clamp_sf))
    error_msg(3) = 1;
    return
end
%% SOLVE CLAMP ERROR POSITION AND ROTATION
[~, T_BC_F_slo, del_C_F, del_b_F] = kc_Ferr_rot2(Del_load_slo, dc_slo, C_slo, Pb_slo); % [mm]
if(tg.subtract_preload_deflection)
    [~, T_BC_F_preload_slo, del_C_preload_slo, del_b_preload_slo] = kc_Ferr_rot2(Del_preload_slo, dc_slo, C_slo, Pb_slo); % [mm]
    del_C_load_slo = del_C_F - del_C_preload_slo; % [mm] Solve deflection from only applied load
    del_B_load_slo = del_b_F - del_b_preload_slo; % [mm]

    del_C_preload_slo = del_C_F; % [mm] 
    del_B_preload_slo = del_b_F; % [mm]
   
end
%% ROTATE OUTPUTS TO SOLUTION CSYS
% Load Variables
T_GC_SLO = inv(T_slo);
T_GC_SLO_ROT = eye(4); T_GC_SLO_ROT(1:3,1:3) = T_GC_SLO(1:3,1:3);
Del_load = Del_load_slo; % Magnitude normal to vee plane, no rotation
FBc = FBc_slo; % Magnitude normal to vee plane, no rotation
del_B_load = data_transform(T_GC_SLO, del_B_load_slo')';
dc = data_transform(T_GC_SLO_ROT, dc_slo')'; % Rotation Only
T_GC_BC_ld = T_BC_F_slo;
% Preload Variables
T_GC_pre_SLO = inv(T_slo);
T_GC_pre_SLO_ROT = eye(4); T_GC_pre_SLO_ROT(1:3,1:3) = T_GC_pre_SLO(1:3,1:3);
Del_preload = Del_preload_slo; % Magnitude normal to vee plane, no rotation
FBc_preload = FBc_preload_slo; % Magnitude normal to vee plane, no rotation
del_B_preload = data_transform(T_GC_pre_SLO, del_B_preload_slo')';
del_C_preload = data_transform(T_GC_pre_SLO, del_C_preload_slo);
T_GC_BC_preld = T_BC_F_preload_slo;

T_BC_F = T_BC_F_slo;
%% SOLVE COMBINED ERROR HTM'S
rest_err_load = [T_BC_F(3,2), T_BC_F(1,3), T_BC_F(2,1),T_BC_F(1:3,4)']*1000; % [urad,um] Rest err is extracted from T_GC_F HTM [a, B, g, x, y, z]
del_C_load = T_BC_F(1:3,4);
%% KC SYSTEMS

kc_ld.Pb = kc.Pb(1:3,1:3) + del_B_load;
kc_ld.Pc = kc.Pc;
kc_ld.C = kc.C + del_C_load;
kc_ld.RP = FBc;
kc_ld.sigma = sig_load_slo;
kc_ld.tau = sig_tau_load_slo;
kc_ld.in_bd = in_ball_disp_load;
kc_ld.dPb = del_B_load;
kc_ld.dc = dc;
kc_ld.C_err = rest_err_load;
kc_ld.T_GC_BC = T_GC_BC_ld;

kc_preld.Pb = kc.Pb(1:3,1:3) + del_B_preload;
kc_preld.Pc = kc.Pc;
kc_preld.RP = FBc;
kc_preld.sigma = sig_load_slo;
kc_preld.tau = sig_tau_load_slo;
kc_preld.in_bd = in_ball_disp_load;
kc_preld.dPb = del_B_load;
kc_preld.dc = dc;
kc_preld.C = kc.C + del_C_preload;
kc_preld.C_err = rest_err_load;
kc_preld.T_GC_BC = T_GC_BC_preld;
end