function vec = zef_ES_error_criteria(zef)
%ZEF_ES_ERROR_CRITERIA  Build an error/score table from y_ES_interval.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Not used by zef_ES_plot_error_chart (that uses zef_ES_table) and not
%   bound in zef_ES_optimization_window. Reads y_ES_interval residual,
%   field_source relative/magnitude/angle, ||y||_1, max y, rwnnz.
%
%   vec = zef_ES_error_criteria()
%   vec = zef_ES_error_criteria(zef)
%
%   See also zef_ES_table, zef_ES_rwnnz.
%

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
