% main.m
clc, clear, close all

% Sample Script
[KC_og, KC_of, T_tot, tg] = KC_SOLVER(config());


% Print Outputs
    % - Text Printouts
% fprintf("KC_of.T_GC_BC = \n"), disp(KC_of.T_GC_BC)
% fprintf("KC_og.T_GC_BC = \n"), disp(KC_og.T_GC_BC)
% fprintf("T_tot = \n"), disp(T_tot)

    % - Plots
kc_plot_FBD(KC_of, tg, "KC Free Body Diagram");
kc_plot_disp(KC_of, tg, "KC Error Displacements");
