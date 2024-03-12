function [T_GC_mfgG, T_V11_GC, T_V12_GC, T_V21_GC, T_V22_GC, T_V31_GC,T_V32_GC] = kct_groovegeom1(X_V_nomG, Y_V_nomG, Z_V_nomG, Height_V_mfgG, Or, Halfa_three, Diam, DeltaX_mfgG, DeltaY_mfgG, DeltaZ_mfgG, v_reo)
% X_V_nomG: nominal X coord of a vee-groove, is a 3*1
% Y_V_nomG: nominal Y coord of a vee-groove, is a 3*1
% Z_V_nomG: nominal Y coord of a vee-groove, is a 3*1
% Height_V_mfgG: Distance between the top of the plate and the vertex of a vee-groove, is a 3*1
% Or: Orientation angle of the grooves, is a 3*1
% Halfa: Half-Angle of aperture of the vee-grooves is a6*1
% Diam: Diameter of a perfect virtual ball, is a scalar
% DeltaX_mfgG: X Offset of the pin, is a 3*1
% DeltaY_mfgG: Y Offset of the pin, is a 3*1
% DeltaZ_mfgG: Y Offset of the pin, is a 3*1
% re_orient: Re-orient each vee about the ball, is a 3x3

% FLAT SURFACES IN MFG COORDINATES SYSTEM
% Translation of the vertex

for i = 1:2:6 % Set Halfa to a 1x6 matrix where every 2 are flipped
    j = (1+i)/2;
    Halfa(i) = Halfa_three(j);
    Halfa(i+1) = Halfa_three(j);
end

for ig = 1:3
    X_V_mfgG(ig) = X_V_nomG(ig) + DeltaX_mfgG(ig);
    Y_V_mfgG(ig) = Y_V_nomG(ig) + DeltaY_mfgG(ig);
    Z_V_mfgG(ig) = Z_V_nomG(ig) + Height_V_mfgG(ig) + DeltaZ_mfgG(ig);
end
T_V_Tr_1 = [1 0 0 X_V_mfgG(1); 0 1 0 Y_V_mfgG(1); 0 0 1 Z_V_mfgG(1); 0 0 0 1];
T_V_Tr_2 = [1 0 0 X_V_mfgG(2); 0 1 0 Y_V_mfgG(2); 0 0 1 Z_V_mfgG(2); 0 0 0 1];
T_V_Tr_3 = [1 0 0 X_V_mfgG(3); 0 1 0 Y_V_mfgG(3); 0 0 1 Z_V_mfgG(3); 0 0 0 1];
% Rotation about the Z axis of the vertex
T_V_RinZ_11 = [cos(Or(1)-pi/2) -sin(Or(1)-pi/2) 0 0; sin(Or(1)-pi/2) cos(Or(1)-pi/2) 0 0; 0 0 1 0; 0 0 0 1];
T_V_RinZ_12 = [cos(Or(1)+pi/2) -sin(Or(1)+pi/2) 0 0; sin(Or(1)+pi/2) cos(Or(1)+pi/2) 0 0; 0 0 1 0; 0 0 0 1];
T_V_RinZ_21 = [cos(Or(2)-pi/2) -sin(Or(2)-pi/2) 0 0; sin(Or(2)-pi/2) cos(Or(2)-pi/2) 0 0; 0 0 1 0; 0 0 0 1];
T_V_RinZ_22 = [cos(Or(2)+pi/2) -sin(Or(2)+pi/2) 0 0; sin(Or(2)+pi/2) cos(Or(2)+pi/2) 0 0; 0 0 1 0; 0 0 0 1];
T_V_RinZ_31 = [cos(Or(3)-pi/2) -sin(Or(3)-pi/2) 0 0; sin(Or(3)-pi/2) cos(Or(3)-pi/2) 0 0; 0 0 1 0; 0 0 0 1];
T_V_RinZ_32 = [cos(Or(3)+pi/2) -sin(Or(3)+pi/2) 0 0; sin(Or(3)+pi/2) cos(Or(3)+pi/2) 0 0; 0 0 1 0; 0 0 0 1];
% Rotation about the Y axis of the vertex
T_V_RinY_11 = [cos(pi/2-Halfa(1)) 0 sin(pi/2-Halfa(1)) 0; 0 1 0 0; -sin(pi/2-Halfa(1)) 0 cos(pi/2-Halfa(1)) 0; 0 0 0 1];
T_V_RinY_12 = [cos(pi/2-Halfa(2)) 0 sin(pi/2-Halfa(2)) 0; 0 1 0 0; -sin(pi/2-Halfa(2)) 0 cos(pi/2-Halfa(2)) 0; 0 0 0 1];
T_V_RinY_21 = [cos(pi/2-Halfa(3)) 0 sin(pi/2-Halfa(3)) 0; 0 1 0 0; -sin(pi/2-Halfa(3)) 0 cos(pi/2-Halfa(3)) 0; 0 0 0 1];
T_V_RinY_22 = [cos(pi/2-Halfa(4)) 0 sin(pi/2-Halfa(4)) 0; 0 1 0 0; -sin(pi/2-Halfa(4)) 0 cos(pi/2-Halfa(4)) 0; 0 0 0 1];
T_V_RinY_31 = [cos(pi/2-Halfa(5)) 0 sin(pi/2-Halfa(5)) 0; 0 1 0 0; -sin(pi/2-Halfa(5)) 0 cos(pi/2-Halfa(5)) 0; 0 0 0 1];
T_V_RinY_32 = [cos(pi/2-Halfa(6)) 0 sin(pi/2-Halfa(6)) 0; 0 1 0 0; -sin(pi/2-Halfa(6)) 0 cos(pi/2-Halfa(6)) 0; 0 0 0 1];
 
% Re-Orient Vees for nonplanar couplings(Added by Tyler S. 8/24/23)
% i=1;j=2;k=3; % Rotation Order Setting
% Treo_32 = Tform(-Pb(1:3,3),0) *Tform(v_reo(3,j),j) *Tform(v_reo(3,i),i) *Tform(Pb(1:3,3),0);
% T_V11_mfgG = T_V_Tr_1 * T_V_RinZ_11 *Tform(v_reo(1,k),k) * T_V_RinY_11*Tform(v_reo(1,j),j) *Tform(v_reo(1,i),i);
% T_V12_mfgG = T_V_Tr_1 * T_V_RinZ_12 *Tform(v_reo(1,k),k) * T_V_RinY_12*Tform(v_reo(1,j),j) *Tform(v_reo(1,i),i);
% T_V21_mfgG = T_V_Tr_2 * T_V_RinZ_21 *Tform(v_reo(2,k),k) * T_V_RinY_21*Tform(v_reo(2,j),j) *Tform(v_reo(2,i),i);
% T_V22_mfgG = T_V_Tr_2 * T_V_RinZ_22 *Tform(v_reo(2,k),k) * T_V_RinY_22*Tform(v_reo(2,j),j) *Tform(v_reo(2,i),i);
% T_V31_mfgG = T_V_Tr_3 * T_V_RinZ_31 *Tform(v_reo(3,k),k) * T_V_RinY_31*Tform(v_reo(3,j),j) *Tform(v_reo(3,i),i);
% T_V32_mfgG = T_V_Tr_3 * T_V_RinZ_32 *Tform(v_reo(3,k),k) * T_V_RinY_32*Tform(v_reo(3,j),j) *Tform(v_reo(3,i),i);
% Combination of the transformations

% You give coord in local CSYS, this matrix will return the coord in the mfg CSYS
T_V11_mfgG = T_V_Tr_1 * T_V_RinZ_11 * T_V_RinY_11
T_V12_mfgG = T_V_Tr_1 * T_V_RinZ_12 * T_V_RinY_12
T_V21_mfgG = T_V_Tr_2 * T_V_RinZ_21 * T_V_RinY_21;
T_V22_mfgG = T_V_Tr_2 * T_V_RinZ_22 * T_V_RinY_22;
T_V31_mfgG = T_V_Tr_3 * T_V_RinZ_31 * T_V_RinY_31;
T_V32_mfgG = T_V_Tr_3 * T_V_RinZ_32 * T_V_RinY_32;


% GROOVE CENTROID IN MFG COORDINATES SYSTEM
for ig = 1:3
    % Dist_CV = 0 when vees are measured using a tooling ball and centroid
    % is on the same plane as the balls.
    Dist_CV(ig) = (Diam(ig)/2) / sin((Halfa(2*ig-1) +Halfa(2*ig)) / 2); % Distance between vertex and center of the ball
    % Dist_CV(ig) = 0; % (Diam(ig)/2) / sin((Halfa(2*ig-1) +Halfa(2*ig)) / 2); % Distance between vertex and center of the ball
    X_G_mfgG(ig) = X_V_mfgG(ig) - Dist_CV(ig) *sin((Halfa(2*ig-1) - Halfa(2*ig)) /2) *sin(Or(ig));
    Y_G_mfgG(ig) = Y_V_mfgG(ig) + Dist_CV(ig) *sin((Halfa(2*ig-1) - Halfa(2*ig)) /2) *cos(Or(ig));
    Z_G_mfgG(ig) = Height_V_mfgG(ig) + Dist_CV(ig) *cos((Halfa(2*ig-1) - Halfa(2*ig)) /2);
end
T_GC_mfgG = kct_centroid(X_G_mfgG, Y_G_mfgG, Z_G_mfgG);

% You give coord in centroid CSYS, this matrix will return the coord in the mfg CSYS

% FLAT SURFACES IN GROOVE CENTROID COORDINATES SYSTEM
T_V11_GC = T_GC_mfgG \ T_V11_mfgG;
T_V12_GC = T_GC_mfgG \ T_V12_mfgG;
T_V21_GC = T_GC_mfgG \ T_V21_mfgG;
T_V22_GC = T_GC_mfgG \ T_V22_mfgG;
T_V31_GC = T_GC_mfgG \ T_V31_mfgG;
T_V32_GC = T_GC_mfgG \ T_V32_mfgG;