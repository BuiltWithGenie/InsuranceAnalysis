include("lib/YeltAnalysis.jl")
using .YeltDataAnalysis

# Paths to your data files
yelt_data_path = "data/yelt-data.csv"
lookup_table_path = "data/lookup.csv"

# Define the return periods you're interested in
return_periods = [100, 50, 25, 10, 5, 2, 1]

# Run the analysis
results = YeltDataAnalysis.run_analysis(yelt_data_path, lookup_table_path, return_periods)

# Access the results
println("Yearly Losses:")
println(results.yearly_losses)

println("\nReturn Period Analysis:")
println(results.return_periods)

println("\nSpecific Return Period Analysis:")
println("Return Period: ", results.specific_analysis.return_period)
println("Total Loss: ", results.specific_analysis.total_loss)
println("Top Contributors:")
println(first(results.specific_analysis.summary, 10))
