function zef_compartment_table_selection(hObject,eventdata,handles)
% --- Zeffiro documentation header ---
% zef_compartment_table_selection — Zef compartment table selection.
%
% Purpose:
%   Zef compartment table selection.
%   Folder: Interactive UI: App Designer exports, menu tools, callbacks, plot refresh, and `zef_update_*` sync from widgets to `zef`.
%
% Inputs:
%   hObject
%   eventdata
%   handles
%
% Outputs:
%   See function signature and code below.
%
% Zef fields (observed):
%   zef.compartment_tags (read)
%   zef.compartments_selected (read, write)
%   zef.current_compartment (read, write)
%   zef.current_tag (read, write)
%   zef.h_parameters_table (read)
%
% Calls (project):
%   zef_compartment_table_selection
%
% Side effects:
%   - base/caller workspace
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Invoked from a menu, button, or table callback in the Zeffiro tools.
%   Programmatic: `zef_compartment_table_selection(hObject, eventdata, handles)` with project root and `src` on the path.
% --- End Zeffiro documentation header


compartment_selected = eventdata.Indices(1);
compartment_tags = evalin('base','zef.compartment_tags');
compartment_tag_ind = evalin('base','length(zef.compartment_tags)') - compartment_selected + 1;

evalin('base', ['zef.current_compartment = ''' compartment_tags{compartment_tag_ind} ''';']);
evalin('base', ['zef.current_tag = ''' compartment_tags{compartment_tag_ind} ''';']);
evalin('base','run(''zef_init_transform'')');
evalin('base','zef.h_parameters_table.Data = [];');
compartments_selected = eventdata.Indices(:,1);
compartments_selected = unique(compartments_selected);
compartments_selected = compartments_selected(:)';
evalin('base',['zef.compartments_selected =[' num2str(compartments_selected) '];']);

end
