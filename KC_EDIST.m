% Class to define Kinematic Coupling Statistics
% Every error distribution contains up to 6DOF and with a mean and standard
% distribution for each term and the magnitudes.
% Rotation components are distinguished with "er" and position with "e".
classdef KC_EDIST
   properties
      data;
      mu_e; sig_e;
      mu_er; sig_er;
   end
end