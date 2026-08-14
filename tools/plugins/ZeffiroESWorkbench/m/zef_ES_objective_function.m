function [sr, sc] = zef_ES_objective_function(varargin)
%ZEF_ES_OBJECTIVE_FUNCTION  Pick (sr,sc) in y_ES_interval from ES_obj_fun / obj_fun_2 and threshold.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Used by Update reconstruction, plotters, and fix-active-electrodes.
%   Builds a table via zef_ES_table; VariableDescriptions are 'minimum' /
%   'maximum' / 'none'. If obj_fun == obj_fun_2, take the global min or max
%   of that column. Else keep cells that pass ES_acceptable_threshold
%   (relative if ES_threshold_condition==1, else absolute) on obj_fun, then
%   min/max obj_fun_2 among those. sr indexes ε, sc indexes α.
%
%   [sr, sc] = zef_ES_objective_function()
%   [sr, sc] = zef_ES_objective_function(zef)
%   [sr, sc] = zef_ES_objective_function(zef, table_or_interval)
%   [sr, sc] = zef_ES_objective_function(zef, obj1, obj2, AT, TT)
%
%   See also zef_ES_table, zef_ES_update_reconstruction.
%

switch nargin
    case {0, 1, 2}
        if nargin == 0
            zef = evalin('base','zef');
            warning('ZI: No zef were called as an input argument.')
        else
            zef = varargin{1};
        end
        obj1    = zef.ES_obj_fun;
        obj2    = zef.ES_obj_fun_2;
        AT      = zef.ES_acceptable_threshold;
        TT      = zef.ES_threshold_condition;
        if nargin == 2 
            if istable(varargin{2})
                vec = varargin{2};
            else
                vec = zef_ES_table(varargin{2});
            end
        else
            vec = zef_ES_table(zef.y_ES_interval);
        end
    case{5}
        if isstruct(varargin{1})
            vec = zef_ES_table(varargin{1}.y_ES_interval);
            [obj1, obj2, AT, TT] = deal(varargin{2}, varargin{3}, varargin{4}, varargin{5});
        else
            [vec, obj1, obj2, AT, TT] = deal(varargin{1}, varargin{2}, varargin{3}, varargin{4}, varargin{5});
        end
    otherwise
        error('ZI: Invalid number of arguments.')
end

%% pre-allocation of the objective functions and threshold parameters
metacriteria_names  = vec.Properties.VariableNames;
metacriteria_minmax = vec.Properties.VariableDescriptions;
metacriteria_objfun = metacriteria_names(~strcmpi(metacriteria_minmax, 'none'));

obj_fun_1 = vec.(metacriteria_objfun{obj1}){1};
obj_fun_2 = vec.(metacriteria_objfun{obj2}){1};
if isempty(obj_fun_1) || isempty(obj_fun_2)
    error('ZI error: No data has been calculated yet.')
end
%% 'sweet spot' indexing based on objective
% Same criterion twice: global argmin/argmax. Two criteria: threshold
% obj_fun_1 then argmin/argmax of obj_fun_2 on the surviving cells.
if isequal(obj1, obj2)
    if     strcmpi(metacriteria_minmax(obj1), 'minimum')
        [~, Idx] = min(abs(obj_fun_1),[],'all','linear');
    elseif strcmpi(metacriteria_minmax(obj1), 'maximum')
        [~, Idx] = max(abs(obj_fun_1),[],'all','linear');
    end
    [sr, sc] = ind2sub(size(obj_fun_1), Idx);
else
    if isequal(TT, 1)
        AT = AT*max((obj_fun_1(:)));
    end

    if     strcmpi(metacriteria_minmax(obj1), 'minimum')
        [Idx] = find(abs(obj_fun_1(:)) <= AT);
        if isempty(Idx)
            [~, Idx] = min(abs(obj_fun_1(:)));
        end
    elseif strcmpi(metacriteria_minmax(obj1), 'maximum')
        [Idx] = find(abs(obj_fun_1(:)) >= AT);
        if isempty(Idx)
            [~, Idx] = max(abs(obj_fun_1(:)));
        end
    end

    if     strcmpi(metacriteria_minmax(obj2), 'minimum')
        [~, Idx_2] = min(abs(obj_fun_2(Idx)));
    elseif strcmpi(metacriteria_minmax(obj2), 'maximum')
        [~, Idx_2] = max(abs(obj_fun_2(Idx)));
    end
    [sr, sc] = ind2sub(size(obj_fun_2), Idx(Idx_2));
end
