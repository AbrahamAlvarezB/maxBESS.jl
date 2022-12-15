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

# ---Data---
# Markets
markets = ["m1", "m2", "m3"]
price = DenseAxisArray{Float64}(
    undef, markets, datetimes
)
market_prices = DataFrame(CSV.File("./data/market_prices.csv"))
price["m1", datetimes] = market_prices[:, :market_1_price]
price["m2", datetimes] = market_prices[:, :market_2_price]
price["m3", datetimes] = market_prices[:, :market_3_price]
# Study Period
start_date = DateTime(2018, 1, 1, 00, 00)
end_date = DateTime(2020, 12, 31, 23, 30)
datetimes = [start_date:Minute(30):end_date;]
# Battery Parameters
S_min = 0.0 # [MWh]
S_max = 4.0 # [MWh]
gamma_s = 0.99 # [Fraction]
gamma_c = 0.95 # [Fraction]
gamma_d = 0.95 # [Fraction]
RR_c = 2 # [MW]
RR_d = 2 # [MW]
consider_lifetime = false
lifetime_cycles = 5000 # [cycles]
# Solver
solver = HiGHS.Optimizer

# Build Optimization Model
build_max_BESS_profits(
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
    RR_d;
    consider_lifetime=consider_lifetime,
    lifetime_cycles=lifetime_cycles
)
# Solve Optimization Model

# Results
