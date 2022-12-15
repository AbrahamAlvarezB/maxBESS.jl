module maxBESS

using AxisKeys
using AxisKeys: sortkeys
using CSV
using Dates
using DataFrames
using Documenter
using JuMP
using JuMP.Containers: DenseAxisArray

# Types

# Utility functions
include("utils/outputs.jl")
include("utils/post_process.jl")
include("utils/plots.jl")
include("utils/write.jl")

# Model functions
include("model/constraints.jl")
include("model/objectives.jl")
include("model/variables.jl")

# Templates
include("templates/max_profits.jl")

# Templates
export max_profits

# Variable functions
export var_charge_discharge!
export var_state_of_charge!
export var_cycles!

# Constraint functions
export con_state_of_charge!
export con_charge_discharge_rates!
export con_max_cycles!
export con_market3!

# Objective functions
export obj_raw_profits!

# Outputs

end
