% KC_COUPLING.m

function [kc_tot] = KC_COUPLING(tg, kc, tl, T_input)

    %% KC SETUP
    Halfa_nom = (kc.Vg / 2) * pi/180; % Half angles of vee groove defined by V_groove_ang
    for i = 1:3
        % Ball
        kc.Diam(i) = kc.Db(i);
        % Groove
        kc.Heightv(i) = kc.Vh(i);
        kc.Orient(i) = kc.or(i);
        kc.Halfa(2*i-1) = Halfa_nom(i);
        kc.Halfa(2*i) = Halfa_nom(i);
    end
    %% GEOMETRY
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
    % Barraja Solution for Planar Couplings Removed 9/7/24. TS.
    
    % Apply custom ball center displacements to geometric error case. 
    if(tg.use_structural_displacement)
        kc_g = custom_ball_disp(kc_g, kc_g.struct_disp_ball);
    end
    if(tg.use_thermal_displacement)
        kc_g = custom_ball_disp(kc_g, kc_g.therm_disp_ball);
    end

    %% FORCE INDUCED ERRORS (Using Geometric error as input)
    [kc_f, error_msg] = Force_Pos(kc_g, tg);
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

    % Apply transform to input, custom, or default Csys
    T_Tot = T_input * kc_g.T_GC_BC * kc_f.T_GC_BC;
    kc_g = KC_TRANSFORM(kc_g,T_input);
    kc_f = KC_TRANSFORM(kc_f,T_input);

    % Solve KC with Total Error
    % Using KC with force data transformed by geometric and force induced errors.
    kc_tot = KC_TRANSFORM(kc_f, kc_g.T_GC_BC);
end