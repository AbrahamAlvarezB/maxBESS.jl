function plot_charge(model::Model, markets, datetimes)
    pc = model[:pc]
    charge_m = Array{Float64}(undef, (length(datetimes), 3))
    charge_m[:, 1] = value.(pc["m1", datetimes].data)
    charge_m[:, 2] = value.(pc["m2", datetimes].data)
    charge_m[:, 3] = value.(pc["m3", datetimes].data)
    plot(datetimes, charge_m, title="Battery Charge",
        label=["Charge M1" "Charge M2" "Charge M3"], legend=:topleft)
    xlabel!("DateTimes")
    a = ylabel!("Charge [MW]")
    return display(a)
end
function plot_discharge(model::Model, markets, datetimes)
    pd = model[:pd]
    discharge_m = Array{Float64}(undef, (length(datetimes), 3))
    discharge_m[:, 1] = value.(pd["m1", datetimes].data)
    discharge_m[:, 2] = value.(pd["m2", datetimes].data)
    discharge_m[:, 3] = value.(pd["m3", datetimes].data)
    plot(datetimes, discharge_m, title="Battery Discharge",
        label=["Discharge M1" "Discharge M2" "Discharge M3"], legend=:topleft)
    xlabel!("DateTimes")
    a = ylabel!("Discharge [MW]")
    return display(a)
end
function plot_raw_profits(model::Model, markets, datetimes)
    rp = model[:raw_profits]
    p = Array{Float64}(undef, (length(datetimes), 1))
    p[:, 1] = value.(rp[datetimes].data)
    plot(datetimes, p, title="Raw Profits",
        label=["Raw_Profits"], legend=:topleft)
    xlabel!("DateTimes")
    a = ylabel!("Raw Profits [£]")
    return display(a)
end
function plot_std_profits(model::Model, markets, datetimes)
    sp = model[:profits]
    p = Array{Float64}(undef, (length(datetimes), 1))
    p[:, 1] = value.(sp[datetimes].data)
    plot(datetimes, p, title="Standard Profits",
        label=["Std_Profits"], legend=:topleft)
    xlabel!("DateTimes")
    a = ylabel!("Standard Profits [£]")
    return display(a)
end
function plot_profits(model::Model, markets, datetimes)
    rp = model[:raw_profits]
    sp = model[:profits]
    p = Array{Float64}(undef, (length(datetimes), 2))
    p[:, 1] = value.(rp[datetimes].data)
    p[:, 2] = value.(sp[datetimes].data)
    plot(datetimes, p, title="Profits",
        label=["Raw_Profits" "Std_Profits"], legend=:topleft)
    xlabel!("DateTimes")
    a = ylabel!("Profits [£]")
    return display(a)
end
