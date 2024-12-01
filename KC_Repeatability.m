% KC_Repeatability.m
% Solve KC Repeatability per Hale's equation. [Source needed] (WIP)
function rho = KC_Repeatability(kci)
for i = 1:6
    % Solve equivalent modulus of elasticity between ball and vee at contact.
    E_e(i) = 1/((1-kci.Mball.poisson_ratio^2)/kci.Mball.mod_of_elasticity + (1-kci.Mvee.poisson_ratio^2)/kci.Mvee.mod_of_elasticity);
    
    % Solve repeatability of each contact point.
    rho_contact(i) = kci.mu * (2/(3*(kci.Db(i)/2))^(1/3))*(kci.RP(i)/E_e(i));

    % Solve error motion from each contact repeatability.
    
end