function vec = zef_ES_error_criteria(zef) 
% --- Zeffiro documentation header ---
% zef_ES_error_criteria — Zef ES error criteria.
%
% Purpose:
%   Zef ES error criteria.
%   Folder: Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.
%
% Inputs:
%   zef
%
% Outputs:
%   vec
%
% Zef fields (observed):
%   zef.ES_relative_weight_nnz (read)
%   zef.y_ES_interval (read)
%
% Calls (project):
%   zef_ES_error_criteria
%   zef_ES_rwnnz
%
% Side effects:
%   - base/caller workspace
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[vec] = zef_ES_error_criteria(zef)` with project root and `src` on the path.
% --- End Zeffiro documentation header


if nargin == 0 
    zef = evalin('base','zef');
end

%% Variables and parameters setup
    load_aux = eval('zef.y_ES_interval');
B = cell2mat(load_aux.residual);
B = B/max(abs(B(:)));

E = cell2mat(load_aux.field_source.relative')';
F = cell2mat(load_aux.field_source.magnitude')';
G = cell2mat(load_aux.field_source.angle')';

A = zeros(size(load_aux.y_ES));
C = zeros(size(load_aux.y_ES));
D = zeros(size(load_aux.y_ES));

for i = 1:size(load_aux.y_ES,1)
    for j = 1:size(load_aux.y_ES,2)
        A(i,j) =         norm(cell2mat(load_aux.y_ES(i,j)),1);
        C(i,j) =          max(cell2mat(load_aux.y_ES(i,j)));
        D(i,j) = zef_ES_rwnnz(cell2mat(load_aux.y_ES(i,j)), eval('zef.ES_relative_weight_nnz'));
    end
end

X = {A,B,C,D,E,F,G};
vec = array2table(X,'VariableNames',{'Total Dose (L_{1}-Norm)', 'Residual', 'Max Y_{ES}', 'Effective NNZ Currents', 'Local Relative Error', 'Local Relative Magnitude Error', 'Local Orientation Error'});
end
