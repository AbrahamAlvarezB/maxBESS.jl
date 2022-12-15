module maxBESS

using AxisKeys
using AxisKeys: sortkeys
using CSV
using Dates
using DataFrames
using Documenter
using JuMP
using JuMP.Containers: DenseAxisArray
using Plots

# Utility functions
include("utils/outputs.jl")
include("utils/plots.jl")
include("utils/write.jl")

# Model functions
include("model/constraints.jl")
include("model/objectives.jl")
include("model/variables.jl")

# Templates
include("templates/max_profits.jl")

# Templates
export build_max_BESS_profits

# Variable functions
export var_charge_discharge!
export var_state_of_charge!
export var_cycles!
export var_profits_over_time!

# Constraint functions
export con_state_of_charge!
export con_charge_discharge_rates!
export con_max_cycles!
export con_market3!
export con_profits_over_time!

# Objective functions
export obj_raw_profits!

# Outputs
export charge_discharge_dataframe
export profits_dataframe

# Plots
export plot_charge
export plot_discharge
export plot_raw_profits
export plot_std_profits
export plot_profits

end
