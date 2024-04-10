%% FUNCTION DEFINITION
function [KC_og, KC_of, tg] = KC_SOLVER(tg, kc_in, preld_in, ld_in, tl_in, poi_in, N, T_custom)
%% KC_SOLVER.m
% Revision:     1.2
% Author:       Tyler A. Seawright
% Created:      10/24/23
% Last Updated: 4/3/24
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
[tg, kc_in, preld_in, ld_in, tl_in, poi_in, N, T_custom] = config();
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
    for i = 1:length(preld_in)
        for j = 1:3
            kc_in.Preld{j}.P = kc_in.Preld{1}.P;
        end
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

%% GEOMETRY TRANSFORMS
[kc_inT, tl_inT, T_GC] = KC_TRANSFORM_INPUTS(kc_in, tl_in);

% Print Transformed (DEBUG)
% kc_plot_input_geometry2(kc_in, tg, "KC INPUT CSYS");
% kc_plot_input_geometry2(kc_inT, tg, "KC SOLUTION CSYS");

% Rotate inputs back to input cys for verification.
T_GC_inv = inv(T_GC);
if(tg.solve_in_custom_csys)
    T_Q = T_GC_inv * T_custom;
elseif(tg.solve_in_input_csys)
    T_Q = T_GC_inv;
else
    T_Q = eye(4);
end

%% BLENDER VISUALIZATION
% Section removed since 3D visualization is now possible in MATLAB
% if (tg.visualize_in_blender)
%     write_to_blender(ball_positions, ball_diameters, plane_positions, plane_rotations, arrow_position, arrow_rotation, coord_sys_position, coord_sys_rotation, contact_force_magnitudes)
% end
%% SOLVE NOMINAL SYSTEM
% Solves nominal contact points
if (tg.solve_nominal)
    kc_nom = kc_inT;
    tl_nom = KC_TOL; % Set all tolerances to zero.
    kc_nom.Ld = KC_LOAD; % Set all loads to zero.
    kc_nom.Preld = KC_LOAD; % Set all preloads to zero.
    [kc_ng, kc_nf, T_ngf_GC_BC] = KC_COUPLING(tg, kc_nom, tl_nom, T_Q);
    % kc_ng.Pb, kc_ng.C
    % kc_nf.Pct, kc_nf.Pb, kc_nf.C, kc_nf.T_GC_BC 
    % kc_plot_input_geometry2(kc_nf, tg, "KC Free Body Diagram");
    KC_og = kc_ng; KC_of = kc_nf;
end
%% SOLVE SPECIFIC CASE
if (tg.solve_specific)
    % Solve specific case
    kc_s = kc_inT;
    [kc_sg, kc_sf, T_sgf_GC_BC] = KC_COUPLING(tg, kc_s, tl_in, T_Q);
    % kc_sg.Pb, kc_sg.C
    % kc_sf.Pb, kc_sf.C, kc_sf.RP, kc_sf.T_GC_BC, kc_sf.dPb
    
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
    % kc_plot_input_geometry2(kc_sf, tg, "KC Free Body Diagram");
    KC_og = kc_sg; KC_of = kc_sf;
end
%% MONTECARLO SIMULATION
if (tg.solve_montecarlo)
    % Solve Montecarlo
    kc_mc = kc_inT;
    for i = 1:N
    [kc_mg{i}, kc_mf{i}, T_sgf_GC_BC{i}] = KC_COUPLING(tg, kc_mc, tl_in, T_Q);
    end
    % Statistics

    KC_og = kc_mg; KC_of = kc_mf;
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
