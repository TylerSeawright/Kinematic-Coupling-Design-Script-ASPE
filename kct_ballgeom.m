function [PB, Db, C_B] = kct_ballgeom(X_B_nomB, Y_B_nomB, Z_B_nomB, Diam, Circ,...
                                 DeltaX_Top_datB, DeltaY_Top_datB, DeltaZ_Top_datB,...
                                 DeltaX_Bottom_datB, DeltaY_Bottom_datB, DeltaZ_Bottom_datB)

% X_B_nomB: X coord of the 3 balls 3*1
% Y_B_nomB: Y coord of the 3 balls 3*1
% Thick: Thickness of the plate is a scalar
% Lft: Length of a foot (until center of the ball) is a 3*1
% Diam: Diameter of a ball is a 3*1
% Circ: Circularity of a radius is a 6*1
% DeltaX_Top_datB: X Offset at the top of the plate, is a 3*1
% DeltaY_Top_datB: Y Offset at the top of the plate, is a 3*1
% DeltaX_Bottom_datB: X Offset at the bottom of the plate, is a 3*1
% DeltaY_Bottom_datB: X Offset at the bottom of the plate, is a 3*1

for ib = 1:3
X_Top_datB(ib) = X_B_nomB(ib) + DeltaX_Top_datB(ib);
Y_Top_datB(ib) = Y_B_nomB(ib) + DeltaY_Top_datB(ib);
Z_Top_datB(ib) = Z_B_nomB(ib) + DeltaZ_Top_datB(ib);
X_Bottom_datB(ib) = X_B_nomB(ib) +DeltaX_Bottom_datB(ib);
Y_Bottom_datB(ib) = Y_B_nomB(ib) +DeltaY_Bottom_datB(ib);
Z_Bottom_datB(ib) = Z_B_nomB(ib) +DeltaZ_Bottom_datB(ib);
% CALCULATIONS
%% Coordinates of the balls, in the datum CSYS (startingpoint + magnitude * unit direction vector)
Magn_Vect_Axis(ib) = sqrt((X_Top_datB(ib)-X_Bottom_datB(ib))^2 + (Y_Top_datB(ib)-Y_Bottom_datB(ib))^2+ Z_Bottom_datB(ib)^2);
X_B_datB(ib) = X_Bottom_datB(ib) + (X_Bottom_datB(ib) -X_Top_datB(ib));% * Lft(ib) / Magn_Vect_Axis(ib);
Y_B_datB(ib) = Y_Bottom_datB(ib) + (Y_Bottom_datB(ib) -Y_Top_datB(ib));% * Lft(ib) / Magn_Vect_Axis(ib);
Z_B_datB(ib) = Z_Bottom_datB(ib) + Z_Bottom_datB(ib);% *Lft(ib) / Magn_Vect_Axis(ib);
end
% IC = incenter_solve([X_B_datB(1);Y_B_datB(1);Z_B_datB(1)],[X_B_datB(2);Y_B_datB(2);Z_B_datB(2)],[X_B_datB(3);Y_B_datB(3);Z_B_datB(3)])
%% Geometry of the coupling triangle
%%% Length of the sides
Side_TriB(1) = sqrt( (X_B_datB(2)-X_B_datB(3))^2 +(Y_B_datB(2)-Y_B_datB(3))^2 + (Z_B_datB(2)-Z_B_datB(3))^2);
Side_TriB(2) = sqrt( (X_B_datB(3)-X_B_datB(1))^2 +(Y_B_datB(3)-Y_B_datB(1))^2 + (Z_B_datB(3)-Z_B_datB(1))^2);
Side_TriB(3) = sqrt( (X_B_datB(1)-X_B_datB(2))^2 +(Y_B_datB(1)-Y_B_datB(2))^2 + (Z_B_datB(1)-Z_B_datB(2))^2);
%%% Apex angles
Apex_TriB(1) = acos( (Side_TriB(2)^2 + Side_TriB(3)^2 -Side_TriB(1)^2) / (2*Side_TriB(2)*Side_TriB(3)) );
Apex_TriB(2) = acos( (Side_TriB(3)^2 + Side_TriB(1)^2 -Side_TriB(2)^2) / (2*Side_TriB(3)*Side_TriB(1)) );
Apex_TriB(3) = acos( (Side_TriB(1)^2 + Side_TriB(2)^2 -Side_TriB(3)^2) / (2*Side_TriB(1)*Side_TriB(2)) );
%%% Coordinates of the centers of the balls in the BC CSYS
X_B_BC(3) = Side_TriB(2) * sin(Apex_TriB(1)/2) /cos(Apex_TriB(2)/2);

Y_B_BC(3) = 0; % By definition, Ball 3 is on the X-axis

X_B_BC(1) = X_B_BC(3) - Side_TriB(2) * cos(Apex_TriB(3)/2);
Y_B_BC(1) = Y_B_BC(3) + Side_TriB(2) * sin(Apex_TriB(3)/2);
X_B_BC(2) = X_B_BC(3) - Side_TriB(1) * cos(Apex_TriB(3)/2);
Y_B_BC(2) = Y_B_BC(3) - Side_TriB(1) * sin(Apex_TriB(3)/2);
for ib = 1:3
Z_B_BC(ib) = 0; % In BC CSYS, the Z-plane goesthrough the 3 balls
Rb(2*ib-1) = Diam(ib)/2; % Fix the average radius onone side of the ball
Rb(2*ib) = Diam(ib)/2; % Fix the average radius onthe other side
end

% IC_BC = incenter_solve([X_B_BC(1);Y_B_BC(1);Z_B_BC(1)],[X_B_BC(2);Y_B_BC(2);Z_B_BC(2)],[X_B_BC(3);Y_B_BC(3);Z_B_BC(3)])
%% Transform between balls and coupling centroid
T_B_N = kct_centroid(X_B_BC, Y_B_BC, Z_B_BC); % Solve the transform between the balls and coupling centroid
C_B = T_B_N(1:3,4);
for i = 1:6
Db(i) = 2*(Rb(i) + Circ(i)); % Add out of roundness
end
PB = [zeros(4)]; % Define PB vectors.
for i = 1:3
    PB(1:4,i) = [X_B_BC(i); Y_B_BC(i); Z_B_BC(i); 1];
    % Form [X1, X2, X3; Y1, Y2, ...; 1 1 ..]
end
PB(1:3,4) = PB(1:3,3);