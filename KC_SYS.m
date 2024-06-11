% Class to define Kinematic Coupling as an Object
classdef KC_SYS
   properties
      %% Inputs
      % Coupling Triangle
      Pct = zeros(3); % Aka input ball centers

      % Points of Interest
      % - Relative to origin of input coupling triangle.
      poi;
      
      % Ball Geometry
      Db = zeros(1,3);      % Ball diameter
      Rb2 = zeros(1,3);     % Ball radius (for canoe ball)
      
      % Vee Geometry
      Vg = pi/2.*ones(1,6); % Vee groove angles
      Vh = zeros(1,3);     % Vee height
      Vreo = zeros(3);      % Vee reorientation angles  
      DV = ones(1,2);       % Vee groove radius of curvature Rxx and Ryy (typically large to simulate flat plane)
      
      % Forces
      Ld = KC_LOAD;                         % Applied load
      Preld = {KC_LOAD,KC_LOAD,KC_LOAD};    % Preloads (standard place each over balls)

      % Materials
      Mball = zeros(3,6);   % Ball material holder
      Mvee = zeros(3,6);    % Vee Material holder
      sig_y_SF = 1;         % Compressive stress safety factor
      sig_tau_SF = 1;       % Shear stress safety factor
      
      %% INTERMEDIATE VALUES
      % These values are calculated and not to be set by users at any time.

      % Ball
        Diam = zeros(1,3);      % Ball diameter
        Circ = zeros(1,6);      % Ball circularity
        dXtop_B = zeros(1,3);   
        dYtop_B = zeros(1,3);
        dZtop_B = zeros(1,3);
        dXbot_B = zeros(1,3);
        dYbot_B = zeros(1,3);
        dZbot_B = zeros(1,3);
        % Groove
        Heightv = zeros(1,3);   % Vee vertex height from vee plate
        Orient = zeros(1,3);    % Angle of vee axis with respect to x axis
        Halfa = zeros(1,6);     % Half groove angle measured from vertical plane through vee axis
        dXpin_G = zeros(1,3);
        dYpin_G = zeros(1,3);
        dZpin_G = zeros(1,3); 
      %% Outputs
      Pb = zeros(3);        % Errored ball Centers
      or = zeros(3,1);      % Angle between balls relative to incenter
      dc = zeros(3,6);      % Direction cosines for each groove plane
      Pc = zeros(3,6);      % Contact points of each ball and groove plane
      C = zeros(1,3);       % Incenter of ball center coupling triangle
      RP = zeros(1,6);      % Resultant force magnitude at contact points
      in_bd = zeros(1,6);   % Deformation at ball contact
      dPc = zeros(3,6);     % Change in contact position
      dPb = zeros(3,3);     % Change in ball center position
      sigma = zeros(1,6);   % Compressive stress at contact point
      tau = zeros(1,6);     % Shear stress at contact point
      clamp_separation = 0; % Indicator if any of balls broke contact with groove
      C_err = zeros(1,6);   % Error of incenter
      poi_err;              % Error at each POI, nx6 matrix.
      T_GC_BC = eye(4);     % Transform between ball and groove coordinate systems (total error)
      T_Vees = cell(6,1);   % Trasform matrices describing groove plane position and orientation
   end
end