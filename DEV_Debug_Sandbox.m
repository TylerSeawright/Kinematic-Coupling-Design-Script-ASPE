%% DEV_Debug_Sandbox.m
% Author: Tyler Seawright
% Last Edited: 11/9/24
% This script is a sandbox for debugging KC functions.
clc, clear, close all
%% INITIALIZE INPUTS

[tg, kci] = config_debug();

%% SOLVE KC SYSTEM

[kco] = KC_SOLVER(tg, kci);

%% PLOT RESULTS

kc_plot_FBD(kco, tg, "KC Free Body Diagram");
% kc_plot_disp(kco, tg, "KC Error Displacements");
%% PRINTING OUTPUTS

%% ADDITIONAL FUNCTIONS
% KC_TRANSFORM() transforms a KC object to a new coordinate system. 
% Tform creates a homogeneous transform matrix for rotation and
% transformation.

% HTM = Tform(pi/3,1); % Transform -pi/4 about X axis.
% kc_transformed = KC_TRANSFORM(kco, HTM); % Transform kco by HTM
% kc_plot_FBD(kc_transformed, tg, "KC FBD Transformed by HTM");