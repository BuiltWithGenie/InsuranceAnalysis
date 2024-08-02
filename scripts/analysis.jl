using CSV
using DataFrames
using Dates
using Statistics
using Plots
using StatsPlots

# Load the data
df = CSV.read("actuarial_data.csv", DataFrame)

# 1. Basic statistics
function calculate_basic_stats(df)
    total_policies = nrow(df)
    total_premium = sum(df.premium)
    total_claims = sum(df.claims)
    total_claim_amount = sum(df.claim_amount)
    
    println("Total number of policies: ", total_policies)
    println("Total premium collected: \$", round(total_premium, digits=2))
    println("Total number of claims: ", total_claims)
    println("Total claim amount: \$", round(total_claim_amount, digits=2))
end

# 2. Loss ratio
function calculate_loss_ratio(df)
    loss_ratio = sum(df.claim_amount) / sum(df.premium)
    println("Overall loss ratio: ", round(loss_ratio, digits=4))
    return loss_ratio
end

# 3. Claim frequency
function calculate_claim_frequency(df)
    claim_frequency = sum(df.claims) / nrow(df)
    println("Claim frequency: ", round(claim_frequency, digits=4))
    return claim_frequency
end

# 4. Average claim severity
function calculate_avg_claim_severity(df)
    avg_severity = mean(df.claim_amount[df.claim_amount .> 0])
    println("Average claim severity: \$", round(avg_severity, digits=2))
    return avg_severity
end

# 5. Loss ratio by policy type
function loss_ratio_by_policy_type(df)
    grouped = groupby(df, :policy_type)
    loss_ratios = combine(grouped, 
        :claim_amount => sum => :total_claims, 
        :premium => sum => :total_premium)
    loss_ratios.loss_ratio = loss_ratios.total_claims ./ loss_ratios.total_premium
    return loss_ratios
end

# 6. Visualizations
function create_visualizations(df)
    # Loss ratio by policy type
    lr_by_type = loss_ratio_by_policy_type(df)
    p1 = bar(lr_by_type.policy_type, lr_by_type.loss_ratio, 
        title="Loss Ratio by Policy Type", ylabel="Loss Ratio")

    # Claim amount distribution
    p2 = histogram(df.claim_amount[df.claim_amount .> 0], 
        title="Distribution of Claim Amounts", xlabel="Claim Amount", ylabel="Frequency")

    # Premium vs Claim Amount scatter plot
    p3 = scatter(df.premium, df.claim_amount, 
        title="Premium vs Claim Amount", xlabel="Premium", ylabel="Claim Amount")

    # Time series of policies and claims
    df.year_month = Dates.format.(df.start_date, "yyyy-mm")
    policies_over_time = combine(groupby(df, :year_month), nrow => :count)
    claims_over_time = combine(groupby(df, :year_month), :claims => sum => :total_claims)
    
    p4 = plot(policies_over_time.year_month, policies_over_time.count, 
        label="Policies", title="Policies and Claims Over Time", 
        xlabel="Date", ylabel="Count")
    plot!(p4, claims_over_time.year_month, claims_over_time.total_claims, label="Claims")

    # Save plots
    savefig(p1, "loss_ratio_by_type.png")
    savefig(p2, "claim_amount_distribution.png")
    savefig(p3, "premium_vs_claim.png")
    savefig(p4, "policies_and_claims_over_time.png")
    
    println("Plots saved as PNG files.")
end

# Run analyses
println("Basic Statistics:")
calculate_basic_stats(df)
println("\nKey Metrics:")
calculate_loss_ratio(df)
calculate_claim_frequency(df)
calculate_avg_claim_severity(df)
println("\nLoss Ratio by Policy Type:")
println(loss_ratio_by_policy_type(df))
println("\nCreating visualizations...")
create_visualizations(df)
