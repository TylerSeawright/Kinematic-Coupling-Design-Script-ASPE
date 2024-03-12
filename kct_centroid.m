function [T] = kct_centroid(X, Y, Z)
% Calculates the coordinates of the apices of a couplingtriangle in its centroid coordinates system
% Length of the sides
Side(1) = sqrt( (X(2)-X(3))^2 + (Y(2)-Y(3))^2 + (Z(2)-Z(3))^2 );
Side(2) = sqrt( (X(3)-X(1))^2 + (Y(3)-Y(1))^2 + (Z(3)-Z(1))^2 );
Side(3) = sqrt( (X(1)-X(2))^2 + (Y(1)-Y(2))^2 + (Z(1)-Z(2))^2 );
% Apex angles
Apex(1) = acos( (Side(2)^2 + Side(3)^2 - Side(1)^2) /(2*Side(2)*Side(3)) );
Apex(2) = acos( (Side(3)^2 + Side(1)^2 - Side(2)^2) /(2*Side(3)*Side(1)) );
Apex(3) = acos( (Side(1)^2 + Side(2)^2 - Side(3)^2) /(2*Side(1)*Side(2)) );
% Coordinates of the centers of the balls in the centroid CSYS
X_CC(3) = Side(2) * sin(Apex(1)/2) / cos(Apex(2)/2);
Y_CC(3) = 0; % By definition, Ball 3 is on the X-axis
X_CC(1) = X_CC(3) - Side(2) * cos(Apex(3)/2);
Y_CC(1) = Y_CC(3) + Side(2) * sin(Apex(3)/2);
X_CC(2) = X_CC(3) - Side(1) * cos(Apex(3)/2);
Y_CC(2) = Y_CC(3) - Side(1) * sin(Apex(3)/2);
for i = 1:3
Z_CC(i) = 0; % In centroid CSYS, the Z-plane goes through the 3 balls
end

% Unit vectors
U_31 = [X(1)-X(3); Y(1)-Y(3); Z(1)-Z(3)] / Side(2);
U_32 = [X(2)-X(3); Y(2)-Y(3); Z(2)-Z(3)] / Side(1);
U_3C = [U_31(1)+U_32(1); U_31(2)+U_32(2); U_31(3)+U_32(3)]/ sqrt((U_31(1)+U_32(1))^2 + (U_31(2)+U_32(2))^2 +(U_31(3)+U_32(3))^2);
% Coordinates of centroid
Dist_3C = Side(2) * sin(Apex(1)/2) / cos(Apex(2)/2);
Xc = X(3) + Dist_3C * U_3C(1);
Yc = Y(3) + Dist_3C * U_3C(2);
Zc = Z(3) + Dist_3C * U_3C(3);
Bc = asin((Zc-Z(3)) / X_CC(3));
% Rotation about the Y axis
Ac = acos((X(3)-Xc) / (X_CC(3)*cos(Bc)));
% Rotation about the Z axis
Gc = asin((Z(2) - Zc + X_CC(2)*sin(Bc)) /(Y_CC(2)*cos(Bc))); % Rotation about the X axis

% Set the elements within the homogenous transformationmatrix
T(1:4,1)=   [cos(Ac)*cos(Bc);
            sin(Ac)*cos(Bc); -sin(Bc);
            0];
T(1:4,2)=   [cos(Ac)*sin(Bc)*sin(Gc)-sin(Ac)*cos(Gc);
            sin(Ac)*sin(Bc)*sin(Gc)+cos(Ac)*cos(Gc); cos(Bc)*sin(Gc);
            0];
T(1:4,3)=   [cos(Ac)*sin(Bc)*cos(Gc)+sin(Ac)*sin(Gc);
            sin(Ac)*sin(Bc)*cos(Gc)-cos(Ac)*sin(Gc); cos(Bc)*cos(Gc);
            0];
T(1:4,4)=[Xc; Yc; Zc; 1];