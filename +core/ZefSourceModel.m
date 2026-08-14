classdef ZefSourceModel
%ZEFSOURCEMODEL  Legacy enumeration stored in older Zeffiro .mat projects.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Older projects saved source models as core.ZefSourceModel. MATLAB can
%   load those files as enumerations only if this class remains an
%   enumeration with the original member names. The live type is
%   core.types.ZefSourceModel; loadobj and ZefSourceModel.from convert.
%
%   See also core.types.ZefSourceModel.

    enumeration
        Hdiv
        Whitney
        StVenant
        ContinuousHdiv
        ContinuousWhitney
        ContinuousStVenant
        Error
    end

    methods (Static)

        function self = loadobj(obj_or_struct)
        % loadobj — Map a saved core.ZefSourceModel onto core.types.ZefSourceModel.

            self = core.types.ZefSourceModel.from(obj_or_struct);
            if self == core.types.ZefSourceModel.Error
                self = core.types.ZefSourceModel.Hdiv;
            end
        end

    end

end
