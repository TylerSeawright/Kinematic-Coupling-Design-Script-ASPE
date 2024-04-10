% KC_COUPLING.m

function [kc_g, kc_f, T_Tot] = KC_COUPLING(tg, kc, tl, T_Q)
    
    %% INIT INPUT VARIABLES
    
    %% KC VARIATION SETUP
Halfa_nom = (kc.Vg / 2) * pi/180; % Half angles of vee groove defined by V_groove_ang

% For the ball pallet
if (tg.solve_specific)
    for i = 1:3
        % Ball
        kc.Diam(i) =       kc.Db(i) + tl.Db(i);
        kc.Circ(2*i-1) =   tl.Circ(i);
        kc.Circ(2*i) =     tl.Circ(i);
        kc.dXtop_B(i) =    tl.B_tol(i);
        kc.dYtop_B(i) =    tl.B_tol(i);
        kc.dZtop_B(i) =    tl.B_tol(i);
        kc.dXbot_B(i) =    tl.B_tol(i);
        kc.dYbot_B(i) =    tl.B_tol(i);
        kc.dZbot_B(i) =    tl.B_tol(i);
        % Groove
        kc.Heightv(i) = kc.Vh(i)+ tl.Vht(i);
        kc.Orient(i) = kc.or(i)+ tl.Or(i);
        kc.Halfa(2*i-1) = Halfa_nom(i)+ tl.Vang(i);
        kc.Halfa(2*i) = Halfa_nom(i)+ tl.Vang(i);
        kc.dXpin_G(i) = tl.V_tol(i);
        kc.dYpin_G(i) = tl.V_tol(i); 
        kc.dZpin_G(i) = tl.V_tol(i);     
    end
elseif (tg.solve_montecarlo)
    for i = 1:3
        % Ball
        kc.Diam(i) =       normrnd(kc.Db(i), tl.Db(i)/3);
        kc.Circ(2*i-1) =   normrnd(0, tl.Circ(i)/3);
        kc.Circ(2*i) =     normrnd(0, tl.Circ(i)/3);
        kc.dXtop_B(i) =    normrnd(0, tl.B_tol(i)/3);
        kc.dYtop_B(i) =    normrnd(0, tl.B_tol(i)/3);
        kc.dZtop_B(i) =    normrnd(0, tl.B_tol(i)/3);
        kc.dXbot_B(i) =    normrnd(0, tl.B_tol(i)/3);
        kc.dYbot_B(i) =    normrnd(0, tl.B_tol(i)/3);
        kc.dZbot_B(i) =    normrnd(0, tl.B_tol(i)/3);
        % Groove
        kc.Heightv(i) = normrnd(kc.Vh(i), tl.Vht(i)/3);
        kc.Orient(i) = normrnd(kc.or(i), tl.Or(i)/3);
        kc.Halfa(2*i-1) = normrnd(Halfa_nom(i), tl.Vang(i)/3);
        kc.Halfa(2*i) = normrnd(Halfa_nom(i), tl.Vang(i)/3);
        kc.dXpin_G(i) = normrnd(0, tl.V_tol(i)/3);
        kc.dYpin_G(i) = normrnd(0, tl.V_tol(i)/3);
        kc.dZpin_G(i) = normrnd(0, tl.V_tol(i)/3);
    end
else
    for i = 1:3
        % Ball
        kc.Diam(i) =       kc.Db(i);
        kc.Circ(2*i-1) =   0;
        kc.Circ(2*i) =     0;
        kc.dXtop_B(i) =    0;
        kc.dYtop_B(i) =    0;
        kc.dZtop_B(i) =    0;
        kc.dXbot_B(i) =    0;
        kc.dYbot_B(i) =    0;
        kc.dZbot_B(i) =    0;
        % Groove
        kc.Heightv(i) = kc.Vh(i);
        kc.Orient(i) = kc.or(i);
        kc.Halfa(2*i-1) = Halfa_nom(i);
        kc.Halfa(2*i) = Halfa_nom(i);
        kc.dXpin_G(i) = 0;
        kc.dYpin_G(i) = 0; 
        kc.dZpin_G(i) = 0; 
    end
end
    
    %% GEOMETRY
    if (tg.bypass_geometric_variance)
        % Solve nominal ball contacts, direction cosines, and contact points
        % analytically. Ball centers do not move as they are nominal.
        kc_g = kc;
        kc_g.Pb = kc_g.Pct; 
        [kc_g.T_Vees, T_reo] = vee_plane_transform(kc_g.Pb, kc_g.Db, Halfa_nom*180/pi, kc_g.Orient, kc_g.Vreo);
        for i = 1:6
            kc_g.Pc(1:3,i) = kc_g.T_Vees{i}(1:3,4);
            kc_g.dc(1:3,i) = [kc_g.T_Vees{i}(3,2),kc_g.T_Vees{i}(1,3),kc_g.T_Vees{i}(2,1)]';
        end
        for j = 1:3
            T_reo_rot = T_reo{j};
            T_reo_rot(1:3,4) = zeros(3,1); % Transform preloads about ball centers.
            if (tg.F_P_is_equal ~= 2)
                kc_g.Preld{j}.P = data_transform(T_reo_rot, kc_g.Preld{j}.P')'; 
            end
        end
    else
        % Solve system of equations numerically to return contact points.
        % Uses geometric variance. Limited to planar couplings only!
        kc_g = Rest_Pos(kc, tl, tg);
    end
    %% FORCE INDUCED ERRORS (Using Geometric error as input)
    [kc_ld, ~, error_msg] = Force_Pos(kc_g, kc_g.Ld, kc_g.Preld, tl, tg);
    kc_f = kc_ld; % Store both load and preload cases of kc.
    %% ERROR MSG
    err_dialogue{1} = 'Coupling Separation, reduce the distance of the applied force relative to the center. Script Terminated';
    err_dialogue{2} = 'Coupling Contacts Failed in Compression due to High Stress. Lower applied load or preload forces, or select a stronger material. Script Terminated';
    err_dialogue{3} = 'Coupling Contacts Failed in Shear due to High Stress. Lower applied load or preload forces, or select a stronger material. Script Terminated';
    if (any(error_msg))
        idx = error_msg ~= 0;
        if (~tg.bypass_errors)
            errordlg(err_dialogue{idx}, 'Error'); % Display Error
        end
        T_Tot = eye(4);
        return % Return even if error dialogue not shown.
    else
    end
    %% COMBINE ERRORS
    T_Tot = kc_g.T_GC_BC * kc_ld.T_GC_BC * T_Q;
    %% APPLY TRANSFORMATION TO INPUT CSYS
    % Apply transform to input, custom, or default Csys
    kc_g = KC_TRANSFORM(kc_g,T_Tot);
    kc_f = KC_TRANSFORM(kc_f,T_Tot);
end