% Class to define Kinematic Coupling as an Object
classdef KC_SYS
   properties
      %% Inputs
      % Coupling Triangle
      Pct = zeros(3); % Aka input ball centers
      
      % Ball Geometry
      Db = zeros(1,3); 
      Rb2 = zeros(1,3);
      
      % Vee Geometry
      Vg = pi/2.*ones(1,6);
      Vh = 0*ones(1,3);
      Vreo = zeros(3);
      DV = ones(1,2);
      
      % Forces
      Ld = KC_LOAD;
      Preld = {KC_LOAD,KC_LOAD,KC_LOAD};

      % Materials
      Mball = zeros(3,6);
      Mvee = zeros(3,6);
      sig_y_SF = 1;
      sig_tau_SF = 1;
      
      %% INTERMEDIATE VALUES
      % Ball
        Diam = zeros(1,3);
        Circ = zeros(1,6);
        dXtop_B = zeros(1,3);
        dYtop_B = zeros(1,3);
        dZtop_B = zeros(1,3);
        dXbot_B = zeros(1,3);
        dYbot_B = zeros(1,3);
        dZbot_B = zeros(1,3);
        % Groove
        Heightv = zeros(1,3);
        Orient = zeros(1,3);
        Halfa = zeros(1,6);
        dXpin_G = zeros(1,3);
        dYpin_G = zeros(1,3);
        dZpin_G = zeros(1,3); 
      %% Outputs
      Pb = zeros(3);
      or = zeros(3,1);
      dc = zeros(3,6);
      Pc = zeros(3,6);
      C = zeros(1,3);
      RP = zeros(1,6); % Resultant Force Magnitude at Contacts
      in_bd = zeros(1,6);
      dPc = zeros(3,6);
      dPb = zeros(3,3);
      sigma = zeros(1,6);
      tau = zeros(1,6);
      clamp_separation = 0;
      C_err = zeros(1,6);
      T_GC_BC = eye(4);
      T_Vees = cell(6,1);
   end
end