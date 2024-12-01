% Debug Script
% Author: Tyler Seawright
% Last Edited: 8/7/24
%% CLEANUP
clc, clear, close all

%% KC APPLICATION SCRIPT
[tg, KC_in, tl_in, N, T_custom] = config_debug();
[kc_og, kc_of, ~, ~] = KC_SOLVER(tg, KC_in, tl_in, N, T_custom);

disp(kc_of.Preld{1}.P_loc)
disp(kc_of.T_GC_BC)

kc_plot_FBD(kc_of, tg, "FBD DEBUG");