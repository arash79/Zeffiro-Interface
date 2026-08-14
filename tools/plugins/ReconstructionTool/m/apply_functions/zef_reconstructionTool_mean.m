function [newRec] = zef_reconstructionTool_mean(reconstruction)
%ZEF_RECONSTRUCTIONTOOL_MEAN  Time-average of a cell reconstruction into one frame.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   [newRec] = zef_reconstructionTool_mean(reconstruction)
%
%   reconstruction is a cell of frames. Returns {mean}. Called from
%   zef_reconstructionTool_apply via FunctionDropDown 'mean'.
%   Does not write zef.
%
%   See also zef_reconstructionTool_power, zef_reconstructionTool_apply.

newRec=reconstruction{:,1};

for frame=2:size(reconstruction,2)
    nextRec=reconstruction{:,frame};
    newRec=newRec+nextRec;
end
newRec=newRec/size(reconstruction,2);
newRec={newRec};

end
