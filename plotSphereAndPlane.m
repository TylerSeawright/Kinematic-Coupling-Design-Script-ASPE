function plotSphereAndPlane(sphereDiameter, C, HTM1, HTM2)
    % Create and plot planes for each HTM
    plotSphere(C, sphereDiameter)
    plotPlane(HTM1, sphereDiameter, 'blue');
    plotPlane(HTM2, sphereDiameter, 'blue');
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
    plot3(planeCenter(1), planeCenter(2), planeCenter(3), 'r.', 'MarkerSize', 10, 'LineWidth', 2);
end

function transformedPoints = applyHTM(HTM, points)
    % Apply a Homogeneous Transformation Matrix to a set of points
    n = size(points, 1); % Number of points
    homogeneousPoints = [points, ones(n, 1)]; % Convert to homogeneous coordinates
    transformedPoints = (HTM * homogeneousPoints')'; % Apply the HTM
    transformedPoints = transformedPoints(:, 1:3); % Convert back to Cartesian coordinates
end
% Helper function to plot a sphere at a given center with a given diameter
function plotSphere(center, diameter)
    [x, y, z] = sphere(20);
    x = diameter/2 * x + center(1);
    y = diameter/2 * y + center(2);
    z = diameter/2 * z + center(3);
    surf(x, y, z, 'EdgeColor', 'none', 'FaceColor', [173/255, 216/255, 230/255]);
end