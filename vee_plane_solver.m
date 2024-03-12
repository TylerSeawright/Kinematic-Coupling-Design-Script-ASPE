% vee_plane_solver.m
% This function solves the HTMs for each vee flat arbitrarily oriented by
% vee_reorient. 
close all; clear; clc;
Db = [20,20,20];
V_ang = (pi/2) * ones(3,1);
Phi = V_ang/2;
vr = [pi/6,0,0;
      0,pi/3,0;
      0,0,pi/2];

HTM = cell(6,1);
T3 = cell(3,1);

for i = 1:2:6
    j = (i+1)/2;
    % Start at origin point (ball center)
    p0 = [0,0,0];
    
    % Move p0 down in Y to touch bottom of ball.
    T1 = Tform([0,0,-Db(j)/2],0);
    p1 = data_transform(T1, p0);
    
    % Rotate by phi about Z axis
    T2_1 = Tform(Phi(j),1);
    T2_2 = Tform(-Phi(j),1);
    
    % Rotate by vee reorientation values
    T3{j} = Tform(vr(j,3),3) * Tform(vr(j,2),2) * Tform(vr(j,1),1);
    
    % Plot (DEV TOOL)
    HTM{i} = T3{j}*T2_1*T1;
    HTM{i+1} = T3{j}*T2_2*T1;
    plotSphereAndPlane(Db(j), HTM{i}, HTM{i+1})
end