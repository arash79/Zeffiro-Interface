function zef = zef_dataBank_add_data_item(zef,data_type,parent_node_name,node_name)
% --- Zeffiro documentation header ---
% zef_dataBank_add_data_item — Zef data Bank add data item.
%
% Purpose:
%   Zef data Bank add data item.
%   Folder: Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.
%
% Inputs:
%   zef
%   data_type
%   parent_node_name
%   node_name
%
% Outputs:
%   zef
%
% Zef fields (observed):
%   zef.dataBank (read)
%
% Calls (project):
%   zef_dataBank_addButtonPress
%   zef_dataBank_add_data_item
%   zef_dataBank_refreshTree
%   zef_dataBank_treeSearch
%
% Side effects:
%   - base/caller workspace
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[zef] = zef_dataBank_add_data_item(zef, data_type, parent_node_name, node_name)` with project root and `src` on the path.
% --- End Zeffiro documentation header


zef = zef_dataBank_refreshTree(zef);
h_tree = zef.dataBank.app.Tree;
hash_list = zef.dataBank.hashList;
h_tree.SelectedNodes = zef_dataBank_treeSearch(h_tree, parent_node_name);

if ischar(data_type)
    if eval(['ismember(''' data_type ''',zef.dataBank.app.Entrytype.Items);'])
        eval(['zef.dataBank.app.Entrytype.Value = ''' data_type ''';']);
        zef = zef_dataBank_addButtonPress(zef);
    end
elseif isfloat(data_type)
    eval(['zef.dataBank.app.Entrytype.Value = zef.dataBank.app.Entrytype.Items{' num2str(data_type) '};']);
    zef = zef_dataBank_addButtonPress(zef);
end

zef = zef_dataBank_refreshTree(zef);
hash_list_new = zef.dataBank.hashList;

new_hash = setdiff(hash_list_new, hash_list);
eval(['zef.dataBank.tree.(''' new_hash{1} ''').name = ''' node_name ''';']);
zef = zef_dataBank_refreshTree(zef);

if nargout == 0
    assignin('base','zef',zef);
end

end
