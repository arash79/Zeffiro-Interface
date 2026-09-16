function zef = zef_dataBank_add_data_item(zef,data_type,parent_node_name,node_name)
%ZEF_DATABANK_ADD_DATA_ITEM  Programmatic Add: select parent by name, set Entrytype, rename.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Not a button. Needs the Data Bank App already open (zef_start_dataBank).
%   Refreshes the uitree, selects the child whose Text equals
%   parent_node_name (empty → root), sets Entrytype to data_type, then
%   zef_dataBank_addButtonPress. The new hash is the setdiff of hashList
%   before/after; that node's .name is set to node_name. Used to create a
%   custom parent plus data and leadfield children (getData has no custom
%   case, so that parent
%   stores only .type).
%
%   zef = zef_dataBank_add_data_item(zef, data_type, parent_node_name, node_name)
%
%   Inputs
%     zef               - session with dataBank.app and tree.
%     data_type         - char in Entrytype.Items, or a 1-based index into Items.
%     parent_node_name  - uitree Text to select, or [] for the root.
%     node_name         - char stored as tree.(new_hash).name.
%
%   Output
%     zef  - tree/uitree updated; nargout==0 → assignin base.
%
%   See also zef_dataBank_addButtonPress, zef_dataBank_treeSearch.

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
