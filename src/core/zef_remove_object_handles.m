function zef = zef_remove_object_handles(zef, node_name, h_list)
%ZEF_REMOVE_OBJECT_HANDLES  Strip graphics/object handles from a struct tree.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Used before saving a project so .mat files do not store live figure
%   handles. Fields whose value isvalid() as an object are rmfield'd
%   (matlab.io.MatFile is skipped). Nested structs are walked recursively;
%   struct arrays longer than 1000 entries are skipped with a warning.
%
%   zef = zef_remove_object_handles(zef)
%   zef = zef_remove_object_handles(zef, node_name)
%   zef = zef_remove_object_handles(zef, node_name, h_list)
%
%   Inputs
%     zef        - struct to clean (often zef_data). With one argument the
%                  struct is processed directly.
%     node_name  - dotted eval path into the caller workspace (e.g. 'zef'
%                  or 'zef.foo(2)'). Empty/omitted uses the one-arg path.
%     h_list     - optional handle list; when nonempty, only matching
%                  handles are removed.
%
%   Output
%     zef  - struct with handle fields removed. The two-arg form also
%            eval's assignments back into node_name in this workspace.
%
%   Notes
%     The node_name path uses eval; it exists for historical save code that
%     walks zef.field names as strings. Prefer the one-arg form for new code.
%
%   See also zef_save.


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
