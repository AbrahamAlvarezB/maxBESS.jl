# Define functions so that `latex` can be dispatched over them
function var_charge_discharge! end
function var_state_of_charge! end
function var_cycles! end

# Charge and Discharge variables
function latex(::typeof(var_charge_discharge!))
    return """
    ``0 \\leq pc_{m, t} \\leq RR_c, \\forall m \\in \\mathcal{M}, t \\in \\mathcal{T}`` \n
    ``0 \\leq pd_{m, t} \\leq RR_d, \\forall m \\in \\mathcal{M}, t \\in \\mathcal{T}``
    """
end

"""
    var_charge_discharge!(model::Model, RR_c, RR_d, datetimes)

Adds the charge `pc` and discharge `pd` variables indexed, respectively, by the `m` market
in the set of `M` markets and by the time periods considered. The variables units are [MW].

$(latex(var_charge_discharge!))
"""
function var_charge_discharge!(model::Model, RR_c, RR_d, markets, datetimes)
    @variable(model, 0 <= pc[m in markets, t in datetimes] <= RR_c)
    @variable(model, 0 <= pd[m in markets, t in datetimes] <= RR_d)
    return model
end

# State of Charge variable
function latex(::typeof(var_state_of_charge!))
    return """
    ``S_min \\leq s_{t} \\leq S_max/2, \\forall t \\in \\mathcal{T}``
    """
end

"""
    var_state_of_charge!(model::Model, S_min, S_max, datetimes)

Adds the State of Charge (SOC) `s` variable indexed by the time periods and bounded by the
minimum and maximum storage volume `S_min` and `Smax` respectively. The SOC units are [MWh].
Since the granularity is every half an hour, 0 <= s_t <= S_max/2

$(latex(var_state_of_charge!))
"""
function var_state_of_charge!(model::Model, S_min, S_max, datetimes)
    @variable(model, S_min <= s[t in datetimes] <= S_max / 2)
    return model
end

# Cycles variable
function latex(::typeof(var_cycles!))
    return """
    ``z \\geq 0``
    """
end

"""
    var_cycles!(model::Model)

Adds the cycles `z` variable. One cycle is defined as charging up to max storage volume
`100%` and  then discharging all stored energy. This does not have to be done in one go
e.g. charging up to 75%, discharging to 0%, then charging up to 25% and discharging to 0%
still counts as one cycle.

$(latex(var_cycles!))
"""
function var_cycles!(model::Model)
    @variable(model, z >= 0)
    return model
end

"""
    var_profits_over_time!(model::Model, datetimes)

Variable to storage the profits over time.

"""
function var_profits_over_time!(model::Model, datetimes)
    @variable(model, raw_profits[t in datetimes])
    @variable(model, profits[t in datetimes])
    return model
end
