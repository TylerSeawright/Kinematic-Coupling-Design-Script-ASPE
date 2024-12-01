%% FUNCTION DEFINITION
function [kc_tot] = KC_SOLVER(tg, kc_in)
%% KC_SOLVER.m
% Revision:     1.3
% Author:       Tyler A. Seawright
% Created:      10/24/23
% Last Updated: 11/9/24
%% AUTHOR'S NOTE
% This script was created by Tyler Seawright through the work of Dr. Alexander Slocum, Michel
% Pharand, and Tyler Seawright. With this script, 2D and 3D kinematic
% couplings consisting of three balls and three vees may be solved. Use to
% determine contact points, contact forces, contact stresses, deformations, and run sensitivity analyses. 
% 
% Edit the config file to change the input parameters. Some features are
% not supported and are listed. 
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
% Transform KC by custom input coordinate system (See Optional Rotation of
% KC from Input Csys in Config File)
kc_in = KC_TRANSFORM(kc_in, kc_in.T_input);

% Transform input KC to place C at origin.
T_in_origin = Tform(-kc_in.C,0);
kc_in = KC_TRANSFORM(kc_in, T_in_origin);

% Transform KC to rotate to XY plane.
[kc_inT, tl_inT, T_GC] = KC_TRANSFORM_INPUTS(kc_in, kc_in.tl);
% Rotate inputs back to input cys for verification.
T_GC_inv = inv(T_GC);
if(tg.solve_in_input_csys)
    T_Q = T_GC_inv;
else
    T_Q = eye(4);
end
kc_inT.T_input = eye(4);%T_Q;

%% SOLVE NOMINAL SYSTEM
% Solves nominal contact points
if (tg.solve_nominal)
    kc_nom = kc_inT;
    tl_nom = KC_TOL; % Set all tolerances to zero.
    kc_nom.Ld = KC_LOAD; % Set all loads to zero.
    kc_nom.Preld = {KC_LOAD, KC_LOAD,KC_LOAD}; % Set all preloads to zero.
    [kc_n_tot] = KC_COUPLING(tg, kc_nom, tl_nom, T_Q);
    kc_tot = kc_n_tot;
end
%% SOLVE SPECIFIC CASE
if (tg.solve_specific)
    % Solve specific case
    kc_s = kc_inT;
    [kc_s_tot] = KC_COUPLING(tg, kc_s, tl_inT, T_Q);
    kc_tot = kc_s_tot;
end
%% COMPLETION
% disp("KC_SOLVER() Ran Successfully")
%% FUNCTION CLOSE
end
