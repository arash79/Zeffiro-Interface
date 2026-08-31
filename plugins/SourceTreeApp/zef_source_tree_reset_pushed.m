function zef_source_tree_reset_pushed(zef, ~, ~)
%ZEF_SOURCE_TREE_RESET_PUSHED  Clear the UI tree and restore default signal parameters.
%
%   App callback. The first argument is ignored; zef is always read from
%   the base workspace. Deletes all uitreenode children, removes
%   zef.source_tree, re-creates source_tree_signal_parameters via
%   zef_init_signal_general_data, refreshes the SignalParameters table,
%   and assignin('base','zef',zef).
%
%   See also zef_init_signal_general_data, zef_update_signal_parameters_table.

zef = evalin('base','zef');

    % Delete all nodes from the UI tree
    delete(zef.h_source_tree.SourceTree.Children);

    % Remove stored source tree data
    if isfield(zef,'source_tree')
        zef = rmfield(zef,'source_tree');
        zef.h_source_tree.SourceParameters.Data = [];
    end

    % Remove global signal parameters
    if isfield(zef,'source_tree_signal_parameters')
        zef = rmfield(zef,'source_tree_signal_parameters');
        zef.source_tree_signal_parameters = zef_init_signal_general_data();
    end
    zef_update_signal_parameters_table(zef, zef.source_tree_signal_parameters);
   
    % Push updated zef back to base workspace
    assignin('base','zef', zef);
end
