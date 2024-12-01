%% tutorial_kc.m
% Author: Tyler Seawright
% Last Edited: 5/23/24
% This script is a tutorial for how to use the KC solver in custom scripts.
clc, clear, close all
%% INITIALIZE INPUTS
% The first step to using the script is to initialize the inputs. This is
% done by editing the config() file which is currently a function. In the
% future it may be a GUI and store values in a folder. At this time, it is
% a function for development. 
% To initialize the inputs, use config().
% - tg represents the toggles associated with the script. 
% - kc represents the kinematic coupling system. The variables associated
% with the system can be found in the KC_SYS.m class. =
[tg, kci] = config();

%% SOLVE KC SYSTEM
% Call KC_SOLVER() with all the outputs from config(). At this stage,
% inputs to KC_SOLVER may be modified per the user's own studies. An
% example of a study is to move the applied load position and plot the
% centroid error as a function of force position. 
% geometry
% - tg represents the toggles used for this solution.
[kco] = KC_SOLVER(tg, kci);

%% PLOT RESULTS
% kc_plot_FBD() plots the free body diagram of the system in the coordinate
% system of the kc object.
% Similarly, kc_plot_disp() plots the displacement of the ball at each
% contact point. Both functions accept a text input for the plot title.
kc_plot_FBD(kco, tg, "KC Free Body Diagram");
% kc_plot_disp(kco, tg, "KC Error Displacements");
%% PRINTING OUTPUTS
% The KC object contains numerous outputs that are available and attainable
% using the KC_SYS class. A list of all variables solved in the class is
% printed to the console.
% disp(kco)
%% ADDITIONAL FUNCTIONS
% KC_TRANSFORM() transforms a KC object to a new coordinate system. 
% Tform creates a homogeneous transform matrix for rotation and
% transformation.

% HTM = Tform(-pi/4,1); % Transform -pi/4 about X axis.
% kc_transformed = KC_TRANSFORM(kco, HTM); % Transform kco by HTM
% kc_plot_FBD(kc_transformed, tg, "KC FBD Transformed by HTM");