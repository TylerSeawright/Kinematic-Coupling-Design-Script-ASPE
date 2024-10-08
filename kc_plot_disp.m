function f = kc_plot_disp(kc, tg, plot_title)
    
    %% Format Data
    
    Pb = kc.Pb;
    Db = kc.Db;
    C = kc.C_err; 
    T_v = kc.T_Vees;
    in_bd = kc.in_bd;
    poi = kc.poi;

    % Replace any third row element zero if any value is less than the tolerance
    tolerance = 1e-6; % Consider all values below tolerance [mm] as zero
    Pb(abs(Pb) < tolerance) = 0;
    C(abs(C) < tolerance) = 0;  

    % Csys Plot Data
    uvec_scale = 1/3;
    max_dist = 0;
    for i = 1:3
        dist = distance(Pb(:,i),C);
        if (dist > max_dist)
            max_dist = dist;
        end
    end
    BC_Csys = uvec_scale * max_dist * data_transform(kc.T_GC_BC,COORD()')' + C;

    
    %% Figure Plots
    f = figure("name","KC GEOMETRY PLOT");
    hold on

    % Plot Ball Meshes
    for i = 1:2:6
        j = (i+1)/2; bl_offset = Db(j);
        plotSphereAndPlane(Db(j), Pb(1:3,j), T_v{i}, T_v{i+1})
        text(T_v{i}(1,4), T_v{i}(2,4), T_v{i}(3,4)-bl_offset, sprintf("dPc %d: %.1f um",i, 1e3*in_bd(i)),'HorizontalAlignment', 'right', 'VerticalAlignment', 'bottom', 'color','r')
        text(T_v{i+1}(1,4), T_v{i+1}(2,4), T_v{i+1}(3,4)-bl_offset, sprintf("dPc %d: %.1f um",i+1, 1e3*in_bd(i+1)),'HorizontalAlignment', 'right', 'VerticalAlignment', 'bottom', 'color','r')
    end
    % Plot Ball Centers
    plot3(Pb(1,1:3), Pb(2,1:3), Pb(3,1:3),'ro'); % Plot Coupling Triangle
    for i = 1:3
        ball_label = sprintf('B%d', i);
        bl_offset = Db(i)/2;
        text(Pb(1,i)-bl_offset, Pb(2,i)+bl_offset, Pb(3,i)+bl_offset, ball_label,'HorizontalAlignment', 'right', 'VerticalAlignment', 'bottom')
    end
    % Plot Coupling Triangle
    plot3([Pb(1,1:3), Pb(1,1)], [Pb(2,1:3),Pb(2,1)], [Pb(3,1:3), Pb(3,1)],'-b'); % Plot Coupling Triangle
    % Plot Coupling Centroid
    plot3(C(1),C(2), C(3),'og', 'MarkerSize', 10);
    plot3(BC_Csys(1,:),BC_Csys(2,:),BC_Csys(3,:),'-g', 'LineWidth', 3)
    text(C(4) + bl_offset/2, C(5) + bl_offset, C(6)+ 3*bl_offset, sprintf("C Error:\n(%.1f, %.1f, %.1f)um\n(%.1f, %.1f, %.1f)urad",1e3*C(4),1e3*C(5),1e3*C(6),1e6*C(1),1e6*C(2),1e6*C(3)), 'color', 'k')

    % Plot Angle Bisectors
    for i = 1:3
        plot3([C(1),Pb(1,i)]',[C(2),Pb(2,i)]',[C(3),Pb(3,i)]',"--k");
    end
    % Plot Points Of Interest
    for i = 1:size(kc.poi,1)
        plot3(kc.poi(i,1),kc.poi(i,2),kc.poi(i,3), "*k", 'MarkerSize', 8, 'LineWidth', 2)
        text(kc.poi(i,1) + bl_offset/2, kc.poi(i,2) + bl_offset, kc.poi(i,3) + 4*bl_offset, sprintf('POI Error:\n(%.1f, %.1f, %.1f)um\n(%.1f, %.1f, %.1f)urad', 1e3*kc.poi_err(4),1e3*kc.poi_err(5),1e3*kc.poi_err(6),1e6*kc.poi_err(1),1e6*kc.poi_err(2),1e6*kc.poi_err(3)), 'color', 'k')
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