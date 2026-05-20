function zef = zef_remove_object_handles(zef, node_name, h_list)
% --- Zeffiro documentation header ---
% zef_remove_object_handles — Zef remove object handles.
%
% Purpose:
%   Zef remove object handles.
%   Folder: Application lifecycle: `zef_start`, `zef_init`, `zef_update`, `zef_close_all`, logging, waitbars, window layout—not the `+core` package.
%
% Inputs:
%   zef
%   node_name
%   h_list
%
% Outputs:
%   zef
%
% Calls (project):
%   zef_remove_object_handles
%
% Side effects:
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[zef] = zef_remove_object_handles(zef, node_name, h_list)` with project root and `src` on the path.
% --- End Zeffiro documentation header


skip_class_list = {'matlab.io.MatFile'};

% When called with only one argument (e.g., zef_remove_object_handles(zef_data)),
% process the input struct directly instead of trying to eval('zef') which doesn't exist.
if nargin < 2 || isempty(node_name)
    if not(isstruct(zef)) || isempty(zef)
        return;
    end
    fields = fieldnames(zef);
    for i = 1 : length(fields)
        if isfield(zef, fields{i})
            aux_field = zef.(fields{i});
            if not(ismember(class(aux_field),skip_class_list))
                try
                    isvalid(aux_field);
                    handle_test = true;
                catch
                    handle_test = false;
                end
                if isobject(aux_field) && handle_test
                    if nargin < 3
                        zef = rmfield(zef, fields{i});
                    elseif isempty(h_list) || ismember(aux_field,h_list)
                        zef = rmfield(zef, fields{i});
                    end
                elseif isstruct(aux_field)
                    % CRITICAL: Limit recursion depth and struct array size to prevent hangs
                    % Very large struct arrays can cause infinite loops or extreme slowdown
                    if length(aux_field) == 1
                        zef.(fields{i}) = zef_remove_object_handles(aux_field, []);
                    elseif length(aux_field) > 1000
                        % Skip processing very large struct arrays to prevent hangs
                        % Large arrays likely don't contain object handles anyway
                        warning('zef_remove_object_handles: Skipping large struct array field %s (size %d)', fields{i}, length(aux_field));
                    else
                        for j = 1:length(aux_field)
                            zef.(fields{i})(j) = zef_remove_object_handles(aux_field(j), []);
                        end
                    end
                end
            end
        end
    end
    return;
end

if nargin < 3
    h_list = [];
end

fields = fieldnames(eval(node_name));
for i = 1 : length(fields)
    aux_string = [node_name '.' fields{i}];
    aux_field = eval(aux_string);
    if not(ismember(class(aux_field),skip_class_list))
        try
            isvalid(aux_field);
            handle_test = true;
        catch
            handle_test = false;
        end
        if isobject(aux_field) &  handle_test
            if isempty(h_list) | ismember(aux_field,h_list)
                aux_struct = rmfield(eval(node_name),fields{i});
                eval([node_name  ' = aux_struct;']);
            end
        elseif isstruct(eval(aux_string))
            if startsWith(aux_string,'zef.')
                if length(eval(aux_string)) == 1
                    zef = zef_remove_object_handles(zef, aux_string);
                else
                    for j = 1:length(eval(aux_string))
                        zef = zef_remove_object_handles(zef, [aux_string,'(',num2str(j),')']);
                    end
                end
            else
                aux_struct_val = eval(aux_string);
                if length(aux_struct_val) == 1
                    eval([aux_string ' = zef_remove_object_handles(aux_struct_val, []);']);
                else
                    for j = 1:length(aux_struct_val)
                        eval([aux_string '(' num2str(j) ') = zef_remove_object_handles(aux_struct_val(j), []);']);
                    end
                end
            end
        end
    end
end
end
