% --- Zeffiro documentation header ---
% if isfield(zef,'synth_source_data') — If isfield(zef,'synth source data').
%
% Purpose:
%   If isfield(zef,'synth source data').
%   Folder: Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.
%
% Zef fields (observed):
%   zef.find_synth_source (read)
%   zef.synth_source_data (read)
%
% Side effects:
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: Call `if isfield(zef,'synth_source_data')` from MATLAB with the project root on the path.
% --- End Zeffiro documentation header

if isfield(zef,'synth_source_data')
    zef.synth_source_data(zef.find_synth_source.selected_source) = [];
    zef.find_synth_source.h_source_list.Data(zef.find_synth_source.selected_source)=[];

    if isempty(zef.synth_source_data)
        zef = rmfield(zef,'synth_source_data');
        zef.find_synth_source.h_source_parameters.Data = [];
        zef.find_synth_source.h_source_list = [];
    else
        zef.find_synth_source.selected_source = 1;
        zef.find_synth_source.h_source_parameters.Data=zef.synth_source_data{zef.find_synth_source.selected_source}.parameters;
    end

end
