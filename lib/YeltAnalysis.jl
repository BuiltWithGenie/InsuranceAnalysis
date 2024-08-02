module YeltDataAnalysis

using CSV
using DataFrames
using Statistics

export load_yelt_data, load_lookup_table, calculate_yearly_losses, calculate_return_periods, analyze_specific_return_period

# Loads the YELT data from a CSV file into a DataFrame
function load_yelt_data(filepath::String)
    return CSV.read(filepath, DataFrame)
end

# Loads the lookup table from a CSV file into a DataFrame
function load_lookup_table(filepath::String)
    return CSV.read(filepath, DataFrame)
end

# Calculates the total yearly losses from the YELT data
function calculate_yearly_losses(df::DataFrame)
    yearly_losses = combine(groupby(df, :Year), :LossUsdOur => sum => :TotalLoss)
    sort!(yearly_losses, :TotalLoss, rev=true)
    return yearly_losses
end

# Calculates the losses for specified return periods based on the yearly losses
# Return period: for a X-year return period, the associated loss represents the level of loss that is expected to be equaled or exceeded, on average, once every X years.
function calculate_return_periods(yearly_losses::DataFrame, return_periods::Vector{Int})
    n_years = nrow(yearly_losses)
    result = DataFrame(ReturnPeriod=Int[], GrossLoss=Float64[], Position=Int[])

    for rp in return_periods
        position = max(1, min(round(Int, n_years / rp), n_years))
        push!(result, (rp, yearly_losses[position, :TotalLoss], position))
    end
    return result
end

# Analyzes a specific return period, providing detailed information about the losses
function analyze_specific_return_period(df::DataFrame, yearly_losses::DataFrame, return_period::Int, lookup_table::DataFrame)
    n_years = nrow(yearly_losses)
    position = max(1, min(round(Int, n_years / return_period), n_years))
    rp_year = yearly_losses[position, :Year]
    rp_loss = yearly_losses[position, :TotalLoss]

    relevant_events = filter(row -> row.Year == rp_year, df)

    # Join with lookup table to get peril names
    relevant_events = leftjoin(relevant_events, lookup_table, on=:AccumulationPerilId)

    # Group by LayerId and AccumulationPerilName
    summary = combine(groupby(relevant_events, [:LayerId, :AccumulationPerilName]),
        :LossUsdOur => sum => :TotalLoss)

    sort!(summary, :TotalLoss, rev=true)

    return (return_period=return_period, total_loss=rp_loss, summary=summary)
end

# Runs the complete analysis pipeline, including loading data, calculating yearly losses,
# analyzing return periods, and providing a specific analysis for the highest return period
function run_analysis(yelt_data_path::String, lookup_table_path::String, return_periods::Vector{Int})
    df = load_yelt_data(yelt_data_path)
    lookup = load_lookup_table(lookup_table_path)

    yearly_losses = calculate_yearly_losses(df)
    rp_analysis = calculate_return_periods(yearly_losses, return_periods)

    # Analyze the highest return period as an example
    highest_rp = maximum(return_periods)
    specific_rp_analysis = analyze_specific_return_period(df, yearly_losses, highest_rp, lookup)

    return (yearly_losses=yearly_losses, return_periods=rp_analysis, specific_analysis=specific_rp_analysis)
end

end # module
