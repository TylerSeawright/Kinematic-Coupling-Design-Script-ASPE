%% main.m
% Author: Tyler Seawright
% Last Edited: 9/18/24
% Build KC Applications using KC_SOLVER(), and plot tools.
%% CLEANUP
clc, clear, close all

%% KC APPLICATION SCRIPT
% Sample Script
[tg, kci] = config();
[kco] = KC_SOLVER(tg, kci);
%% OUTPUTS
% Print Outputs
    % - Text Printouts
% fprintf("KC_of.dPb (um) = \n"), disp(KC_of.dPb*1e3)
fprintf("KC_of.Cerr (um) = \n"), disp(kco.C_err*1e3)
    % - Plots
% kc_plot_FBD(KC_of, tg, "KC Free Body Diagram");
% kc_plot_disp(KC_of, tg, "KC Error Displacements");

% Organize Figures on Screen 
findfigs % Move off screen plots onto the screen.