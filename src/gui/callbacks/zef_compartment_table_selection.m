function zef_compartment_table_selection(hObject,eventdata,handles)
%ZEF_COMPARTMENT_TABLE_SELECTION  CellSelectionCallback for the compartment UITable.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Wired from zef_segmentation_tool onto h_compartment_table. Runs in the
%   GUI callback workspace; all zef writes go through evalin('base',...).
%
%   Table rows are stored in reverse order of zef.compartment_tags (see
%   zef_update). Row 1 is the last tag. This maps the clicked row to that
%   tag, sets zef.current_compartment and zef.current_tag, rebuilds the
%   transform table for that compartment (zef_init_transform), and clears
%   the parameters table so it can be refilled. Unique selected row indices
%   are stored in zef.compartments_selected for **Delete compartment(s)**.
%
%   Inputs (MATLAB UITable CellSelectionCallback)
%     hObject, handles  - unused.
%     eventdata.Indices - N-by-2 [row, column] of the selection.
%
%   See also zef_delete_compartment, zef_update.

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
