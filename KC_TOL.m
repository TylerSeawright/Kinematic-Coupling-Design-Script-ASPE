% Class to define Kinematic Coupling as an Object
classdef KC_TOL
   properties
    % - Tolerances
    Db = [0,0,0];     % mm
    Circ = [0,0,0];     % mm
    B_tol = [0,0,0];      % mm
    Vht = [0,0,0];  % mm
    Or = [0,0,0];   % rad
    Vang = [0,0,0];    % rad
    V_tol = [0,0,0];      % mm
    F_L = [0,0,0];      % N
    F_P = [0,0,0];      % N
    FL_loc = [0,0,0];   % mm
   end
end