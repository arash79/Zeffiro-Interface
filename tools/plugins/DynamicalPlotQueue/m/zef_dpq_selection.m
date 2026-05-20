function zef_dpq_selection(hObject,eventdata,handles)
% --- Zeffiro documentation header ---
% zef_dpq_selection — Zef dpq selection.
%
% Purpose:
%   Zef dpq selection.
%   Folder: Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.
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
%   zef.dpq_selected (read, write)
%   zef.h_dynamical_plot_queue_description (read)
%   zef.h_dynamical_plot_queue_script (read)
%   zef.h_dynamical_plot_queue_table (read)
%
% Calls (project):
%   zef_dpq_selection
%
% Side effects:
%   - base/caller workspace
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Invoked from a menu, button, or table callback in the Zeffiro tools.
%   Programmatic: `zef_dpq_selection(hObject, eventdata, handles)` with project root and `src` on the path.
% --- End Zeffiro documentation header


functions_selected = eventdata.Indices(:,1)';
evalin('base',['zef.dpq_selected = [' num2str(functions_selected) ']'';']);
evalin('base',['zef.h_dynamical_plot_queue_script.Value=zef.h_dynamical_plot_queue_table.Data{' num2str(functions_selected(1)) ',1};']);
evalin('base',['zef.h_dynamical_plot_queue_description.Value=zef.h_dynamical_plot_queue_table.Data{' num2str(functions_selected(1)) ',4};']);

end
