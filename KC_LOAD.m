% Class to define loads applied to Kinematic Coupling
classdef KC_LOAD
    properties
        P = zeros(1,3)'; % Applied Load
        P_loc = zeros(1,3)'; % Applied Load Location
        M = zeros(1,3)'; % Applied Moment
    end
end