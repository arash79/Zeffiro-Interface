%ADD_SYNTHETIC_SOURCE  Append a Source(n) row to the synthetic-source list.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Script. Add button in find_synthetic_source. Picks the smallest
%   unused n from the Source(k) labels, copies synth_source_init into
%   h_source_parameters, and stores name+parameters on
%   zef.synth_source_data (flip to prepend). Errors if synth_source_data
%   is missing on the first add (else branch only sets itemnum=1). Does
%   not project through L (Create synth data does).
%
%   See also remove_synthetic_source, find_synthetic_source.

zef.find_synth_source.h_source_parameters.Data=zef.synth_source_init;

%Define a possible index for banked method name and add it to the list of selected inversion methods
if isfield(zef,'synth_source_data')
    zef_temp_itemnum  = str2double(erase(zef.find_synth_source.h_source_list.Data,{'Source','(',')'}));
    zef_temp_itemnum = setdiff(1:(length(zef.synth_source_data)+1),zef_temp_itemnum);
    zef_temp_itemnum = min(zef_temp_itemnum);
else
    zef_temp_itemnum = 1;
end
zef.find_synth_source.h_source_list.Data=flip(zef.find_synth_source.h_source_list.Data);

zef.find_synth_source.h_source_list.Data{end+1,1} = ['Source(',num2str(zef_temp_itemnum),')'];
zef.find_synth_source.selected_source=1;

zef.find_synth_source.h_source_list.Data=flip(zef.find_synth_source.h_source_list.Data);
clear zef_temp_itemnum;

%Save the meta information to synt_data field
zef.synth_source_data = flip(zef.synth_source_data);
zef.synth_source_data{end+1}.name = zef.find_synth_source.h_source_list.Data{1};
zef.synth_source_data{end}.parameters = zef.find_synth_source.h_source_parameters.Data;
zef.synth_source_data = flip(zef.synth_source_data);
