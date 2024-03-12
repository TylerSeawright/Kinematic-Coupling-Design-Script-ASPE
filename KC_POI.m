% Class to define Kinematic Coupling as an Object
classdef KC_POI
   properties
    POI = [0,0,0]'; % POI [mm] is a set of points of interest to solve error about.
    POI_unc; % POI uncertainty [mm] set of points relative to coupling centroid by application assembly
   end
end