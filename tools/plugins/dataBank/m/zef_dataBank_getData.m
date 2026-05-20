function [data] = zef_dataBank_getData(zef, type)
% --- Zeffiro documentation header ---
% zef_dataBank_getData — Zef data Bank get Data.
%
% Purpose:
%   Zef data Bank get Data.
%   Folder: Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.
%
% Inputs:
%   zef
%   type
%
% Outputs:
%   data
%
% Zef fields (observed):
%   zef.GMM (read)
%   zef.L (read)
%   zef.compartment_tags (read)
%   zef.imaging_method (read)
%   zef.lf_tag (read)
%   zef.measurements (read)
%   zef.noise_data (read)
%   zef.parcellation_interp_ind (read)
%   zef.reconstruction (read)
%   zef.reconstruction_information (read)
%   zef.sensors (read)
%   zef.source_directions (read)
%   zef.source_interpolation_ind (read)
%   zef.source_positions (read)
%
% Calls (project):
%   zef_dataBank_getData
%
% Side effects:
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[data] = zef_dataBank_getData(zef, type)` with project root and `src` on the path.
% --- End Zeffiro documentation header


data=[];
data.type=type;

switch type

    case 'data'
        data.measurements=zef.measurements;

    case 'noisedata'
        data.noisedata=zef.noise_data;

    case 'reconstruction'
        if iscell(zef.reconstruction)
            data.reconstruction=zef.reconstruction;
        else
            data.reconstruction={zef.reconstruction};
        end
        data.reconstruction_information=zef.reconstruction_information;

    case 'leadfield'
        data.source_interpolation_ind = zef.source_interpolation_ind;
        data.parcellation_interp_ind = zef.parcellation_interp_ind;
        data.source_positions = zef.source_positions;
        data.source_directions = zef.source_directions;
        data.L = zef.L;
        data.sensors = zef.sensors;
        data.imaging_method = zef.imaging_method;
        data.noise_data = zef.noise_data;
        if isfield(zef,'lf_tag')
            data.lf_tag = zef.lf_tag;
        else
            data.lf_tag = '';
        end
        data.source_structure = cell(0,0);
        for zef_ind=1:length(zef.compartment_tags)
            zef_name=strcat(zef.compartment_tags{zef_ind}, '_sources');
            data.source_structure{zef_ind}=zef.(zef_name);
        end

    case 'gmm'
        data.model = zef.GMM.model;
        data.dipoles = zef.GMM.dipoles;
        data.amplitudes = zef.GMM.amplitudes;
        data.time_variables = zef.GMM.time_variables;
        data.parameters = zef.GMM.parameters;

end

end
