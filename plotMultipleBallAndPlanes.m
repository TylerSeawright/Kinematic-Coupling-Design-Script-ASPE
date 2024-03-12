function plotMultipleBallAndPlanes(ballCenters, ballDiameters, planeHTMs, couplingCentroid)
    % Check inputs
    if length(ballDiameters) ~= 3 || size(planeHTMs, 1) ~= 3 || size(planeHTMs, 2) ~= 2
        error('Invalid input dimensions. There must be 3 balls and 3 sets of 2 plane HTMs.');
    end

    % Create a new figure
    figure;

    % Loop through each set of ball and planes
    for i = 1:3
        % Plot each ball
        plotBall(ballCenters(i, :), ballDiameters(i));

        % Plot the center of the ball
        plot3(ballCenters(i, 1), ballCenters(i, 2), ballCenters(i, 3), 'ko', 'MarkerSize', 10, 'MarkerFaceColor', 'k');

        % Plot dashed lines from ball centers to the coupling centroid
        line([ballCenters(i, 1), couplingCentroid(1)], ...
             [ballCenters(i, 2), couplingCentroid(2)], ...
             [ballCenters(i, 3), couplingCentroid(3)], 'Color', 'k', 'LineStyle', '--');

        % Plot the two planes associated with this ball
        for j = 1:2
            plotPlane(planeHTMs{i, j}, ballDiameters(i), rand(1,3)); % Random color for each plane
        end
    end

    % Set common plot properties
    xlabel('X-axis');
    ylabel('Y-axis');
    zlabel('Z-axis');
    title('Multiple Balls, Planes, and Coupling Centroid');
    axis equal;
    view(3);
    grid on;
end

% Include the previously defined functions plotBall, plotPlane, and applyHTM
function plotBall(center, diameter)
    % Plot a ball at the given center with the given diameter
    [x, y, z] = sphere(50);
    x = diameter/2 * x + center(1);
    y = diameter/2 * y + center(2);
    z = diameter/2 * z + center(3);
    surf(x, y, z, 'FaceColor', 'interp', 'EdgeColor', 'none');
    hold on;
end

function plotPlane(HTM, sphereDiameter, color)
    % Create a basic plane (e.g., a square)
    planeSize = max(sphereDiameter, 10); % Ensure the plane is large enough
    [px, py] = meshgrid(linspace(-planeSize/2, planeSize/2, 2), ...
                        linspace(-planeSize/2, planeSize/2, 2));
    pz = zeros(size(px)); % Flat plane in the XY plane

    % Apply the HTM to transform the plane
    transformedPlane = applyHTM(HTM, [px(:), py(:), pz(:)]);
    pxTransformed = reshape(transformedPlane(:, 1), size(px));
    pyTransformed = reshape(transformedPlane(:, 2), size(py));
    pzTransformed = reshape(transformedPlane(:, 3), size(pz));

    % Plot the transformed plane
    surf(pxTransformed, pyTransformed, pzTransformed, 'FaceColor', color, 'FaceAlpha', 0.5);

    % Calculate and plot the center of the plane
    planeCenter = applyHTM(HTM, [0, 0, 0]);
    plot3(planeCenter(1), planeCenter(2), planeCenter(3), 'ro', 'MarkerSize', 10, 'LineWidth', 2);
end