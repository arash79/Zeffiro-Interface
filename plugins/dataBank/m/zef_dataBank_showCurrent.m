function [info,columnNames] = zef_dataBank_showCurrent(zef, type)
%ZEF_DATABANK_SHOWCURRENT  Table of live zef fields for the selected Entrytype.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   showcurrentButton.ButtonPushedFcn in zef_open_dataBank (and the initial
%   currentTable fill). Builds a one-node tree via getData then showAll, so
%   column layout matches the bank table for that type. Does not write
%   zef.dataBank.tree.
%
%   [info, columnNames] = zef_dataBank_showCurrent(zef, type)
%
%   Inputs
%     zef   - session whose live fields are snapshotted.
%     type  - Entrytype.Value (data, leadfield, reconstruction, …).
%
%   Output
%     info, columnNames  - as from zef_databank_showAll for a single node.
%
%   See also zef_databank_showAll, zef_dataBank_getData.

tree.node.data=zef_dataBank_getData(zef, type);
tree.node.type=type;
[info, columnNames]=zef_databank_showAll(tree, type);

end
