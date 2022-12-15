using AxisKeys
using CSV
using Dates
using DataFrames
using DataFramesMeta
using HiGHS
using JuMP.Containers: DenseAxisArray
using JuMP
using MathOptInterface: TerminationStatusCode
using maxBESS
using Plots

# ---Data---
# Study Period
start_date = DateTime(2018, 1, 1, 00, 00)
end_date = DateTime(2020, 12, 31, 23, 30)
datetimes = [start_date:Minute(30):end_date;]
# Markets
markets = ["m1", "m2", "m3"]
price = DenseAxisArray{Float64}(
    undef, markets, datetimes
)
market_prices = DataFrame(CSV.File("./data/market_prices.csv"))
price["m1", datetimes] = market_prices[:, :market_1_price]
price["m2", datetimes] = market_prices[:, :market_2_price]
price["m3", datetimes] = market_prices[:, :market_3_price]
# Battery Parameters
S_min = 0.0 # [MWh]
S_max = 4.0 # [MWh]
gamma_s = 0.99 # [Fraction]
gamma_c = 0.95 # [Fraction]
gamma_d = 0.95 # [Fraction]
RR_c = 2 # [MW]
RR_d = 2 # [MW]
consider_lifetime = true
lifetime_cycles = 5000 # [cycles]
consider_fees = true
operational_costs = DenseAxisArray{Float64}(
    undef, datetimes
)
operational_costs[datetimes] = fill(10000 / length(datetimes), length(datetimes)) # Cost per year 5000£/year
capex = DenseAxisArray{Float64}(
    undef, datetimes
)
capex[datetimes] = fill(500000 / length(datetimes), length(datetimes)) # Capex divided in all timeslots
# Solver
solver = HiGHS.Optimizer

# Build Optimization Model
model = build_max_BESS_profits(
    solver,
    markets,
    datetimes,
    price,
    S_min,
    S_max,
    gamma_s,
    gamma_c,
    gamma_d,
    RR_c,
    RR_d,
    operational_costs,
    capex;
    consider_lifetime=consider_lifetime,
    lifetime_cycles=lifetime_cycles,
    consider_fees=consider_fees
)
# Solve Optimization Model
optimize!(model)

# Results
status = termination_status(model)
p_status = primal_status(model)
d_status = dual_status(model)
raw_total_profits = objective_value(model)

# Results Treatment
charge_discharge_df = charge_discharge_dataframe(model, markets, datetimes)
profits_df = profits_dataframe(model, markets, datetimes, operational_costs, capex)

# Export Results
CSV.write("charge_discharge.csv", charge_discharge_df)
CSV.write("profits.csv", profits_df)

# Display Plots
plotly()
plot_charge(model, markets, datetimes)
plot_discharge(model, markets, datetimes)
plot_raw_profits(model, markets, datetimes)
plot_std_profits(model, markets, datetimes)
plot_profits(model, markets, datetimes)
