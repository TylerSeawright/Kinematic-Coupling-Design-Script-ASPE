function M = Tform(v, d)    % HTM Forming Function
    if d == 0               % Location transform
        M = eye(4);         % v must be input as vector
        M(1:3,4) = v(1:3)';
    elseif d == 3               % Rotate about x axis
        M = [cos(v) -sin(v) 0 0; 
              sin(v) cos(v) 0 0;
              0 0 1 0; 
              0 0 0 1];
    elseif d == 2               % Rotate about y axis
        M = [cos(v) 0 sin(v) 0; 
              0 1 0 0;
              -sin(v) 0 cos(v) 0;
              0 0 0 1];
    elseif d == 1               % Rotate about z axis
        M = [1 0 0 0; 
          0 cos(v) -sin(v) 0;
          0 sin(v) cos(v) 0; 
          0 0 0 1];
    else 
        M = eye(4);
    end
end