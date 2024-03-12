function S = plotSphere(center, diameter)
    % Validate input
    if length(center) ~= 3 || ~isscalar(diameter)
        error('Center must be a 3-element vector and radius must be a scalar.');
    end
    
    radius = diameter./2;

    % Generate data for a sphere
    [nx, ny, nz] = sphere;

    % Scale and shift the coordinates for the sphere
    x = radius * nx + center(1);
    y = radius * ny + center(2);
    z = radius * nz + center(3);

    S = [x;y;z];
    surf(S)
end
