function T = Tform(v, d)    % HTM Forming Function
    if d == 0               % Location transform
        T = eye(4);         % v must be input as vector
        T(1:3,4) = v(1:3)';
    elseif d == 3               % Rotate about x axis
        T = [cos(v) -sin(v) 0 0; 
              sin(v) cos(v) 0 0;
              0 0 1 0; 
              0 0 0 1];
    elseif d == 2               % Rotate about y axis
        T = [cos(v) 0 sin(v) 0; 
              0 1 0 0;
              -sin(v) 0 cos(v) 0;
              0 0 0 1];
    elseif d == 1               % Rotate about z axis
        T = [1 0 0 0; 
          0 cos(v) -sin(v) 0;
          0 sin(v) cos(v) 0; 
          0 0 0 1];
    elseif (d == 4) % Scale transformation by sx, sy, sz
        if (size(v,2) == 3)
            T = eye(4);
            T(1,1) = v(1);
            T(2,2) = v(2);
            T(3,3) = v(3);
        end
    else 
        T = eye(4);
    end
end