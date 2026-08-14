function [data] = zef_dataBank_getData(zef, type)
%ZEF_DATABANK_GETDATA  Copy selected zef fields into a node payload by type.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Used by Add (addButton / add_data_item). Does not write the tree.
%   Entrytype.Items in zef_open_dataBank are data, noisedata, leadfield,
%   reconstruction, gmm, custom, import. Only the first five have cases
%   here; custom and import yield a struct with .type only.
%
%   data = zef_dataBank_getData(zef, type)
%
%   Inputs
%     zef   - session whose live fields are copied.
%     type  - char matching a case below (usually Entrytype.Value).
%
%   Output
%     data  - struct with .type and type-specific fields:
%       data            - .measurements (zef.measurements)
%       noisedata       - .noisedata (zef.noise_data)
%       reconstruction  - .reconstruction as a cell, .reconstruction_information
%       leadfield       - L, sensors, imaging_method, noise_data, lf_tag,
%                         source_positions/directions, interpolants,
%                         source_structure{k} = zef.(compartment_tags{k}_sources)
%       gmm             - zef.GMM.model, dipoles, amplitudes, time_variables, parameters
%
%   See also zef_dataBank_setData, zef_dataBank_addButtonPress.

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
