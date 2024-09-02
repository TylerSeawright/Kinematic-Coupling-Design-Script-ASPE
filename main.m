%% main.m
% Author: Tyler Seawright
% Last Edited: 5/21/24
% Build KC Applications using KC_SOLVER(), and plot tools.
%% CLEANUP
clc, clear, close all

%% KC APPLICATION SCRIPT
% Sample Script
[tg, kc_in, tl_in, N, T_custom] = config();
[KC_og, KC_of, T_tot, tg] = KC_SOLVER(tg, kc_in, tl_in, N, T_custom);

%% OUTPUTS
% Print Outputs
    % - Text Printouts
% fprintf("KC_of.dPb (um) = \n"), disp(KC_of.dPb*1e3)
fprintf("KC_of.Cerr (um) = \n"), disp(KC_of.C_err*1e3)
% fprintf("KC_of.C (mm) = \n"), disp(KC_of.C)
% fprintf("KC_of.Pb mm = \n"), disp(KC_of.Pb)
% fprintf("KC_of.Pct mm = \n"), disp(KC_of.Pct)
% fprintf("KC_of.dc = \n"), disp(KC_of.dc)
% fprintf("KC_of.poi_err = \n"), disp(KC_of.poi_err)
% fprintf("KC_of.poi = \n"), disp(KC_of.poi)
    % - Plots
% kc_plot_FBD(KC_of, tg, "KC Free Body Diagram");
% kc_plot_disp(KC_of, tg, "KC Error Displacements");
% plot_err_exaggerated(KC_og, KC_og.T_GC_BC, T_tot, 10, "Coupling Centroid
% Error, Exaggerated") % WIP

% Organize Figures on Screen 
findfigs % Move off screen plots onto the screen.