function N_Tri = kc_triangle(KC_type, KC_radius)
N_Tri = zeros(3);
    if (KC_type == 0) % Symmetric KC Case
        for i = 1:3 % Set x terms to indices spaced 120 deg apart with R = KC_radius
            N_Tri(i,1) = KC_radius(1) * cos(i*2*pi/3); % i*2*pi/3 places 3rd ball center on x axis
            N_Tri(i,2) = KC_radius(1) * sin(i*2*pi/3);
            N_Tri(i,3) = 0;
        end
    elseif (KC_type == 1) % Isoscelese KC Case
        N_Tri(1,:) = [-KC_radius(1)/2, 0, 0];
        N_Tri(2,:) = [KC_radius(1)/2, 0, 0];
        N_Tri(3,:) = [0, KC_radius(2), 0];
    elseif (KC_type == 2) % Right KC Case
        N_Tri = KC_radius(1).* [0,1,0;0,0,0;1,0,0];
    end
    N_Tri = N_Tri';
end