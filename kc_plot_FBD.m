function f = kc_plot_FBD(kc, tg, plot_title)
    
    %% Format Data
    
    Pb = kc.Pct;
    Db = kc.Db;
    C = kc.C; 
    FL = kc.Ld.P;
    for i = 1:3
        PL(1:3,i) = kc.Preld{i}.P;
    end
    FL_loc = kc.Ld.P_loc;
    if(tg.F_P_is_equal ==1 || tg.F_P_is_equal ==0)
        for i = 1:3
            PL_loc(1:3,i) = kc.Pct(1:3,i)+kc.Preld{i}.P_loc;
        end
    elseif(tg.F_P_is_equal==2)
        for i = 1:3
            PL_loc(1:3,i) = kc.Preld{i}.P_loc;
        end
    end
    T_v = kc.T_Vees;

    % Replace any third row element zero if any value is less than the tolerance
    tolerance = 1e-6; % Consider all values below tolerance [mm] as zero
    Pb(abs(Pb) < tolerance) = 0;
    C(abs(C) < tolerance) = 0;  
    FL_loc(abs(FL_loc) < tolerance) = 0;  

    % Normalize Force Data
    FL_unit = FL./norm(FL);
    uvec_scale = 1/3;
    max_dist = 0;
    for i = 1:3
        dist = distance(Pb(:,i),C);
        if (dist > max_dist)
            max_dist = dist;
        end
    end
    FL_scale = -uvec_scale * max_dist .* [[0,0,0]', FL_unit];
    FL_scale = FL_scale + FL_loc;
    for i = 1:3
        PL_unit(1:3,i) = PL(1:3,i)./max(vecnorm(PL(1:3,:), 2, 1));
        PL_scale{i} = -uvec_scale * max_dist .* [[0,0,0]', PL_unit(1:3,i)] + PL_loc(1:3,i);
    end
    % Contact Force Data
    if (all(kc.RP~= 0))
        RP = 1;
        FR = zeros(3,12);
        maxRP = max(kc.RP);
        for i = 1:2:12
            j = (i+1)/2;
            FR_unit(j) = kc.RP(j) / maxRP; % Normalize to RP magnitudes
            FR_scale = -uvec_scale * max_dist .* [[0,0,0]', [0,0,FR_unit(j)]'];
            FR(1:3,i:i+1) = data_transform(kc.T_Vees{(i+1)/2},FR_scale')';
        end
    else
        RP = 0;
    end

    % Csys Plot Data
    BC_Csys = uvec_scale * max_dist * data_transform(kc.T_GC_BC, COORD()')' + C;

    
    %% Figure Plots
    f = figure("name","KC GEOMETRY PLOT");
    hold on

    % Plot Ball Meshes
    for i = 1:2:6
        j = (i+1)/2; plotSphereAndPlane(Db(j), Pb(1:3,j), T_v{i}, T_v{i+1})
    end
    % Plot Ball Centers
    plot3(Pb(1,1:3), Pb(2,1:3), Pb(3,1:3),'ro'); % Plot Coupling Triangle
    for i = 1:3
        ball_label = sprintf('B%d', i);
        bl_offset = 2*Db(i)/3;
        text(Pb(1,i)-bl_offset, Pb(2,i)+bl_offset, Pb(3,i)+bl_offset, ball_label,'HorizontalAlignment', 'right', 'VerticalAlignment', 'bottom')
    end
    % Plot Coupling Triangle
    plot3([Pb(1,1:3), Pb(1,1)], [Pb(2,1:3),Pb(2,1)], [Pb(3,1:3), Pb(3,1)],'-b'); % Plot Coupling Triangle
    % Plot Coupling Centroid
    plot3(C(1),C(2), C(3),'og', 'MarkerSize', 10);
    plot3(BC_Csys(1,:),BC_Csys(2,:),BC_Csys(3,:),'-g', 'LineWidth', 3)
    text(C(1) - bl_offset, C(2) - bl_offset, C(3), "C", 'color', 'k')

    % Plot Force Input Location
    plot3(FL_loc(1),FL_loc(2), FL_loc(3), "*r", 'MarkerSize', 8, 'LineWidth', 2);
    plot3(FL_scale(1,:), FL_scale(2,:), FL_scale(3,:), "-r", 'LineWidth', 2);
    text(FL_loc(1) + bl_offset, FL_loc(2) + bl_offset, FL_loc(3) + bl_offset, sprintf('FL: %.1f N',norm(FL)), 'color', 'r')

    % Plot Preload Inputs
    if (tg.F_P_is_equal == 0 || tg.F_P_is_equal == 1)
        for i = 1:3
        PLx = PL_scale{i}(1,:); PLy = PL_scale{i}(2,:); PLz = PL_scale{i}(3,:);
        plot3(PLx,PLy, PLz, "-k", 'MarkerSize', 8, 'LineWidth', 2);
        plot3(PL_loc(1,i),PL_loc(2,i), PL_loc(3,i), "*k", 'MarkerSize', 8, 'LineWidth', 2);
        text(PL_loc(1,i) + bl_offset, PL_loc(2,i) + bl_offset, PL_loc(3,i) + 3*bl_offset, sprintf('PL: %.1f N',norm(PL(1:3,i))), 'color', 'k')   
        end
    elseif (tg.F_P_is_equal == 2)
        PLx = PL_scale{1}(1,:); PLy = PL_scale{1}(2,:); PLz = PL_scale{1}(3,:);
        plot3(PLx,PLy, PLz, "-k", 'MarkerSize', 8, 'LineWidth', 2);
        plot3(PL_loc(1),PL_loc(2), PL_loc(3), "*k", 'MarkerSize', 8, 'LineWidth', 2);
        text(PL_loc(1) + bl_offset, PL_loc(2) + bl_offset, PL_loc(3) + 3*bl_offset, sprintf('PL: %.1f N',norm(PL(1:3,1))), 'color', 'k')   
    end 
    % Plot Angle Bisectors
    for i = 1:3
        plot3([C(1),Pb(1,i)]',[C(2),Pb(2,i)]',[C(3),Pb(3,i)]',"--k");
    end
    % Plot Contact forces (if applicable)
    if(RP ~= 0)
        for i = 1:2:12
            j = (i+1)/2;
            plot3(FR(1,i:i+1), FR(2,i:i+1), FR(3,i:i+1), "-m", 'LineWidth', 2) % Plot Line
            plot3(FR(1,i), FR(2,i), FR(3,i), "*m", 'LineWidth', 1) % Plot Line
            text(FR(1,i+1), FR(2,i+1), FR(3,i+1), strcat( sprintf("R%d: ",j), strcat(num2str(round(kc.RP(j),1)), ' N')),'HorizontalAlignment', 'right', 'VerticalAlignment', 'bottom', 'color', 'm')
        end
    end

    % Plot Points Of Interest
    for i = 1:size(kc.poi,1)
        plot3(kc.poi(i,1),kc.poi(i,2),kc.poi(i,3), "*k", 'MarkerSize', 8, 'LineWidth', 2)
        text(kc.poi(i,1) + bl_offset, kc.poi(i,2) + bl_offset, kc.poi(i,3) + bl_offset, sprintf('POI: %d ', i), 'color', 'k')
    end
    %% Figure Format
    axis square
    axis equal
    zlim(xlim);
    % legend("Balls","Vees","Clamp Force Location","Clamp Force Vector","Angle Bisector")
    title(plot_title);
    xlabel("X [mm]")
    ylabel("Y [mm]")
    zlabel("Z [mm]")
    view(3)
    % Get the current axes
    % ax = gca;
    
    % Turn off grid lines along X and Y axes
    % ax.XGrid = 'off';
    % ax.YGrid = 'off';
    % 
    % ax.ZGrid = 'off';
    grid("on")
    hold off

end