function kc_g = Rest_Pos(kc, tl, tg);
%% INIT INPUTS
kc_g = kc;
%% NOMINAL DIMENSIONS
% For the ball pallet
Xb_nomB = kc.Pct(1,1:3); % Nominal Ball Positions [mm]
Yb_nomB = kc.Pct(2,1:3); % Nominal Ball Positions [mm]
Zb_nomB = kc.Pct(3,1:3); % Nominal Ball Positions [mm]

% For the groove body
Xp_nomG = Xb_nomB; % Nominal Vee Groove Positions [mm]
Yp_nomG = Yb_nomB; % Nominal Vee Groove Positions [mm]
Zp_nomG = Zb_nomB; % Nominal Vee Groove Positions [mm]

% Ball
Diam =kc.Diam;
Circ =kc.Circ;
dXtop_B = kc.dXtop_B;
dYtop_B = kc.dYtop_B;
dZtop_B = kc.dZtop_B;
dXbot_B = kc.dXbot_B;
dYbot_B = kc.dYbot_B;
dZbot_B = kc.dZbot_B;
% Groove
Heightv = kc.Heightv;
Orient = kc.Orient;
Halfa = kc.Halfa;
dXpin_G = kc.dXpin_G;
dYpin_G = kc.dYpin_G;
dZpin_G = kc.dZpin_G;
d_pin = [dXpin_G;dYpin_G;dZpin_G];

%% CALCULATING RESTING POSITION
[Pb, Db_row, C] = kct_ballgeom(Xb_nomB, Yb_nomB, Zb_nomB, Diam, Circ, dXtop_B, dYtop_B, dZtop_B, dXbot_B, dYbot_B, dZbot_B);

% Solve Csys for groove bodies, T_GC is groove body CS from N frame, TGXX_G
% is groove body flat CS for each flat surface x6
if(tg.threeD_coupling)
    % Use vee_reorient values
    vee_reorient = kc.Vreo;
else
    vee_reorient = zeros(3); % Set vee reorient values to zero
end

% Solve Groove Flat Transform Matrices
[T_G, TG11_G, TG12_G, TG21_G, TG22_G, TG31_G, TG32_G] = kct_groovegeom(kc.Pct, Heightv, Orient, Halfa, Diam, d_pin, vee_reorient);
TGVV_G = {TG11_G, TG12_G, TG21_G, TG22_G, TG31_G, TG32_G};
% Solve resting position and orientation (no load) 
%     Pc are ball contact points as vector list
%     alpha_rest, beta_rest, gamma_rest are error orientation angles
%     xr_rest, yr_rest, zr_rest, are error positions of coupling centroid
%     TB_G_rest is the HTM relating BC to Groove frame in resting state (no load)
[T_GC_BC, alpha_rest, beta_rest, gamma_rest, xr_rest, yr_rest, zr_rest, Pc] = kct_rest(Pb, Db_row, TG11_G, TG12_G, TG21_G, TG22_G, TG31_G, TG32_G);
err_geo = [alpha_rest, beta_rest, gamma_rest, xr_rest, yr_rest, zr_rest];

% Calculate Coupling centroid based on new ball centers
C_B = T_GC_BC(1:3,4); % Should be [0 0 0] in BC coordinate system
T_ng = T_GC_BC;

% Solve Vees with Contact Points (For Plotting)
HTM = vee_plane_transform(Pb, kc.Db, kc.Vg*180/pi, Orient, vee_reorient);
%% Set KC VALUES
kc_g.Pb = Pb;
kc_g.Pc = Pc;
kc_g.C = C; % ********** Change to C_B LATER **********
kc_g.C_err = err_geo;
kc_g.T_GC_BC = T_ng;
kc_g.T_Vees = HTM;
