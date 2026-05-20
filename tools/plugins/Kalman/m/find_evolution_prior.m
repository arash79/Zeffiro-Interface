function [q] = find_evolution_prior(L, theta0, number_of_frames, evolution_prior_db, prior_over_measurement_db, snr)
% --- Zeffiro documentation header ---
% find_evolution_prior — Find evolution prior.
%
% Purpose:
%   Find evolution prior.
%   Folder: Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.
%
% Inputs:
%   L
%   theta0
%   number_of_frames
%   evolution_prior_db
%   prior_over_measurement_db
%   snr
%
% Outputs:
%   q
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[q] = find_evolution_prior(L, theta0, number_of_frames, evolution_prior_db, …)` with project root and `src` on the path.
% --- End Zeffiro documentation header

q = (1./number_of_frames)*10^(2*(evolution_prior_db)/20) * theta0;

end
