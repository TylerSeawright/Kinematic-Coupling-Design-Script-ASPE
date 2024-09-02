% Configuration File
function [TG, KC, TL, N, T_custom] = config()
%% GUI INPUTS
solve_nominal = 0;              % Control if Nominal simulation runs
solve_specific = 1;             % Control if Specific simulation runs
solve_montecarlo = 0;           % Control if MonteCarlo simulation runs
solve_covariance = 0;           % Control if Covariance simulation runs

rotinputs = 0;                  % Control if inputs are transformed by inR and inP values.
FL_is_Coupling_Centroid = 1;    % Control if F_L is located at coupling centroid
F_P_is_equal = 2;               % Control if all F_P magnitudes are equal. 1 for all equal, 0 for specific vectors, 2 for solve via superposition of load in first column
mat_lib_external = 0;           % Control if external imported material library is used, else use default

solve_in_input_csys = 1;        % Control if plots and results are in input coordinate system
solve_in_custom_csys = 0;       % Control if plots and results are in custom coordinate system
solve_in_C_csys = 0;            % Control if plots and results are in centroid coordinate system. B3 center on x-axis and all balls on XY plane.

subtract_preload_deflection = 1;% Control if preload deflection is subtracted from clamp force induced error to simulate only loading and unloading clamp.

threeD_coupling = 1;            % Control if 3D coupling is enabled. Save calculation speed by only enabling when vee_reorient vectors are used
time_script = 0;                % Control if script is timed
verify_inputs = 0;              % Control if inputs are verified before running the script
bypass_errors = 0;              % Control if error messages are bypassed. Use at your own risk.
solve_force_location_boundary = 0;  % Control if force location bounds are solved that induce clamp separation.
bypass_geometric_variance = 1;  % Control if nominal geometry resting position is solved analytically rather than numerically. 

% Unsupported 6/10/24
use_structural_displacement = 0; % Control if structural deformation is applied to original ball and vee positions (Requires independent analysis with rigid balls and vees).
use_thermal_displacement = 0;    % Control if thermal expansion is applied to original ball and vee positions (Requires independent analysis).
exaggerated_plot = 0;           % Control if output exaggerated error plot of geometry is generated
use_friction = 0;               % Control if friction is considered in force balance
canoe_ball = 0;                 % Control if canoe ball is used
use_mass = 0;                   % Use ball and vee plate mass and COM in force balance

%% SCALES AND FACTORS
KC_type = 0; % Control type of KC, 0 for angular symmetry, 1 for isosceles, 2 for right, 3 for custom
% Type 0 use KC_radius(1) for KC_radius
% Type 1 use KC_radius(1) for triangle base and KC_radius(2) for height
% Type 2 use KC_radius(1) for triangle base
% Type 3 ignore KC_radius and use custom input (KC_custom_Pct)
KC_radius = [55,200];

% - Optional Rotation of KC from Input Csys. 
% Generally used for transforming a simple system such as symmetric 90
% degrees.
inRx = pi/2; inRy = 0; inRz = 0; % Rotation Angles
inP = [0,0,0]'; % Transformation Vector
%% GEOMETRY
% [mm] Nominal Coordinates of each ball center (triangle) in the 
% newtonian N frame stored as [x1, y1, z1; x2 ...]
% Note Nominal Ball centers must fall on XY plane. Z = 0.
% Custom Entered Ball Positions
KC_custom_Pct = [104, 55, 0; ...
                 -104, 55, 0;
                 0, -138, 0]'; 
% - Ball Bodies
Ball_dia_nom = 10*ones(1,3);      %[mm] Nominal Ball Diameters
Ball_R2 = 100 * ones(1,3);        % [mm] Ball major radii if using canoe balls (unsupported)

% - Groove Bodies
V_groove_ang = 90*ones(1,3);      % [deg] Nominal Vee Groove Angles
Vee_rad = 1e10*[1,1]';            % [mm], Large radius for vee groove -> flat, Rxx, Ryy
Vh = 0*ones(1,3);                 % [mm] vee hieght
vee_reorient = [0 0 0; 0 0 0; 0 0 0]; % [rad], controls vee orientation, [0,0,0] is vee pointing towards centroid. CHECK INPUT CSYS
%% FORCES
F_PL = [0 0 0; ... % F_PL are preload force vectors
        0 0 0;
        0 0 0]';
F_PL_loc = [0 0 0; ... % F_PL_loc are preload force position vectors relative to each ball center [x1, y1, z1; x2 ...]
            0 0 0;
            0 0 0]';
M_PL = [0,0,0]'; % M_PL is list of clamp preload moments applied to the ball pallet
F_L = [0 0 -25]'; % F_L is list of clamp loads at FL_loc [x1, y1, z1; x2 ...]
M_L = [0,0,0]'; % M_L is list of clamp moments applied to the ball pallet
F_L_loc = [0,0,0]'; % FL_loc is list of clamp load locations [x1, y1, z1; x2 ...]

% - Optional masses for heavy clamps.
mass_ball_plate = 0;
COM_ball_plate = [0,0,0]';
mass_vee_plate = 0;
COM_vee_plate = [0,0,0]';
%% POI
poi = [75,0,0]; % POI [mm] is a set of points of interest to solve error about in the input Csys.
%% MATERIALS
mu_f = 0;               % Coeff of friction between ball and vee materials, 0 for no friction
mat_index = [5,5];      % Variable to store which rows of material lib used. First index is ball, second is vee.
sig_y_SF = 1.0; % Yield Stress Safety Factor
sig_tau_SF = 1.0; % Shear Stress Safety Factor
%% CUSTOM ERROR SOURCES
% Apply custom displacements to ball and vee joints to simulate total
% error. An independent structural analysis is required and inputs for each
% ball center shall be provided by the user.

% Displacement matrix is a vector list of form [B1x, B2x, B3x; B1y ... ;
% ... B3z]
struct_disp_ball = [0,0,0;
                    0,0,0;
                    0,0,0];
therm_disp_ball =  [0,0,0;
                    0,0,0;
                    0,0,0];

%% TOLERANCES
Diam_tol = [0,0,0];     % mm
Circ_tol = [0,0,0];     % mm
B_pos_tol = [0,0,0];      % mm
V_pos_tol = [0,0,0];      % mm
Heightv_tol = [0,0,0];  % mm
Orient_tol = [0,0,0];   % rad
Halfa_tol = [0,0,0];    % rad
F_L_tol = [0,0,0];      % N
F_P_tol = [0,0,0];      % N
FL_loc_tol = [0,0,0];   % mm
%% MONTECARLO
N = 10; % Samples
%% CUSTOM CSYS
T_custom = eye(4);
%% NO EDITS PAST THIS LINE ...............................................
%% SET TOGGLES
TG = KC_TOG;

TG.solve_nominal = solve_nominal;
TG.solve_specific = solve_specific;
TG.solve_montecarlo = solve_montecarlo;
TG.solve_covariance = solve_covariance;

TG.rotinputs = rotinputs; 
TG.FL_is_Coupling_Centroid = FL_is_Coupling_Centroid;  
TG.F_P_is_equal = F_P_is_equal;
TG.mat_lib_external = mat_lib_external;          

TG.solve_in_input_csys = solve_in_input_csys;  
TG.solve_in_custom_csys = solve_in_custom_csys;      
TG.solve_in_C_csys = solve_in_C_csys; 

TG.subtract_preload_deflection = subtract_preload_deflection;

TG.threeD_coupling = threeD_coupling;       
TG.time_script = time_script; 
TG.verify_inputs = verify_inputs;
TG.bypass_errors = bypass_errors; 
TG.solve_force_location_boundary = solve_force_location_boundary;  
TG.bypass_geometric_variance = bypass_geometric_variance;  
TG.use_structural_displacement = use_structural_displacement; 
TG.use_thermal_displacement = use_thermal_displacement;

% Unsupported 2/28/24
TG.exaggerated_plot = exaggerated_plot;
TG.use_friction = use_friction;  
TG.canoe_ball = canoe_ball;
TG.use_mass = use_mass;

%% INIT CALCULATIONS
% DO NOT EDIT THIS SECTION. CALCULATIONS ONLY. ALL INPUTS ABOVE
if KC_type ~= 3
    N_tri = kc_triangle(KC_type, KC_radius);
else
    N_tri = KC_custom_Pct;
end
if (TG.rotinputs)
    % Transform
    inputRotate = Tform(inRz,3) * Tform(inRy,2) * Tform(inRx,1); % Rotation Only
    inputTran = Tform(inP,0);
    inputTranRot = inputTran * inputRotate; % Transformation
    N_tri = data_transform(inputTranRot,N_tri')';
    F_L_loc = data_transform(inputTranRot, F_L_loc')';
    F_L = data_transform(inputRotate,F_L')';
    F_PL_loc = data_transform(inputTranRot, F_PL_loc')';
    F_PL = data_transform(inputRotate,F_PL')';

    FL_loc_tol = data_transform(inputTranRot,FL_loc_tol);
    F_L_tol = data_transform(inputRotate,F_L_tol);
    B_pos_tol = data_transform(inputTranRot,B_pos_tol);
    V_pos_tol = data_transform(inputTranRot,V_pos_tol);
end

% Solve Incenter
C = incenter_solve(N_tri);

if(~TG.threeD_coupling)
    vee_reorient = zeros(3);
end

%% Set Materials
[mat_ball, mat_vee] = Import_Materials(mat_index,TG.mat_lib_external);    % Steel, Material Property Organized [E, sig_y, G, sig_G, v]
%% Defining Objects

% DO NOT EDIT THIS SECTION. ALL INPUTS ABOVE.    
% --------------------------------------------

PreLD = {KC_LOAD,KC_LOAD,KC_LOAD};
for i = 1:3
    PreLD{i}.P = F_PL(1:3,i);
    PreLD{i}.P_loc = F_PL_loc(1:3,i);
    PreLD{i}.M = zeros(3,1);
end

LD = KC_LOAD;
LD.P = F_L;
LD.P_loc = F_L_loc;
LD.M = M_L;
% --------------------------------------------
KC = KC_SYS;

KC.Pct = N_tri;
KC.or;
KC.C = C;
KC.Db = Ball_dia_nom; 
KC.Rb2 = Ball_R2*2;
KC.Vg = V_groove_ang;
KC.Vh = Vh;
KC.DV = Vee_rad;
KC.Vreo = vee_reorient;
KC.Preld = PreLD;
KC.Ld = LD;
KC.Mball = mat_ball;
KC.Mvee = mat_vee;
KC.sig_y_SF = 1.0;
KC.sig_tau_SF = 1.0;
KC.T_Vees = cell(6,1);
KC.poi = poi;
KC.Ppoi = poi;
sz_poi = size(poi);
KC.poi_err = zeros(sz_poi(1),6);
for i = 1:6
    KC.T_Vees{i} = eye(4);
end
KC.struct_disp_ball = struct_disp_ball;
KC.therm_disp_ball = therm_disp_ball;

% --------------------------------------------
TL = KC_TOL;
TL.Db = Diam_tol;     % mm
TL.Circ = Circ_tol;     % mm
TL.B_tol = B_pos_tol;      % mm
TL.Vht = Heightv_tol;  % mm
TL.Or = Orient_tol;   % rad
TL.Vang = Halfa_tol;    % rad
TL.V_tol = V_pos_tol;      % mm
TL.F_L = F_L_tol;      % N
TL.F_P = F_P_tol;      % N
TL.FL_loc = FL_loc_tol;   % mm
TL.B_tol = B_pos_tol;
TL.V_tol = V_pos_tol;
% --------------------------------------------

%% ERROR CHECK
if (TG.solve_nominal+TG.solve_specific+TG.solve_montecarlo+TG.solve_covariance > 1)
    uiwait(errordlg('Only one type of solution may be checked. Verify Solve toggles are all zero except one'));
    error('Script Terminated')
end
%% STORE CONFIG FILE
% Work in progress
% saveObjectsToFile(TG, KC, PreLD, LD, TL, POI, N, T_custom, 'default_config.mat')
%% INTERNAL FUNCTIONS
function saveObjectsToFile(TG, KC, PreLD, LD, TL, POI, N, T_custom, filename)
    % Gather objects into a structure
    data.TG = TG;
    data.KC = KC;
    data.PreLD = PreLD;
    data.LD = LD;
    data.TL = TL;
    data.POI = POI;
    data.N = N;
    data.T_custom = T_custom;
    
    % Save the structure to a .mat file
    save(filename, '-struct', 'data');
    fprintf('Objects saved to %s.\n', filename);
end
function [tg, kc_in, preld_in, ld_in, tl_in, poi_in, N, T_custom] = unpackObjectsFromFile(filename)
    % Load the structure from the .mat file
    data = load(filename);
    % Unpack the structure into variables
    TG = data.TG;
    KC = data.KC;
    PreLD = data.PreLD;
    LD = data.LD;
    TL = data.TL;
    POI = data.POI;
    N = data.N;
    T_custom = data.T_custom;
end
end
