%% kc_mc.m
% Author: Tyler Seawright
% Last Edited: 9/6/24
% Run KC MonteCarlo Simulations

% N is number of samples
% sdev is number of standard deviations tolerance zone is from zero
% tg is standard set of toggles used
% kci is input KC
% kco is output KC using combined KC errors geometric, force, and custom
% sources.
% kco_stats is output KC stats
%% FUNCTION DEFINITION
function [kco, kco_stat] = kc_mc(N, sd, tg, kci)
fprintf("KC MonteCarlo PROGRESS BAR\n>          < 100%%\n>")
    kco = cell(1,N);
    for i = 1:N
        % Solve Each KC System
        kco{i} = KC_SOLVER(tg, kc_deviate(kci, sd));
        % Poor Man's Waitbar in Console
        if mod(i,N/10) == 0
            fprintf("|")
        end
    end
    fprintf("< 100%%\nKC MonteCarlo Complete\n")
    % SEPARATE STAT DATASETS
    Ce = zeros(N,6);
    for i = 1:N
        Ce(i,:) = kco{i}.C_err;
    end

    % SOLVE STATS
    kco_stat=KC_MC_STATS;
    kco_stat.C.data = Ce;
    kco_stat.C.mu_er = mean(Ce(:,1:3),1);
    kco_stat.C.mu_e = mean(Ce(:,4:6),1);
    kco_stat.C.sig_er = std(Ce(1:3));
    kco_stat.C.sig_e = std(Ce(4:6));
end