%% kc_deviate
% Author: Tyler Seawright
% Last Edited: 9/6/24
% Deviate KC geometry by tolerances defined in KC object

function kco = kc_deviate(kci, sd)
    kco = kci;

    %% Vary inputs by input tolerance
        for i = 1:3
        kco.Pct(1:3,i) = nrd(kco.Pct(1:3,i), kco.tl.B_tol'./sd); % Ball Position
        kco.Pct(1:3,i) = nrd(kco.Pct(1:3,i), kco.tl.V_tol'./sd); % Vee position adds to ball position (derived vees)
        kco.Preld{i}.P = nrd(kco.Preld{i}.P, kco.tl.F_L'./sd); % Applied Load
    end
    kco.Ld.P_loc = nrd(kco.Ld.P_loc, kco.tl.FL_loc'./sd); % Applied Load Position
    kco.or = nrd(kco.or, kco.tl.Or./sd); % Vee axis
    kco.Vg = nrd(kco.Vg, kco.tl.Vang./sd); % Vee groove angle
    kco.Vreo = nrd(kco.Vreo, kco.tl.Or./sd); % Vee reorientation (3D)
    kco.Db = nrd(kco.Db, kco.tl.Db./sd); % Ball Diameter
    kco.Db = nrd(kco.Db, kco.tl.Circ*2/sd); % Ball ROC
    kco.Rb2 = nrd(kco.Rb2, kco.tl.Circ*2/sd); % Ball ROC2
    kco.Ld.P = nrd(kco.Ld.P, kco.tl.F_L'./sd); % Applied Load


end

%% TOLERANCE LIST
% KC.tl.Db = Diam_tol;     % mm
% KC.tl.Circ = Circ_tol;     % mm
% KC.tl.B_tol = B_pos_tol;      % mm
% KC.tl.Vht = Heightv_tol;  % mm
% KC.tl.Or = Orient_tol;   % rad
% KC.tl.Vang = Halfa_tol;    % rad
% KC.tl.V_tol = V_pos_tol;      % mm
% KC.tl.F_L = F_L_tol;      % N
% KC.tl.F_P = F_P_tol;      % N
% KC.tl.FL_loc = FL_loc_tol;   % mm
% KC.tl.B_tol = B_pos_tol; % mm