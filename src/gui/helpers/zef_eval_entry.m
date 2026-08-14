function out_val = zef_eval_entry(in_var, entry_ind)
%ZEF_EVAL_ENTRY  Index a vector (groot ScreenSize waitbar width/height).
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   out_val = in_var(entry_ind). Only callers: zef_waitbar and zef_menu_tool
%   use ScreenSize(3) and (4). Not a profile-INI evaluator.
%
%   out_val = zef_eval_entry(in_var, entry_ind)

out_val = in_var(entry_ind);

end
