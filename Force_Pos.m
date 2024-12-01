function [kc_load, error_msg] = Force_Pos(kc, tg)
%% INITIALIZE INPUTS
kc_ld = kc; 
error_msg = zeros(1,3); % Store booleans of three error cases, separation, yield stress, shear stress

% Organize Material Data
E = [0,0]; v = [0,0]; sig_yield = [0,0];
E(1) = kc.Mball.mod_of_elasticity; E(2) = kc.Mvee.mod_of_elasticity; % [N / m^2] Mod of Elasticity
v(1) = kc.Mball.poisson_ratio; v(2) = kc.Mvee.poisson_ratio; % Poisson Ratio
sig_yield(1) = kc.Mball.yield_strength; sig_yield(2) = kc.Mvee.yield_strength; % [Pa] Yield Strength
tau_yield(1) = kc.Mball.shear_strength; tau_yield(2) = kc.Mvee.shear_strength; % [Pa] Shear Strength
%% ROTATE KC TO SLOCUM CSYS
% Rotate data to match Slocum solution form
rot_ang_slo = -vec_ang(kc_ld.Pb(1:3,1), [0,1,0]'); % Angle between ball 1 and Y axis about Z axis
T_slo = Tform(rot_ang_slo,3); % Rotation matrix between ball 1 vector and Y axis about Z axis

% Solve Transformed KC_SLO
kc_ld_slo = KC_TRANSFORM(kc_ld, T_slo);
kc_preld_slo = kc_ld_slo;
% Calculate vector from ball contact to ball center and average between ball contact points
Pc_avg_slo = zeros(3,3); Pc_2_Pb_slo = zeros(3,6);
for i = 1:2:6 
    j = (i+1)/2; 
    Pc_2_Pb_slo(1:3,i) = kc_ld_slo.Pb(1:3,j) - kc_ld_slo.Pc(1:3,i); % Vector from ball contact to ball center 1
    Pc_2_Pb_slo(1:3,i+1) = kc_ld_slo.Pb(1:3,j) - kc_ld_slo.Pc(1:3,i+1); % Vector from ball contact to ball center 2
    Pc_avg_slo(1:3,j) = (kc_ld_slo.Pc(1:3,i+1) + kc_ld_slo.Pc(1:3,i))/2; % Average between ball contact points
end
%% OPRGANIZE DATA AND SET UNITS
% Data to rotate
Pb_slo = kc_ld_slo.Pb(1:3,1:3)./1000; % [m]
Pc_avg_slo = Pc_avg_slo./1000; % [m]
Pc_slo = kc_ld_slo.Pc(1:3,:)./1000; % [m]
Pc_2_Pb_slo = Pc_2_Pb_slo./1000; % [m]
FL_loc_slo = kc_ld_slo.Ld.P_loc./1000; % [m]
F_L_slo = kc_ld_slo.Ld.P;

if (tg.F_P_is_equal==0 || tg.F_P_is_equal==1)
    for j = 1:3
        F_P_slo(1:3,j) = kc_ld_slo.Preld{j}.P;
        F_P_loc_slo(1:3,j) = kc_ld_slo.Preld{j}.P_loc./1000;  % [m]
    end
elseif(tg.F_P_is_equal==2)
    for j = 1:3
        F_P_slo(1:3,j) = kc_ld_slo.Preld{1}.P;
        F_P_loc_slo(1:3,j) = kc_ld_slo.Preld{1}.P_loc./1000;  % [m]
    end
end

%% SOLVE FORCE AT EACH BALL CONTACT (SI UNITS)
if(tg.F_P_is_equal==0 || tg.F_P_is_equal==1) % If 3 preloads are applied at balls
    [FBc_slo, clamp_separated] =  ClampContactForce(kc_ld_slo.dc, Pc_slo(1:3,1:6)', Pc_2_Pb_slo', Pc_avg_slo, F_P_slo', F_L_slo', FL_loc_slo'); % Solve with preload and applied load
    [FBc_preload_slo, ~] =        ClampContactForce(kc_ld_slo.dc, Pc_slo(1:3,1:6)', Pc_2_Pb_slo', Pc_avg_slo, F_P_slo', zeros(1,3)', zeros(1,3)'); % Solve with only preload
elseif (tg.F_P_is_equal==2) % If a single preload is applied to plate same as applied load
    [FBc_slo, clamp_separated] =  ClampContactForce(kc_ld_slo.dc, Pc_slo(1:3,1:6)', Pc_2_Pb_slo', Pc_avg_slo, zeros(3), F_L_slo', FL_loc_slo'); % Solve with preload and applied load
    [FBc_preload_slo, ~] =        ClampContactForce(kc_ld_slo.dc, Pc_slo(1:3,1:6)', Pc_2_Pb_slo', Pc_avg_slo, zeros(3), F_P_slo(1:3,1)', F_P_loc_slo(1:3,1)'); % Solve with only preload
    FBc_slo = FBc_slo + FBc_preload_slo; % Superposition combines reaction forces at the same points.
end

%% ERROR HANDLING
if(clamp_separated) % Display error if nominal clamp separates
    error_msg(1) = 1;
    kc_ld_slo.clamp_separation = 1;
    return
end
%% SOLVE CONTACT STRESSES AND DEFLECTIONS
[sig_load_slo,~,~,~, sig_tau_load_slo,Del_load_slo,~] = ContactStressElliptical2(min(sig_yield), kc_ld_slo.dc, [1,1].*([kc.Db(1), 2* kc.Rb2(1)] /(2* 1000)), kc.DV(1:2), E, v, FBc_slo, 0);
[~,~,~,~,~,Del_preload_slo,~] =                         ContactStressElliptical2(min(sig_yield), kc_ld_slo.dc, [1,1].*([kc.Db(1), 2* kc.Rb2(1)] /(2*1000)), kc.DV(1:2), E, v, FBc_preload_slo, 0);
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
[~, T_BC_F_slo, ~, del_b_F] = kc_Ferr_rot2(Del_load_slo, kc_ld_slo.dc, kc_ld_slo.C, Pb_slo); % [mm]
[~, ~, ~, del_b_preload_slo] = kc_Ferr_rot2(Del_preload_slo, kc_ld_slo.dc, kc_ld_slo.C, Pb_slo); % [mm]
if(tg.subtract_preload_deflection)
    del_B_load_slo = del_b_F - del_b_preload_slo; % [mm]
else
    del_B_load_slo = del_b_F; % [mm]
end
%% SOLVE COMBINED ERROR HTM'S
rest_err_load_slo = [T_BC_F_slo(3,2), T_BC_F_slo(1,3), T_BC_F_slo(2,1),T_BC_F_slo(1:3,4)']; % [urad,um] Rest err is extracted from T_GC_F HTM [a, B, g, x, y, z]
% Rotate Coordinate System Slo to Sol
T_Sol_slo = inv(T_slo); 
T_BC_F_load = T_BC_F_slo * T_slo;
%% DEFINE KC SYSTEMS
kc_ld_slo.Pb = kc_ld_slo.Pct(1:3,1:3) + del_B_load_slo;
kc_ld_slo.Pc = kc_ld_slo.Pc;
kc_ld_slo.C = kc_ld_slo.C + rest_err_load_slo(4:6)';
kc_ld_slo.RP = FBc_slo;
kc_ld_slo.sigma = sig_load_slo;
kc_ld_slo.tau = sig_tau_load_slo;
kc_ld_slo.in_bd = Del_load_slo;
kc_ld_slo.dPb = del_B_load_slo;
kc_ld_slo.C_err = rest_err_load_slo;
kc_ld_slo.T_GC_BC = T_BC_F_load;
kc_ld_slo.stiffness = norm(F_L_slo)./(1000*rest_err_load_slo);
%% ROTATE KC SYSTEMS
kc_load = KC_TRANSFORM(kc_ld_slo, T_Sol_slo);
%% Verify Sum of Forces
% F = kc_load.RP
% Fcomp = kc_load.RP'.*kc_load.dc
% sumF = sum(Fcomp,2)-(kc_load.Ld.P + kc_load.Preld{1}.P)
end