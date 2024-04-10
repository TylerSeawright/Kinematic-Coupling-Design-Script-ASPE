% main.m
clc, clear, close all

% Sample Script
[KC_og, KC_of, tg] = KC_SOLVER(config());
kc_plot_input_geometry2(KC_of, tg, "KC Free Body Diagram");
