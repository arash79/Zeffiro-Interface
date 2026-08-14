%REMOVE_SYNTHETIC_SOURCE  Delete the selected synth_source_data cell.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Script. Remove button. Drops selected_source from synth_source_data
%   and the list. If empty, rmfield synth_source_data. Does not change
%   zef.measurements.
%
%   See also add_synthetic_source.

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
