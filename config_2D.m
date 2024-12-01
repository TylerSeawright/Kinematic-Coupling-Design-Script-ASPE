% Configuration File
function [TG, KC] = config_2D()
%% GUI INPUTS
solve_nominal = 0;              % Control if Nominal simulation runs
solve_specific = 1;             % Control if Specific simulation runs

rotinputs = 1;                  % Control if inputs are transformed by inR and inP values.
FL_is_Coupling_Centroid = 0;    % Control if F_L is located at coupling centroid
F_P_is_equal = 2;               % Control if all F_P magnitudes are equal. 1 for all equal, 0 for specific vectors, 2 for solve via superposition of load in first column
mat_lib_external = 0;           % Control if external imported material library is used, else use default

solve_in_input_csys = 1;        % Control if plots and results are in input coordinate system
solve_in_C_csys = 0;            % Control if plots and results are in centroid coordinate system. B3 center on x-axis and all balls on XY plane.

subtract_preload_deflection = 1;% Control if preload deflection is subtracted from clamp force induced error to simulate only loading and unloading clamp.

threeD_coupling = 1;            % Control if 3D coupling is enabled. Save calculation speed by only enabling when vee_reorient vectors are used
verify_inputs = 0;              % Control if inputs are verified before running the script
bypass_errors = 0;              % Control if error messages are bypassed. Use at your own risk.

print_config = 0;               % Control if KC config information is printed to console.
print_materials = 0;            % Control if material list is printed.

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
KC_radius = [100,200];

% - Optional Rotation of KC from Input Csys. 
% Generally used for transforming a simple system such as symmetric 90
% degrees.
inRx = 0; inRy = 0; inRz = 0; % Rotation Angles
inP = [0,0,0]'; % Transformation Vector
%% GEOMETRY
% [mm] Nominal Coordinates of each ball center (triangle) in the 
% newtonian N frame stored as [x1, y1, z1; x2 ...]
% Custom Entered Ball Positions
KC_custom_Pct = [104, 0, 55; ...
                 -104, 0, 55;
                 0, 0, -138]'; 
% - Ball Bodies
Ball_dia_nom = 19*ones(1,3);      %[mm] Nominal Ball Diameters
Ball_R2 = 100 * ones(1,3);        % [mm] Ball major radii if using canoe balls

% - Groove Bodies
V_groove_ang = 90*ones(1,3);      % [deg] Nominal Vee Groove Angles
Vee_rad = 1e10*[1,1]';            % [mm], Large radius for vee groove -> flat, Rxx, Ryy
Vh = 0*ones(1,3);                 % [mm] vee hieght
vee_reorient = [0 0 0; 0 0 0; 0 0 0]; % [rad], controls vee orientation, [0,0,0] is vee pointing towards centroid. CHECK INPUT CSYS
%% FORCES
F_Preload = [0 0 -10; ... % [N] F_Preload are preload force vectors
             0 0 0;
             0 0 0]';
F_Preload_Location = [0 0 0; ... % [mm] F_Preload_Location are preload force position vectors relative to each ball center [x1, y1, z1; x2 ...]
                      0 0 0;
                      0 0 0]';
F_Applied = [0 0 -100]'; % [N] F_Applied is list of clamp loads at FL_loc [x1, y1, z1; x2 ...]
F_Applied_Location = [0,0,25]'; % [mm] FL_loc is list of clamp load locations [x1, y1, z1; x2 ...]

M_Preload = [0,0,0]'; % [N-m] M_PL is list of clamp preload moments applied to the ball pallet
M_Applied = [0,0,0]'; % [N-m] M_L is list of clamp moments applied to the ball pallet

% - Optional masses for heavy clamps. (Unsupported)
mass_ball_plate = 4; % [kg]
COM_ball_plate = [0,0,0]'; % Location of COM
gravity_direction = [0,0,-1]; % Set gravity direction.
%% POI
poi = [50, 0, 0;
       30, 50, 10]; % POI [mm] is a set of points of interest to solve error about in the input Csys.
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
                    0,0,0]; % [mm]
therm_disp_ball =  [0,0,0;
                    0,0,0;
                    0,0,0]; % [mm / deg K]
temperature_shift = 0; % [deg k]
%% TOLERANCES
Diam_tol =      0*1e-3;        % mm
Circ_tol =      0*1e-3;        % mm
B_pos_tol =     [0,0,0]*1e-3;  % mm
V_pos_tol =     [0,0,0]*1e-3;  % mm
Heightv_tol =   [0,0,0]*1e-3;  % mm
Orient_tol =    [0,0,0]*1e-3;  % rad
Halfa_tol =     0*1e-3;        % deg
F_L_tol =       [0,0,0];       % N
F_P_tol =       [0,0,0];       % N
FL_loc_tol =    [0,0,0]*1e-3;  % mm
%% NO EDITS PAST THIS LINE ...............................................
%% SET TOGGLES
TG = KC_TOG;

TG.solve_nominal = solve_nominal;
TG.solve_specific = solve_specific;

TG.rotinputs = rotinputs; 
TG.FL_is_Coupling_Centroid = FL_is_Coupling_Centroid;  
TG.F_P_is_equal = F_P_is_equal;
TG.mat_lib_external = mat_lib_external;          

TG.solve_in_input_csys = solve_in_input_csys;  
TG.solve_in_C_csys = solve_in_C_csys; 

TG.subtract_preload_deflection = subtract_preload_deflection;

TG.threeD_coupling = threeD_coupling;       
TG.verify_inputs = verify_inputs;
TG.bypass_errors = bypass_errors; 


% Unsupported 2/28/24
TG.use_structural_displacement = use_structural_displacement; 
TG.use_thermal_displacement = use_thermal_displacement;
TG.exaggerated_plot = exaggerated_plot;
TG.use_friction = use_friction;  
TG.canoe_ball = canoe_ball;
TG.use_mass = use_mass;

%% DO NOT EDIT PAST THIS LINE ...........................................
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
else
    inputTranRot = eye(4);
end

% Solve Incenter
C = incenter_solve(N_tri);

if(~TG.threeD_coupling)
    vee_reorient = zeros(3);
end

%% MATERIALS
[mat_ball, mat_vee, num_mats] = Import_Materials(mat_index,TG.mat_lib_external);    % Material Property Organized [E, sig_y, G, sig_G, v]

%% KC OBJECT DEFINITION

% DO NOT EDIT THIS SECTION. ALL INPUTS ABOVE.    
% --------------------------------------------

PreLD = {KC_LOAD,KC_LOAD,KC_LOAD};
for i = 1:3
    PreLD{i}.P = F_Preload(1:3,i);
    PreLD{i}.P_loc = F_Preload_Location(1:3,i);
    PreLD{i}.M = zeros(3,1);
end

LD = KC_LOAD;
LD.P = F_Applied;
LD.P_loc = F_Applied_Location;
LD.M = M_Applied;
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
KC.T_input = inputTranRot;
KC.struct_disp_ball = struct_disp_ball;
KC.therm_disp_ball = therm_disp_ball;

% --------------------------------------------
KC.tl.Db = Diam_tol;     % mm
KC.tl.Circ = Circ_tol;     % mm
KC.tl.B_tol = B_pos_tol;      % mm
KC.tl.Vht = Heightv_tol;  % mm
KC.tl.Or = Orient_tol;   % rad
KC.tl.Vang = Halfa_tol;    % rad
KC.tl.V_tol = V_pos_tol;      % mm
KC.tl.F_L = F_L_tol;      % N
KC.tl.F_P = F_P_tol;      % N
KC.tl.FL_loc = FL_loc_tol;   % mm
KC.tl.B_tol = B_pos_tol;
% --------------------------------------------
%% OPTIONAL PRINTOUTS
if (print_config == 1)
    fprintf("KC Configuration............................\n\n")
    fprintf("Ball Material: %s\n", mat_ball.mat)
    fprintf("Vee Material: %s\n\n", mat_vee.mat)
end
if(print_materials == 1)
    fprintf("Default Material List\n")
    for i = 1:num_mats
        [m_print, ~] = Import_Materials([i,1], 0);
        fprintf("%d %s\n", i, m_print.mat)
    end
end
%% ERROR CHECK
if (TG.solve_nominal+TG.solve_specific> 1)
    uiwait(errordlg('Only one type of solution may be checked. Verify Solve toggles are all zero except one'));
    error('Script Terminated')
end
