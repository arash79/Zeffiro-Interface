# JL GMM — advanced fitter (`AdvancedGMM`)

First-party entry is `zef_AdvGMModeling.m`. The JL app Start button calls it when the advanced-option flags in `zef.GMM.parameters` are **not** both `'1'` (see parent plugin README).

Files such as `estep.m`, `FitAdvGMM.m`, `EstepWeight.m`, `WeightedCondDensity.m`, and `AdvGMModeling4Rec.m` are **vendor / MathWorks GMM** internals. They are not Zeffiro APIs; do not re-attribute or rewrite them as product documentation.

`plugins.ClassGMM` is a separate package and is unused from this GUI.

Plugin manual: [../../../README.md](../../../README.md).
