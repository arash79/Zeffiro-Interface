function [newRec] = zef_reconstructionTool_power(reconstruction)
%ZEF_RECONSTRUCTIONTOOL_POWER  Mean of squared frames (power) into one cell.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   [newRec] = zef_reconstructionTool_power(reconstruction)
%
%   reconstruction is a cell of frames. Returns {mean(x.^2)}.
%   Called from zef_reconstructionTool_apply via FunctionDropDown
%   'power'. Does not write zef.
%
%   See also zef_reconstructionTool_mean, zef_reconstructionTool_apply.

newRec=reconstruction{:,1};
newRec=newRec.^2;

for frame=2:size(reconstruction,2)
    nextRec=reconstruction{:,frame};
    newRec=newRec+nextRec.^2;
end
newRec=newRec/size(reconstruction,2);
newRec={newRec};

end
