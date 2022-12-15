# Define functions so that `latex` can be dispatched over them
function con_state_of_charge! end
function con_charge_discharge_rates! end
function con_market3! end
function con_max_cycles! end

# State of Charge Constraint
function latex(::typeof(con_state_of_charge!))
    return """
        ``s_{t} = \\gamma_s s_{t-1} + \\tau \\sum_{m \\in \\mathcal{M}} [\\gamma_c pc_{m, t} - ( pd_{m, t}  / \\gamma_d )  ] \\forall m \\in \\mathcal{M}, t \\in \\mathcal{T}``
        """
end

"""
    con_state_of_charge!(model::Model, gamma_s, gamma_c, gamma_d, datetimes)

Add State of charge constraints to the model:

$(latex(con_state_of_charge!))

The constraints are named `con_state_of_charge` and `con_state_of_charge_initial`.
"""
function con_state_of_charge!(model::Model, gamma_s, gamma_c, gamma_d, markets, datetimes)
    # Get variables and time steps
    s = model[:s]
    pc = model[:pc]
    pd = model[:pd]
    Δh = first(diff(datetimes))
    h1 = first(datetimes)
    tau = 1 # One half an hour since S_max = MWh and 0 <= s_t <= S_max/2
    @constraint(
        model,
        con_state_of_charge[t in datetimes[2:end]],
        s[t] == gamma_s * s[t-Δh] + tau * sum(
            gamma_c * pc[m, t] - (pd[m, t] / gamma_d) for m in markets
        )
    )
    @constraint(
        model,
        con_state_of_charge_initial[h1],
        s[h1] == 0.0
    )
    return model
end

# Charging and Discharging Rates
function latex(::typeof(con_charge_discharge_rates!))
    return """
        ``0 \\leq \\sum_{m \\in \\mathcal{M}} [pc_{m, t}] \\leq RR_c \\forall m \\in \\mathcal{M}, t \\in \\mathcal{T}`` \n
        ``0 \\leq \\sum_{m \\in \\mathcal{M}} [pd_{m, t}] \\leq RR_d \\forall m \\in \\mathcal{M}, t \\in \\mathcal{T}``
        """
end
"""
    con_charge_discharge_rates!(model::Model, RR_c, RR_d, markets, datetimes)

Add charge and discharge rates limit constraints to the model:

$(latex(con_charge_discharge_rates!))

The constraints added are named `con_charge_rate_lo`, `con_charge_rate_hi`,
`con_discharge_rate_lo`, `con_discharge_rate_hi` and their initials.
"""
function con_charge_discharge_rates!(model::Model, RR_c, RR_d, markets, datetimes)
    # Get variables and time steps
    pc = model[:pc]
    pd = model[:pd]
    h1 = first(datetimes)
    # Low Boundaries
    @constraint(
        model,
        con_charge_rate_lo[t in datetimes[2:end]],
        0.0 <= sum(pc[m, t] for m in markets)
    )
    @constraint(
        model,
        con_discharge_rate_lo[t in datetimes[2:end]],
        0.0 <= sum(pd[m, t] for m in markets)
    )
    # High Boundaries
    @constraint(
        model,
        con_charge_rate_hi[t in datetimes[2:end]],
        sum(pc[m, t] for m in markets) <= RR_c
    )
    @constraint(
        model,
        con_discharge_rate_hi[t in datetimes[2:end]],
        sum(pd[m, t] for m in markets) <= RR_d
    )
    # Initial States
    @constraint(
        model,
        con_charge_rate_initial[h1],
        sum(pc[m, h1] for m in markets) == 0.0
    )
    @constraint(
        model,
        con_discharge_rate_initial[h1],
        sum(pd[m, h1] for m in markets) == 0.0
    )
    return model
end

# Market 3 Constraints
function latex(::typeof(con_market3!))
    return """
        ``pc_{m, t} - pc_{m, t-1} = 0.0 \\forall m = m3, t \\in \\mathcal{T} \\setminus \\{time_zero\\}`` \n
        ``pd_{m, t} - pc_{m, t-1} = 0.0 \\forall m = m3, t \\in \\mathcal{T} \\setminus \\{time_zero\\}``
        """
end
"""
    con_market3!(model::Model, datetimes)

Add Market 3 constraint: It must export/import a constant level of power for the full day.

$(latex(con_market3!))

The constraints added are named `con_market3_pc`and `con_market3_pd`.
"""
function con_market3!(model::Model, datetimes)
    # Get variables and time steps
    pc = model[:pc]
    pd = model[:pd]
    Δh = first(diff(datetimes))
    # Skip time 00:00:00 of each day to let it free
    subset_datetimes = filter(datetimes) do x
        Dates.Time(x) == Time(00, 00, 00)
    end
    # Add constraints for the remaining hours
    @constraint(
        model,
        con_market3_pc[t in subset_datetimes],
        pc["m3", t] - pc["m3", t-Δh] == 0.0
    )
    @constraint(
        model,
        con_market3_pd[t in subset_datetimes],
        pd["m3", t] - pd["m3", t-Δh] == 0.0
    )
    return model
end

# Cycle lifetime constraints
function latex(::typeof(con_max_cycles!))
    return """
        ``z = \\sum_{t \\in \\mathcal{T}} [ \\sum_{m \\in \\mathcal{M}} [((100 \\tau pd_{m, t}) / (S_max/2))/100 ] ]  `` \n
        """
end
"""
    con_max_cycles!(model::Model, lifetime_cycles, S_max, markets, datetimes)

Add Maximum battery lifetime constraint in battery cycles equivalent - one cycle is defined
as charging up to max storage volume and then discharging all stored energy. This does not
have to be done in one go - e.g. charging up to 75%, discharging to 0%, then charging up to
25% and discharging to 0% still counts as one cycle.

$(latex(con_max_cycles!))

The constraints added are named `con_total_cycles` and `con_max_cycles`.
"""
function con_max_cycles!(model::Model, lifetime_cycles, S_max, markets, datetimes)
    # Get variables and time steps
    z = model[:z]
    pd = model[:pd]
    # Add constraints for max cycles
    @constraint(
        model,
        con_total_cycles,
        z == S_max * sum(pd[m, t] for (m, t) in (markets, datetimes))
    )
    @constraint(
        model,
        con_max_cycles,
        z <= lifetime_cycles
    )
    return model
end
