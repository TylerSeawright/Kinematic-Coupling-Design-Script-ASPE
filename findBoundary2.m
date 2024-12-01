function boundaryPoints = findBoundary2(R, step_size, tg, kc, tl, T_Q)

    % Coupling Triangle
    triangle = kc.Pct(1:2,:);

    % Refine Factor
    refine_factor = 10;
    % Convert triangle points to x and y arrays for inpolygon
    tri_x = triangle(1, :);
    tri_y = triangle(2, :);

    % Initial coarse grid
    rRange = linspace(0, R, step_size(1));
    theta = linspace(0, 2*pi, step_size(2));

    coarseBoundaryPoints = [];
    fineBoundaryPoints = [];

    for i = 1:length(theta)
        for j = round(length(rRange)/step_size(1)):length(rRange)
            x = rRange(j) * cos(theta(i));
            y = rRange(j) * sin(theta(i));

            % Skip points inside the triangle
            % ONLY USE FOR FORCES NORMAL TO BALL PLANE.
            % 3D FORCES RESULT IN SMALLER SAFE BOUNDS
            % if inpolygon(x, y, tri_x, tri_y)
            %     continue;
            % end

            kc.Ld.P_loc(1:2) = [x,y];
            [kc_nf] = KC_COUPLING(tg, kc, tl, T_Q);
            result = kc_nf.clamp_separation;
            if result == 1
                coarseBoundaryPoints = [coarseBoundaryPoints; x, y];
                % for k = 1:refine_factor
                %     x2 = x - rRange(j) * cos(theta(i))/refine_factor;
                %     y2 = y - rRange(j) * sin(theta(i))/refine_factor;
                %     kc.Ld.P_loc(1:2) = [x2,y2];
                %     [~, kc_nf, ~] = KC_COUPLING(tg, kc, tl, T_Q);
                %     result2 = kc_nf.clamp_separation;
                %     if result2 == 0
                %        fineBoundaryPoints = [fineBoundaryPoints; x, y];
                %     end
                % end     
            break;
            end
        end
    end


    % Refine the grid around the coarse boundary
    boundaryPoints = coarseBoundaryPoints;%[];
    % for i = 1:size(coarseBoundaryPoints, 1)
    % 
    %     xRefine = linspace(coarseBoundaryPoints(i, 1) - 1, coarseBoundaryPoints(i, 1) + 1, refinementFactor);
    %     yRefine = linspace(coarseBoundaryPoints(i, 2) - 1, coarseBoundaryPoints(i, 2) + 1, refinementFactor);
    %     boundaryPoints = [boundaryPoints; getBoundaryPoints(xRefine, yRefine)];
    % end

    % Optimization Stats
    SamplePoints = i*j;
    SampleArea = pi*max(abs(rRange))^2;
    BoundarySize = length(boundaryPoints);
    fprintf("Optimization Stats:\n");
    fprintf('Sample Points: %d\n',SamplePoints);
    fprintf('Boundary Points: %d\n',BoundarySize);
    fprintf('Sample Area (mm^2): %.2f\n',SampleArea);
    fprintf('----------------------------------------\n')

    % Plotting the refined boundary
    marksize_fac = 1/50;
    marksize = round(R*marksize_fac);
    hold on
    plot(boundaryPoints(:, 1), boundaryPoints(:, 2), 'r-', 'LineWidth', 2);
    % plot(innerPoints(:, 1), innerPoints(:, 2), 'b.','MarkerSize',marksize);
    % Plot Coupling Triangle
    title('Refined Boundary between Pass and Fail');
    xlabel('X-axis');
    ylabel('Y-axis');
    grid on;
    axis equal
    hold off
end
