% Class to define Kinematic Coupling as an Object
classdef KC_TOG
   properties
    %% GUI TOGGLES
    solve_nominal = 0;              % Control if Nominal simulation runs
    solve_specific = 0;             % Control if Specific simulation runs
    solve_montecarlo = 0;           % Control if MonteCarlo simulation runs
    solve_covariance = 0;           % Control if Covariance simulation runs
    rotinputs = 0;                  % Control if inputs are transformed by inR and inP values.
    exact_contacts = 0;             % Control if exact contacts are used. WARNING, bypasses geometric error solution.
    FL_is_Coupling_Centroid = 0;    % Control if F_L is located at coupling centroid
    F_P_is_equal = 0;               % Control if all F_P magnitudes are equal. 1 for all equal, 0 for specific vectors, 2 for solve via superpositon of load in first column
    use_mass = 0;                   % Use ball and vee plate mass and COM in force balance
    mat_lib_external = 0;           % Control if external imported material library is used, else use default
    canoe_ball = 0;                 % Control if canoe ball is used
    solve_in_input_csys = 0;        % Control if plots and results are in input coordinate system
    solve_in_custom_csys = 0;       % Control if plots and results are in custom coordinate system
    solve_in_C_csys = 0;            % Control if plots and results are in centroid coordinate system
    subtract_preload_deflection = 0;% Control if preload deflection is subtracted from clamp force induced error to simulate only loading and unloading clamp.
    visualize_in_blender = 0;       % Control if visualization in blender is turned on
    visualize_resultant_forces = 0; % Control if resultant forces are calculated and displayed in blender viewport
    threeD_coupling = 0;            % Control if 3D coupling is enabled. Save calculation speed by only enabling when vee_reorient vectors are used
    time_script = 0;                % Control if script is timed
    verify_inputs = 0;              % Control if inputs are verified before running the script
    bypass_errors = 0;              % Control if error messages are bypassed. Use at your own risk.
    solve_force_location_boundary = 0;  % Control if force location bounds are solved that induce clamp separation.
    bypass_geometric_variance = 1;  % Control if nominal geometry resting position is solved analytically rather than numerically. 

    exaggerated_plot = 0;           % Control if output exaggerated error plot of geometry is generated
    use_friction = 0;               % Control if friction is considered in force balance
    solve_stiffness = 0;            % Control if stiffness is solved for each DOF
   end
end