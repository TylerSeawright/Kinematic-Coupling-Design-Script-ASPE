% KC_COUPLING.m

function [kc_g, kc_f, T_Tot] = KC_COUPLING(tg, kc, tl, T_input)

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
            kc_g.dc(1:3,i) = extractDirectionCosines(kc_g.T_Vees{i});
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
        % Barraja Solution
        kc_g = Rest_Pos(kc, tl, tg);
    end
    
    % Apply custom ball center displacements to geometric error case. 
    if(tg.use_structural_displacement)
        kc_g = custom_ball_disp(kc_g, kc_g.struct_disp_ball);
    end
    if(tg.use_thermal_displacement)
        kc_g = custom_ball_disp(kc_g, kc_g.therm_disp_ball);
    end

    %% FORCE INDUCED ERRORS (Using Geometric error as input)
    [kc_f, ~, error_msg] = Force_Pos(kc_g, tl, tg);
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

    %% POI Calculations
    % POI error is the error transform to POI with nominal transform removed.
    for i = 1:size(kc.poi,1)
        % Determine Errored POI's
        kc_g.Ppoi(i,:) = data_transform(kc_g.T_GC_BC, kc.poi(i,:));
        kc_f.Ppoi(i,:) = data_transform(kc_f.T_GC_BC, kc.poi(i,:));
        % Determine Error components at each POI
        % 1) Apply offset by POI for term.
        % 2) Apply Error T_GC_BC to solve Errored POI
        % 3) Subtract POI from Errored POI for Error Components.
        kc_g.poi_err(i,1:3) = kc_g.C_err(1:3);
        kc_g.poi_err(i,4:6) = kc_g.Ppoi(i,:) - kc.poi(i,:);
        kc_f.poi_err(i,1:3) = kc_f.C_err(1:3);
        kc_f.poi_err(i,4:6) = kc_f.Ppoi(i,:) - kc.poi(i,:);
    end
    %% APPLY TRANSFORMATION TO INPUT CSYS
    inv_T_input = T_input;

    % Apply transform to input, custom, or default Csys
    T_Tot = inv_T_input * kc_g.T_GC_BC * kc_f.T_GC_BC;
    kc_g = KC_TRANSFORM(kc_g,inv_T_input);
    kc_f = KC_TRANSFORM(kc_f,inv_T_input);

end