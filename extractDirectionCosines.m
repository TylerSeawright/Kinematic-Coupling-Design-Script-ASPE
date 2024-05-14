function [dc] = extractDirectionCosines(rotationMatrix)
    % Validate the input matrix
    if ~isequal(size(rotationMatrix), [4, 4])
        error('Input must be a 4x4 matrix.');
    end

    % Extract the direction cosines
    % l - direction cosines along x-axis
    % m - direction cosines along y-axis
    % n - direction cosines along z-axis
    dc_x = -rotationMatrix(1, 3); % First column represents the x-axis
    dc_y = -rotationMatrix(2, 3); % Second column represents the y-axis
    dc_z = -rotationMatrix(3, 3); % Third column represents the z-axis
    dc = [dc_x;dc_y;dc_z];
end
