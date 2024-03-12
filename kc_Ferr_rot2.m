function [rest_err, T_err, Dbc, bN] = kc_Ferr_rot2(dib, dc, C, bO)
%% Calculate the error rotation HTM given:
% del_1D = deflection matrix in frame of each ball contact
% C = coupling centroid
% dc = direction cosines for input forces
% Pb = ball centers
% T =  transformation matrix list for vee groove flats
% (1) Convert deflections into 1D values
    % - Add deflections of each contact point for each ball for total ball
    % shift
% This script is the Matlab version of Dr. Alexander H. Slocum's
% Kinematic_Coupling_3Groove_Design.xls
%% Unpack Inputs
Ab = dc(1,:);
Bb = dc(2,:);
Gb = dc(3,:);
%% REF Values
x_ax = [1,0,0];
%% Calculate New Ball Coordinates and Center Deflections
% bN is in form [x1,x2,x3;y1,y2,y3;z1,z2,z3]
for i = 1:2:6
    j = (i+1)/2;
    bN(1,j) = bO(1,j) + (Ab(i).*dib(i) + Ab(i+1).*dib(i+1));
    bN(2,j) = bO(2,j) + (Bb(i).*dib(i) + Bb(i+1).*dib(i+1));
    bN(3,j) = bO(3,j) + (Gb(i).*dib(i) + Gb(i+1).*dib(i+1));
    bcD(1:3,j) = bN(1:3,j) - bO(1:3,j); % Ball center deflections
end
%% Solve originl sides' angles with x axis
Aot = 180*vec_ang(bO(1:3,1)-bO(1:3,2), x_ax)/pi; % Opposite Ball 3
Att = 180*vec_ang(bO(1:3,3)-bO(1:3,2), x_ax)/pi; % Opposite Ball 1
Ato = 180*vec_ang(bO(1:3,1)-bO(1:3,3), x_ax)/pi; % Opposite Ball 2 
% A_ang = [Aot,Att,Ato];
%% Solve new sides' angles with x axis
AotN = 180*vec_ang(bN(1:3,1)-bN(1:3,2), x_ax)/pi; % Opposite Ball 3
AttN = 180*vec_ang(bN(1:3,3)-bN(1:3,2), x_ax)/pi; % Opposite Ball 1
AtoN = 180*vec_ang(bN(1:3,1)-bN(1:3,3), x_ax)/pi; % Opposite Ball 2 
%% Solve the new distances between balls from Slocum Fig 7.7.8, p408.
LotN = distance(bN(1:3,1),bN(1:3,2));
LttN = distance(bN(1:3,2),bN(1:3,3));
LtoN = distance(bN(1:3,3),bN(1:3,1));
% LN = [LotN, LttN, LtoN];
%% Solve Original Altitudes
Aone = LotN*sin(pi*abs(Aot-Att)/180);
Atwo = LttN*sin(pi*abs(Aot-Att)/180);
Athree = LtoN*sin(pi*abs(Ato-Att)/180);
% AO = [Aone,Atwo,Athree];
%% Solve distance from ball to centroid (Slocum eq. 7.7.9 p407)
for i = 1:3
   Dbc(i) = distance(bN(1:3,i),C'); 
end
%% Solve the new Altitudes from Slocum p408
AoneN = LotN*sin(pi*abs(AotN-AttN)/180);
AtwoN = LttN*sin(pi*abs(AotN-AttN)/180);
AthreeN = LtoN*sin(pi*abs(AtoN-AttN)/180);
AN = [AoneN,AtwoN,AthreeN];
%% Solve Rotation about Opposite Side
Ttt = bcD(3,1)/Aone;
Tto = bcD(3,2)/Atwo;
Tot = bcD(3,3)/Athree;
% theta = [Ttt,Tto,Tot];
%% Solve Centroid Position Error
dCx = 0; dCy = 0; dCz = 0;
for i = 1:3
   dCx = dCx + bcD(1,i)*(AN(i)-Dbc(i))/AN(i);
   dCy = dCy + bcD(2,i)*(AN(i)-Dbc(i))/AN(i);
   dCz = dCz + bcD(3,i)*(AN(i)-Dbc(i))/AN(i);
end
dC = [sum(dCx),sum(dCy),sum(dCz)]';
%% Solve Error Rotations about X and Y, Slocum p407
eps_X = Ttt*cos(pi*Att/180)+Tto*cos(pi*Ato/180)-Tot*cos(pi*Aot/180);
eps_Y = Ttt*sin(pi*Att/180)+Tto*sin(pi*Ato/180)-Tot*sin(pi*Aot/180);
%% Solve the Error Rotations in Z, Slocum eq. 7.7.12, p407
epsZ1 = sqrt((0.5*(Ab(1)*dib(1)+Ab(2)*dib(2)))^2 + (0.5*(Bb(1)*dib(1)+Bb(2)*dib(2)))^2)*sign(-(Ab(1)*dib(1)+Ab(2)*dib(2)))/sqrt((bO(1,1)-C(1))^2+(bO(2,1)-C(2))^2);
epsZ2 = sqrt((0.5*(Ab(3)*dib(3)+Ab(4)*dib(4)))^2 + (0.5*(Bb(3)*dib(3)+Bb(4)*dib(4)))^2)*sign((Ab(3)*dib(3)+Ab(4)*dib(4)))/sqrt((bO(1,2)-C(1))^2+(bO(2,2)-C(2))^2);
epsZ3 = sqrt((0.5*(Ab(5)*dib(5)+Ab(6)*dib(6)))^2 + (0.5*(Bb(5)*dib(5)+Bb(6)*dib(6)))^2)*sign((Ab(5)*dib(5)+Ab(6)*dib(6)))/sqrt((bO(1,3)-C(1))^2+(bO(2,3)-C(2))^2);
epsZ = (epsZ1+epsZ2+epsZ3)/3; % Slocum eq. 7.7.13, p407
%% Solve Error HTM
T_err = [1 -epsZ eps_Y dC(1);
        epsZ 1 -eps_X dC(2);
        -eps_Y eps_X 1 dC(3);
        0 0 0 1];
%% Store Error components to single vector.
rest_err = [eps_X, eps_Y, epsZ, dC'];
end