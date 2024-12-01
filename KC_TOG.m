% Class to define Kinematic Coupling as an Object
classdef KC_TOG
   properties
    %% GUI TOGGLES
    solve_nominal = 0;              % Control if Nominal simulation runs
    solve_specific = 0;             % Control if Specific simulation runs
    rotinputs = 0;                  % Control if inputs are transformed by inR and inP values.
    FL_is_Coupling_Centroid = 0;    % Control if F_L is located at coupling centroid
    F_P_is_equal = 0;               % Control if all F_P magnitudes are equal. 1 for all equal, 0 for specific vectors, 2 for solve via superpositon of load in first column
    use_mass = 0;                   % Use ball and vee plate mass and COM in force balance
    mat_lib_external = 0;           % Control if external imported material library is used, else use default
    canoe_ball = 0;                 % Control if canoe ball is used
    solve_in_input_csys = 0;        % Control if plots and results are in input coordinate system
    solve_in_C_csys = 0;            % Control if plots and results are in centroid coordinate system
    subtract_preload_deflection = 0;% Control if preload deflection is subtracted from clamp force induced error to simulate only loading and unloading clamp.
    threeD_coupling = 0;            % Control if 3D coupling is enabled. Save calculation speed by only enabling when vee_reorient vectors are used
    verify_inputs = 0;              % Control if inputs are verified before running the script
    bypass_errors = 0;              % Control if error messages are bypassed. Use at your own risk.
    use_structural_displacement = 0; % Control if structural deformation is applied to original ball and vee positions (Requires independent analysis with rigid balls and vees).
    use_thermal_displacement = 0;    % Control if thermal expansion is applied to original ball and vee positions (Requires independent analysis).
    exaggerated_plot = 0;           % Control if output exaggerated error plot of geometry is generated
    use_friction = 0;               % Control if friction is considered in force balance
   end
end