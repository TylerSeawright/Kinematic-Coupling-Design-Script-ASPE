function T = orientTriangle(Pb, center, origin, normal, direction)

    p1 = Pb(1:3,1);
    p2 = Pb(1:3,2);
    p3 = Pb(1:3,3);

    % Ensure all vectors are column vectors
    p1 = p1(:); p2 = p2(:); p3 = p3(:); center = center(:);
    origin = origin(:); normal = normal(:); direction = direction(:);

    % Normalize the normal and direction vectors
    normal = normal / norm(normal);
    direction = direction / norm(direction);

    % Step 1: Translate the triangle to place its center at the origin
    T_center = eye(4);
    T_center(1:3, 4) = -center;

    % Apply the translation
    p1_centered = T_center * [p1; 1];
    p2_centered = T_center * [p2; 1];
    p3_centered = T_center * [p3; 1];

    % Step 2: Rotate the triangle to align its normal with the specified normal
    current_normal = cross(p2_centered(1:3) - p1_centered(1:3), p3_centered(1:3) - p1_centered(1:3));
    current_normal = current_normal / norm(current_normal);
    axis = cross(current_normal, normal);
    angle = acos(dot(current_normal, normal));
    R = rotationMatrix(axis, angle);
    T_rot = [R, zeros(3, 1); 0, 0, 0, 1];

    % Apply the rotation
    p1_rotated = T_rot * p1_centered;
    p3_rotated = T_rot * p3_centered;

    % Step 3: Rotate to align p3 with the direction vector
    p3_direction = p3_rotated(1:3) - p1_rotated(1:3);
    p3_direction = p3_direction / norm(p3_direction);
    axis = cross(p3_direction, direction);
    angle = acos(dot(p3_direction, direction));
    R = rotationMatrix(axis, angle);
    T_rot2 = [R, zeros(3, 1); 0, 0, 0, 1];

    % Step 4: Translate the triangle to place its center at the specified origin
    T_origin = eye(4);
    T_origin(1:3, 4) = origin;

    % Combine all transformations
    T = T_origin * T_rot2 * T_rot * T_center;

    % Nested function to compute rotation matrix given an axis and an angle
    function R = rotationMatrix(axis, angle)
        axis = axis / norm(axis); % Ensure the axis is a unit vector
        K = [0, -axis(3), axis(2); axis(3), 0, -axis(1); -axis(2), axis(1), 0];
        R = eye(3) + sin(angle) * K + (1 - cos(angle)) * K^2;
    end
    
if any(isnan(T)), T = eye(4); end

end
