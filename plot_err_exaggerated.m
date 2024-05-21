function plot_err_exaggerated(kc, T0, T1, exfac, plot_title)
    %% Format Data

    % Csys Plot Data
    C = T0(1:3,4)'
    C_nom = data_transform(T0,COORD()')'
    C_err_exagg = data_transform(T1 * Tform(exfac*ones(1,3),4),(COORD()./exfac)')'
    
    %% Figure Plots
    f = figure("name","KC GEOMETRY PLOT");
    hold on

    % Plot Coupling Centroid
    plot3(C(1),C(2),C(3),'og', 'MarkerSize', 10);
    plot3(C_nom(1,:),C_nom(2,:),C_nom(3,:),'-g', 'LineWidth', 3)
    plot3(C_err_exagg(1,:),C_err_exagg(2,:),C_err_exagg(3,:),'-r', 'LineWidth', 3)
    
    hold off
    %% Figure Format
    axis square
    axis equal
    zlim(xlim);
    title(plot_title);
    xlabel("X [mm]")
    ylabel("Y [mm]")
    zlabel("Z [mm]")
    view(3)
    grid("on")
    hold off
end