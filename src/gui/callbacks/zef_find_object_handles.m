function h_output = zef_find_object_handles(zef, h_input, h_output, node_name)
% --- Zeffiro documentation header ---
% zef_find_object_handles — Zef find object handles.
%
% Purpose:
%   Zef find object handles.
%   Folder: Interactive UI: App Designer exports, menu tools, callbacks, plot refresh, and `zef_update_*` sync from widgets to `zef`.
%
% Inputs:
%   zef
%   h_input
%   h_output
%   node_name
%
% Outputs:
%   h_output
%
% Calls (project):
%   zef_find_object_handles
%
% Side effects:
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[h_output] = zef_find_object_handles(zef, h_input, h_output, node_name)` with project root and `src` on the path.
% --- End Zeffiro documentation header


if nargin < 3
    h_output = struct;
end

if nargin < 4
    node_name = 'zef';
end

fields = fieldnames(eval(node_name));
for i = 1 : length(fields)
    aux_string = [node_name '.' fields{i}];
    aux_field = eval(aux_string);
    try
        isvalid(aux_field);
        handle_test = true;
    catch
        handle_test = false;
    end
    if and(isobject(aux_field),handle_test)
        try
            if ismember(aux_field,h_input)
                h_output.(fields{i}) = aux_field;
            end
        catch
            h_output.(fields{i}) = aux_field;
            properties_aux = properties(aux_field);
            for k = 1 : length(properties_aux)
                h_output.(fields{i}).(properties_aux{k}) = aux_field.(properties_aux{k});
            end
        end

    elseif isstruct(eval(aux_string))
        h_output = zef_find_object_handles(zef, h_input, h_output, aux_string);
    end

end
end
