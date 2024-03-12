function write_to_blender(ball_positions, ball_diameters, plane_positions, plane_rotations, arrow_position, arrow_rotation, coord_sys_position, coord_sys_rotation, contact_force_magnitudes)
%{
INPUT FORMATTING
ball_positions = [1,2,3; 4,5,6; 7,8,9];
ball_diameters = [1.5, 2.5, 3.5];
plane_positions = [10,11,12; 13,14,15; 16,17,18];
plane_rotations = [20,21,22; 23,24,25; 26,27,28];
arrow_position = [30,31,32];
arrow_rotation = [33,34,35];
coord_sys_position = [40,41,42];
coord_sys_rotation = [43,44,45];    
%}
% Open a file for writing
    fileID = fopen('3DKC_Blender.txt', 'w');

    % Write data for three balls (only positions)
    for i = 1:3
    fprintf(fileID, 'BALL: %f, %f, %f, %f\n', ball_positions(i, :), ball_diameters(i));    end

    % Write data for three planes (positions and orientations)
    for i = 1:6
        fprintf(fileID, 'PLANE: %f, %f, %f, %f, %f, %f\n', plane_positions(i, :), plane_rotations(i, :));
    end

    % Write data for an arrow (position and orientation)
    fprintf(fileID, 'ARROW: %f, %f, %f, %f, %f, %f\n', arrow_position, arrow_rotation);

    % Write data for a coordinate system (position and orientation)
    fprintf(fileID, 'COORD_SYS: %f, %f, %f, %f, %f, %f\n', coord_sys_position, coord_sys_rotation);
    
    if length(contact_force_magnitudes)>1
        for i = 1:6
            fprintf(fileID, 'CFORCE: %f, %f, %f, %f, %f, %f, %f\n', contact_force_magnitudes(i), plane_positions(i, :), plane_rotations(i, :));
        end
    end
    
    % Close the file
    fclose(fileID);
%{ 
OUTPUT TXT FILE FORMATTING
BALL: 1.000000, 2.000000, 3.000000
BALL: 4.000000, 5.000000, 6.000000
BALL: 7.000000, 8.000000, 9.000000
PLANE: 10.000000, 11.000000, 12.000000, 20.000000, 21.000000, 22.000000
PLANE: 13.000000, 14.000000, 15.000000, 23.000000, 24.000000, 25.000000
PLANE: 16.000000, 17.000000, 18.000000, 26.000000, 27.000000, 28.000000
ARROW: 30.000000, 31.000000, 32.000000, 33.000000, 34.000000, 35.000000
COORD_SYS: 40.000000, 41.000000, 42.000000, 43.000000, 44.000000, 45.000000
%}
end


