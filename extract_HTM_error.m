% extract_HTM_error.m
% Return the error terms from a given HTM for rotation and translation.
% HTM input in form 
% T_err = [1        -epsZ   eps_Y   dC(1);
        %  epsZ     1       -eps_X  dC(2);
        % -eps_Y    eps_X   1       dC(3);
        % 0         0       0       1];
% Error output in form rest_err = [eps_X, eps_Y, epsZ, dC(1), dC(2), dc(3)];
function err = extract_HTM_error(H)
    err = [H(3,2), H(1,3), H(2,1), H(1:3,4)'];
end

% function err = extract_HTM_error(H)
%     err_rot = eulerangs(H(1:3,1:3));
%     err_pos = H(1:3,4)';
%     err = [err_rot, err_pos];
% 
%     function err_rot = eulerangs(H)
%         sy = sqrt(H(1,1)^2 + H(2,1)^2);
% 
%         if sy > 1e-12
%             rx = atan2(H(3,2), H(3,3));
%             ry = atan2(-H(3,1), sy);
%             rz = atan2(H(2,1), H(1,1));
%         else
%             rx = atan2(-H(2,3), H(2,2));
%             ry = atan2(-H(3,1), sy);
%             rz = 0;
%         end
% 
%         err_rot = [rx,ry,rz];
%     end
% end

