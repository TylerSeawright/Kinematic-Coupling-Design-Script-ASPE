function T = orientTriangle(Pb, C)

desiredOrigin = [0,0,0]; % Origin
desiredNormal = [0,0,1]; % Z axis
desiredAxis = [1,0,0]; % X axis

% Rotate plane of ball centers to XY plane
T_A_B = rotatePlaneToNormal(Pb, desiredNormal);

% Locate triangle incenter to desired origin
C_B = desiredOrigin - data_transform(T_A_B, C')';
T_B_C = Tform(C_B', 0);

% Rotate triangle to place B3 on desired axis
B3_A = Pb(:,3);
B3_C = data_transform(T_B_C*T_A_B, B3_A')';
B3_ang = vec_ang(B3_C,desiredAxis);
T_C_D = Tform(B3_ang, 3); 

T = T_C_D * T_B_C * T_A_B;

% Check B3 is on positive X axis. If not, rotate the system 180deg to place
% on X axis.
B3_check = data_transform(T,Pb(:,3)')';
if (B3_check(1) < 0)
    T_z_180 = Tform(pi,3);
    T = T_z_180 * T;
end

function T = rotatePlaneToNormal(Pb, desiredNormal)
    % Extract points
    p1 = Pb(:,1);
    p2 = Pb(:,2);
    p3 = Pb(:,3);

    % Ensure all vectors are column vectors
    p1 = p1(:); p2 = p2(:); p3 = p3(:); desiredNormal = desiredNormal(:);

    % Normalize the desired normal vector
    desiredNormal = desiredNormal / norm(desiredNormal);

    % Calculate the current normal of the plane
    currentNormal = cross(p2 - p1, p3 - p1);
    currentNormal = currentNormal / norm(currentNormal);

    % Calculate the axis of rotation (cross product of the two normals)
    rotationAxis = cross(currentNormal, desiredNormal);
    rotationAxisNorm = norm(rotationAxis);

    % Check for the case when the normals are parallel or anti-parallel
    if rotationAxisNorm < eps % They are parallel or anti-parallel
        if dot(currentNormal, desiredNormal) > 0
            % No rotation needed
            R = eye(3);
        else
            % 180 degrees rotation around an arbitrary axis perpendicular to the normal
            % Here, finding such an axis
            if abs(currentNormal(1)) < abs(currentNormal(3))
                arbitraryAxis = [1, 0, 0];
            else
                arbitraryAxis = [0, 0, 1];
            end
            rotationAxis = cross(currentNormal, arbitraryAxis);
            rotationAxis = rotationAxis / norm(rotationAxis);
            R = rotationMatrix(rotationAxis, pi);
        end
    else
        rotationAxis = rotationAxis / rotationAxisNorm;
        % Calculate the angle between the two normals
        rotationAngle = acos(dot(currentNormal, desiredNormal) / (norm(currentNormal) * norm(desiredNormal)));

        % Compute the rotation matrix
        R = rotationMatrix(rotationAxis, rotationAngle);
    end

    % Create the homogeneous transformation matrix
    T = eye(4);
    T(1:3, 1:3) = R;

    % Nested function to compute rotation matrix given an axis and an angle
    function R = rotationMatrix(axis, angle)
        % Ensure the axis is a unit vector
        K = [0, -axis(3), axis(2); axis(3), 0, -axis(1); -axis(2), axis(1), 0];
        R = eye(3) + sin(angle) * K + (1 - cos(angle)) * K^2;
    end
    end
end
