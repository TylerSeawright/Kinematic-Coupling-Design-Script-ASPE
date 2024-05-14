%% FUNCTION DEFINITION
function [KC_og, KC_of, T_ogf_GC_BC, tg] = KC_SOLVER(tg, kc_in, preld_in, ld_in, tl_in, poi_in, N, T_custom)
%% KC_SOLVER.m
% Revision:     1.2
% Author:       Tyler A. Seawright
% Created:      10/24/23
% Last Updated: 5/4/24
%% AUTHOR'S NOTE
% This script was created through the work of Dr. Alexander Slocum, Michel
% Pharand, and Tyler Seawright. With this script, 2D and 3D kinematic
% couplings consisting of three balls and three vees may be solved. Use to
% determine contact points, contact forces, contact stresses, deformations, and run sensitivity analyses. 
% 
% Edit the config file to change the input parameters. Some features are
% not supported and those are listed. 
%% CLEANUP
% clc, clear, close all

% Timing
% tic
%% INPUTS
% Get all inputs from config file. Edit config file.
[tg, kc_in, tl_in, poi_in, N, T_custom] = config();
%% BALL CENTER INPUT VERIFICATION
% Verify ball centers forms a triangle. If a ball falls on the line formed
% by the two other balls then end script.
if(~verify_tri(kc_in.Pct))
    error("Invalid Ball Centers. Ball centers must form a triangle.")
    return
end
%% INIT

% Set all preload forces to equal vectors if toggled.
if(tg.F_P_is_equal==1)
    for j = 1:3
        kc_in.Preld{j}.P = kc_in.Preld{1}.P;
    end
end
if (tg.FL_is_Coupling_Centroid)
   kc_in.Ld.P_loc = kc_in.C;
end
if (~tg.canoe_ball) % If canoe ball is not used, set ball R2 to ball R1
   kc_in.Rb2 = kc_in.Db/2;
end

%% PRE-RUN PRINTS
% - Verification of Inputs (DEBUG)
% kc_in.Pct; kc_in.C;
%% INPUT VERIFICATION DIALOGUE BOX
% Ask the user whether to continue or not using the dialog box
if (tg.verify_inputs)
    if verify_to_continue_dialog()
        % The user chose to continue, proceed with the script
        % disp('Continuing with the script...');
        % rest of your script here
    else
        % The user chose to terminate, exit the script
        disp('Terminating the script.');
        return; % Exit the function or script
    end
end

% %% GEOMETRY TRANSFORMS
% % Solve basic Triangle Geometry
% T_GC = orientTriangle(kc_in.Pct, kc_in.C);
% tl_inT = tl_in;
% [kc_inT] = KC_TRANSFORM(kc_in, T_GC);
% % 
% %% PREPARE INPUTS
% 
% 
% % Orientation defines the ball coordinate system orientation about Z axis on XY plane such that X
% % axis points towards coupling centroid.
% for i = 1:3
%     kc_inT.or(i) = atan2(kc_inT.C(2) - kc_inT.Pct(2,i), kc_inT.C(1) - kc_inT.Pct(1,i));
%     if kc_inT.or(i) < 0 % If orientation angle is negative, change to positive angle
%         kc_inT.or(i) = kc_inT.or(i) + 2*pi; % Return negative angle as positive [0,2pi]
%     end
% end
% 
% kc_inT.T_Vees = vee_plane_transform(kc_inT.Pct, kc_inT.Db, kc_inT.Vg/2, kc_inT.or, kc_inT.Vreo);
% kc_inT.C = incenter_solve(kc_in.Pb);
%% GEOMETRY TRANSFORMS
% Transform input KC to place C at origin.
kc_in = KC_TRANSFORM(kc_in, Tform(-kc_in.C,0));
% Transform KC to rotate to XY plane.
[kc_inT, tl_inT, T_GC] = KC_TRANSFORM_INPUTS(kc_in, tl_in);
% Rotate inputs back to input cys for verification.
T_GC_inv = inv(T_GC);
if(tg.solve_in_custom_csys)
    T_Q = T_GC_inv * T_custom;
elseif(tg.solve_in_input_csys)
    T_Q = T_GC_inv;
else
    T_Q = eye(4);
end
% 

%% SOLVE NOMINAL SYSTEM
% Solves nominal contact points
if (tg.solve_nominal)
    kc_nom = kc_inT;
    tl_nom = KC_TOL; % Set all tolerances to zero.
    kc_nom.Ld = KC_LOAD; % Set all loads to zero.
    kc_nom.Preld = {KC_LOAD, KC_LOAD,KC_LOAD}; % Set all preloads to zero.
    [kc_ng, kc_nf, T_ngf_GC_BC] = KC_COUPLING(tg, kc_nom, tl_nom, T_Q);
    KC_og = kc_ng; KC_of = kc_nf; T_ogf_GC_BC = T_ngf_GC_BC;
end
%% SOLVE SPECIFIC CASE
if (tg.solve_specific)
    % Solve specific case
    kc_s = kc_inT;
    [kc_sg, kc_sf, T_sgf_GC_BC] = KC_COUPLING(tg, kc_s, tl_inT, T_Q);
    
    % % Vertical KC Experiment Verification ..................
    % C = kc_sf.C
    % RP = kc_sf.RP' % Reaction Forces
    % dPb = 1000* kc_sf.dPb %[um]
    % T_exp = Tform(-pi/2,1)*Tform(-pi/2,3); % Experiment Csys
    % T1_exp = T_exp * Tform(pi/2,3); % Sensor 1 Csys
    % T2_exp = T_exp * Tform(-pi/2,3); % Sensor 2 Csys
    % dPbe(:,1) = data_transform(T1_exp, dPb(:,1)')'; % dPb 1
    % dPbe(:,2) = data_transform(T2_exp, dPb(:,2)')'; % dPb 2
    % dPbe(:,3) = data_transform(T_exp, dPb(:,3)')'; % dPb 3
    % % Theoretical Sensor Values
    % Se(1) = dPbe(2,1); Se(2) = dPbe(3,1);
    % Se(3) = dPbe(3,2); Se(4) = dPbe(2,2);
    % Se(5) = dPbe(2,3); sens_val_vert_kc = Se
    % % Contact Force components
    % for i = 1:6
    %     force_comp(1:3,i) = kc_sf.dc(1:3,i) * -kc_sf.RP(i);
    % end
    % contact_force_vert_kc = force_comp
    % ......................................................

    % Plot Geometry
    KC_og = kc_sg; KC_of = kc_sf; T_ogf_GC_BC = T_sgf_GC_BC;
end
%% MONTECARLO SIMULATION
if (tg.solve_montecarlo)
    % Solve Montecarlo
    kc_mc = kc_inT;
    for i = 1:N
    [kc_mg{i}, kc_mf{i}, T_mgf_GC_BC{i}] = KC_COUPLING(tg, kc_mc, tl_inT, T_Q);
    end
    % Statistics

    KC_og = kc_mg; KC_of = kc_mf; T_ogf_GC_BC = T_mgf_GC_BC;
end
%% COVARIANCE ERROR SIMULATION
% Currently unsupported
if (tg.solve_covariance)
    % Solve Covariance
end
%% OPTIMIZATION PROBLEMS
% (Recommend remove for use outside of KC_SOLVER function). TS 4/9/23
% Solve Force Position Boundary that Causes Coupling Separation
if (tg.solve_force_location_boundary)
    % Define Optimization KC System
    kc_fl_opt = kc_inT; kc_fl_opt.Ld.P_loc = kc_fl_opt.C;
    tg_fl_opt = tg;
    tl_fl_opt = KC_TOL;

    % Using Polar Coords. Scan from coupling centroid
    R_step = 100;
    Theta_step = 36;
    refine_fac = 1; step_size = [R_step, Theta_step];
    % Using R-Theta
    R = norm([kc_fl_opt.Pct(1,:), kc_fl_opt.Pct(2,:)]);
    boundaryPoints = findBoundary2(R, step_size, tg_fl_opt, kc_fl_opt, tl_fl_opt, T_Q);

    kc_plot_input_geometry2(kc_fl_opt, tg, "KC FORCE BOUNDARY");
end
%% PRINT AND PLOT RESULTS
%% SAVE INPUT/RESULTS
%% COMPLETION
% Timing
% if (tg.time_script)
%     script_run_time = toc;
% end
% disp("Program Ran Successfully")
%% FUNCTION CLOSE
end
