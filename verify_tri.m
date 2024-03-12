% verify_tri.m
% This function evaluates if three input points form a triangle.

function v = verify_tri(Pb)
    v = 1; % If Pb forms a triangle, v = 1. Else, v = 0;

    % Ensure the points are column vectors
    P1 = Pb(1:3,1);
    P2 = Pb(1:3,2);
    P3 = Pb(1:3,3);
    
    % Tolerance for floating-point comparisons
    tol = 1e-7;
    
    % Check condition 1: The points are not the same
    if norm(P1 - P2) < tol || norm(P2 - P3) < tol || norm(P1 - P3) < tol
        v = 0;
        % error('Two or more input points are at the same position.');
    end

    % Check condition 2: The points are not collinear
    % This can be checked by finding the cross product of the vectors (P2-P1) and (P3-P1)
    % If the points are collinear, the cross product will be a zero vector
    if norm(cross(P2 - P1, P3 - P1)) < tol
        v = 0;
        % error('The input points are collinear.');
    end

    % Check condition 3: P3 is not on the line defined by P1 and P2
    % This can be done by checking if the vector P3-P1 is a scalar multiple of P2-P1
    v1 = P2 - P1;
    v2 = P3 - P1;
    v1_unit = v1 / norm(v1);
    v2_unit = v2 / norm(v2);
    
    if abs(dot(v1_unit, v2_unit) - 1) < tol
        v = 0
        % error('P3 is on the line defined by P1 and P2. It cannot be aligned on the X axis alone.');
    end
    
    % disp('Points verification passed.');
end