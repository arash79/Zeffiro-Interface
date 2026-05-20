# tES Hyperparameter Optimization

This module implements a **recursive search** for the hyperparameters (alpha, epsilon) used in Zeffiro Interface’s **Electrical Stimulation (ES)** tool for transcranial electrical stimulation (tES). Instead of manually tuning these parameters, the algorithm performs an initial grid search and then iteratively narrows the parameter space around the best objective value.

## What Is tES in Zeffiro?

Transcranial electrical stimulation (tES) applies weak currents to the scalp to modulate brain activity. Zeffiro’s ES tool helps optimize electrode currents to achieve desired electric fields in the brain. The parameters **alpha** and **epsilon** control the trade-off between target accuracy and current magnitude in this optimization.

## What Will You Learn?

- How the ES tool’s hyperparameters (alpha, epsilon) affect the optimization.
- How to run an adaptive parameter search from a script instead of the GUI.
- How to inspect `zef.adapted_y_ES`, which stores the current solution at each refinement step.

## When to Use This Module

- You use transcranial electrical stimulation (tES) in Zeffiro.
- You want to find good alpha/epsilon values programmatically rather than by trial and error.
- You are familiar with the ES tool and its objective function.

## Prerequisites

- The ES tool must be configured in your project struct (`zef`).
- You should understand what alpha and epsilon represent in the ES optimization (see ES tool documentation).

## How to Run

```matlab
zef = examples.studies.tES_hyperparameter_optimization.zef_ES_recursive_search(zef, num_lattice);
```

- `zef` — Project struct with ES tool configuration.
- `num_lattice` — Grid size for the initial and adaptive search steps (e.g., 5 or 10).

The function updates `zef.adapted_y_ES`, a cell array where each element is the current solution for that refinement iteration.

## How It Works

1. **Initial search**: A grid over (alpha, epsilon) is generated; the ES objective is evaluated; the best point (sr, sc) is identified.
2. **Adaptive refinement**: The parameter range is narrowed around that point; a new grid is generated; the process repeats.
3. **Output**: Each refinement step’s solution is stored in `zef.adapted_y_ES`.

## Files in This Module

| File | Role |
|------|------|
| `zef_ES_recursive_search.m` | Main entry point: runs initial grid search and adaptive refinement, updates `zef.adapted_y_ES`. |
| `zef_ES_centralize_recursive_search.m` | Helper: computes the new (alpha, epsilon) bounds centered on the best indices (sr, sc) from the objective. |
