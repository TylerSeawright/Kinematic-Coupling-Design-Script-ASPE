% KC_TRANSFORM.m
% This function transforms the input KC by HTM T. 
function kco = KC_TRANSFORM(kci, T)
    
    % Init kc_out
    kco = kci;
    % Split T into rotation and translation components.
    Tr = [T(1:3,1:3), [0,0,0]';[0,0,0,1]];
    % Tp = [eye(3), T(1:3,4);[0,0,0,1]];
    % Split is necessary since vectors are only rotated and positions are
    % transformed by position and rotation

    % Perform Transformations
    % Coupling Triangle
    kco.Pct = data_transform(T,kci.Pct')';

    % POI
    kco.poi = data_transform(T,kci.poi);
    
    % Ball Geometry
    kco.Db = kci.Db;       % Ball diameter
    kco.Rb2 = kci.Rb2;     % Ball radius (for canoe ball)
    
    % Vee Geometry
    kco.Vg = kci.Vg;
    kco.Vh = kci.Vh;
    kco.Vreo = data_transform(Tr, kci.Vreo);
    
    kco.DV = kci.DV;
    
    % Forces
    kco.Ld.P = data_transform(Tr, kci.Ld.P')';
    kco.Ld.P_loc = data_transform(T, kci.Ld.P_loc')';
    for i = 1:3
        kco.Preld{i}.P = data_transform(Tr, kci.Preld{i}.P')';
        kco.Preld{i}.P_loc = data_transform(T, kci.Preld{i}.P_loc')';
    end
    
    % Materials
    kco.Mball = kci.Mball;
    kco.Mvee = kci.Mvee;
    kco.sig_y_SF = kci.sig_y_SF;
    kco.sig_tau_SF = kci.sig_tau_SF;
    
    % Ball
    kco.Diam = kci.Diam;
    kco.Circ = kci.Circ; 

    % Format Data
    dtop_B_i = [kci.dXtop_B', kci.dYtop_B', kci.dZtop_B']';
    dbot_B_i = [kci.dXbot_B', kci.dYbot_B', kci.dZbot_B']';
    dpin_i = [kci.dXpin_G', kci.dYpin_G', kci.dZpin_G']';
    
    % Transform data
    dtop_B_o = data_transform(T, dtop_B_i')';
    dbot_B_o = data_transform(T, dbot_B_i')';
    dpin_o = data_transform(T, dpin_i')';

    kco.dXtop_B = dtop_B_o(1,:);   
    kco.dYtop_B = dtop_B_o(2,:);   
    kco.dZtop_B = dtop_B_o(3,:);   
    kco.dXbot_B = dbot_B_o(1,:); 
    kco.dYbot_B = dbot_B_o(2,:); 
    kco.dZbot_B = dbot_B_o(3,:); 
    % Groove
    kco.Heightv = kci.Heightv;
    kco.Orient = kci.Orient;
    kco.Halfa = kci.Halfa;
    kco.dXpin_G = dpin_o(1,:);
    kco.dYpin_G = dpin_o(2,:);
    kco.dZpin_G = dpin_o(3,:);
    %% Outputs
    kco.Pb = data_transform(T,kci.Pb')';
    kco.or = data_transform(Tr,kci.or')';
    kco.dc = data_transform(Tr,kci.dc')';
    kco.Pc = data_transform(T,kci.Pc')';
    kco.C = incenter_solve(kci.Pct);
    kco.RP = kci.RP;
    kco.in_bd = kci.in_bd;
    kco.dPc = data_transform(T,kci.dPc')';
    kco.dPb = data_transform(T,kci.dPb')';
    kco.sigma = kci.sigma;
    kco.tau = kci.tau;
    kco.clamp_separation = kci.clamp_separation;
    kco.C_err(1:3) = data_transform(T,kci.C_err(1:3));
    kco.C_err(4:6) = data_transform(Tr,kci.C_err(4:6));
    kco.T_GC_BC = T * kci.T_GC_BC;
    for i = 1:6
        kco.T_Vees{i} = Tr * kci.T_Vees{i};
    end

end