function [kc_load, kc_preload, error_msg] = Force_Pos(kc, tl, tg)
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
Pb_slo = kc_ld_slo.Pb(1:3,1:3)./1000;
Pc_avg_slo = Pc_avg_slo./1000;
Pc_slo = kc_ld_slo.Pc(1:3,:)./1000;
Pc_2_Pb_slo = Pc_2_Pb_slo./1000;
FL_loc_slo = kc_ld_slo.Ld.P_loc./1000;
F_L_slo = kc_ld_slo.Ld.P;

if (tg.F_P_is_equal==0 || tg.F_P_is_equal==1)
    for j = 1:3
        F_P_slo(1:3,j) = kc_ld_slo.Preld{j}.P;
        F_P_loc_slo(1:3,j) = kc_ld_slo.Preld{j}.P_loc./1000;
    end
elseif(tg.F_P_is_equal==2)
    for j = 1:3
        F_P_slo(1:3,j) = kc_ld_slo.Preld{1}.P;
        F_P_loc_slo(1:3,j) = kc_ld_slo.Preld{1}.P_loc./1000;
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
[~, T_BC_F_slo, del_C_F, del_b_F] = kc_Ferr_rot2(Del_load_slo, kc_ld_slo.dc, kc_ld_slo.C, Pb_slo); % [mm]
[~, T_BC_F_preload_slo, del_C_preload_slo, del_b_preload_slo] = kc_Ferr_rot2(Del_preload_slo, kc_ld_slo.dc, kc_ld_slo.C, Pb_slo); % [mm]
if(tg.subtract_preload_deflection)
    del_C_load_slo = del_C_F - del_C_preload_slo; % [mm] Solve deflection from only applied load
    del_B_load_slo = del_b_F - del_b_preload_slo; % [mm]
    del_C_preload_slo = del_C_F; % [mm] 
    del_B_preload_slo = del_b_F; % [mm]
else
    del_C_load_slo = del_C_F; % [mm] Solve deflection from only applied load
    del_B_load_slo = del_b_F; % [mm]
    del_C_preload_slo = del_C_F;
    del_B_preload_slo = del_b_F; % [mm]
end
%% SOLVE COMBINED ERROR HTM'S
rest_err_load_slo = [T_BC_F_slo(3,2), T_BC_F_slo(1,3), T_BC_F_slo(2,1),T_BC_F_slo(1:3,4)']; % [urad,um] Rest err is extracted from T_GC_F HTM [a, B, g, x, y, z]
rest_err_preload_slo = [T_BC_F_preload_slo(3,2), T_BC_F_preload_slo(1,3), T_BC_F_preload_slo(2,1),T_BC_F_preload_slo(1:3,4)'];
% Rotate Coordinate System Slo to Sol
T_Sol_slo = inv(T_slo); 
T_BC_F_load = T_BC_F_slo * T_slo;
T_BC_F_preload = T_BC_F_preload_slo * T_slo;
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

% Currently unused, however coded if needed in future.
kc_preld_slo.Pb = kc_preld_slo.Pct(1:3,1:3) + del_B_preload_slo;
kc_preld_slo.Pc = kc_preld_slo.Pc;
kc_preld_slo.C = kc_preld_slo.C + rest_err_preload_slo(4:6)';
kc_preld_slo.RP = FBc_preload_slo;
kc_preld_slo.sigma = sig_load_slo;
kc_preld_slo.tau = sig_tau_load_slo;
kc_preld_slo.in_bd = Del_preload_slo;
kc_preld_slo.dPb = del_B_preload_slo;
kc_preld_slo.C_err = rest_err_preload_slo;
kc_preld_slo.T_GC_BC = T_BC_F_preload;
%% ROTATE KC SYSTEMS
kc_load = KC_TRANSFORM(kc_ld_slo, T_Sol_slo);
kc_preload = KC_TRANSFORM(kc_preld_slo, T_Sol_slo);
%% DEBUG PLOT
% kc_plot_FBD(kc_ld_slo, tg, "KC Free Body Diagram, SLO Csys");
% kc_plot_FBD(kc_load, tg, "KC Free Body Diagram, SOL Csys");
% kc_plot_FBD(kc, tg, "KC Free Body Diagram, INPUT Csys");

% Verify Sum of Forces
% F = kc_load.RP
% Fcomp = kc_load.RP'.*kc_load.dc
% sumF = sum(Fcomp,2)-(kc_load.Ld.P + kc_load.Preld{1}.P)
end