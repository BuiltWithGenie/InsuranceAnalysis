using DataFrames, Dates, Random, CSV, Distributions

# Set a seed for reproducibility
Random.seed!(123)

# Function to generate random dates within a range
function random_date(start_date, end_date)
    days = Dates.value(end_date - start_date)
    return start_date + Dates.Day(rand(0:days))
end

# Generate synthetic data
function generate_actuarial_data(n_policies=1000)
    # Policy types and their base premiums
    policy_types = ["Basic" => 500.0, "Standard" => 750.0, "Premium" => 1000.0]

    # Pre-allocate arrays
    start_dates = Date[]
    end_dates = Date[]
    premiums = Float64[]
    policy_types_arr = String[]
    claims_arr = Int[]
    claim_amounts = Float64[]

    for i in 1:n_policies
        # Generate policy dates
        start_date = random_date(Date(2020, 1, 1), Date(2023, 12, 31))
        end_date = start_date + Dates.Year(1)

        # Assign policy type and calculate premium
        policy_type, base_premium = rand(policy_types)
        premium = base_premium * (1 + rand(-0.1:0.01:0.1))  # Add some variation

        # Generate claims
        n_claims = rand(Poisson(0.1))  # Assume 0.1 claims per policy on average
        claim_amount = n_claims > 0 ? sum(rand(LogNormal(7, 1), n_claims)) : 0.0

        # Add to arrays
        push!(start_dates, start_date)
        push!(end_dates, end_date)
        push!(premiums, premium)
        push!(policy_types_arr, policy_type)
        push!(claims_arr, n_claims)
        push!(claim_amounts, claim_amount)
    end

    # Create DataFrame
    df = DataFrame(
        policy_id = 1:n_policies,
        start_date = start_dates,
        end_date = end_dates,
        premium = premiums,
        policy_type = policy_types_arr,
        claims = claims_arr,
        claim_amount = claim_amounts
    )

    return df
end

# Generate the data
actuarial_data = generate_actuarial_data(10000)  # Generate 10,000 policies

# Display first few rows
println(first(actuarial_data, 5))

# Save to CSV
CSV.write("actuarial_data.csv", actuarial_data)
println("Data saved to 'actuarial_data.csv'")
