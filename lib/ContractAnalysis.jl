module ContractAnalysis

using CSV
using DataFrames
using Dates
using Statistics

export analyze_contracts, print_top_n, aggregate_data, prepare_treemap_data

function preprocess_data(file_path)
    df = CSV.read(file_path, DataFrame)

    df.InceptionDate = Date.(df.InceptionDate, "m/d/y")
    df.ExpirationDate = Date.(df.ExpirationDate, "m/d/y")
    df.Year = year.(df.InceptionDate)

    df.AdjustedPremium = df.Premium100 .* df.Share .* df.LatestFxRate
    df.AdjustedLimit = df.Limit100 .* df.Share .* df.LatestFxRate
    df.AdjustedExpectedLoss = df.ExpectedLoss100 .* df.Share .* df.LatestFxRate

    return df
end

loss_ratio(premium, expected_loss) = expected_loss / premium

function aggregate_data(df, dims, value_col)
    gdf = groupby(df, dims)
    combine(gdf, value_col => sum => value_col)
end

function hierarchical_aggregation(df, hierarchy, value_col)
    result = DataFrame()
    for i in 1:length(hierarchy)
        dims = hierarchy[1:i]
        agg = aggregate_data(df, dims, value_col)

        for col in setdiff(hierarchy, dims)
            agg[!, col] .= missing
        end

        agg[!, :Level] .= i
        select!(agg, [hierarchy..., value_col, :Level])
        result = vcat(result, agg)
    end
    sort(result, [:Level, value_col], rev=true)
end

function print_top_n(df, n=5)
    println(first(df, n))
    if nrow(df) > n
        println("...")
    end
end

function analyze_contracts(file_path)
    df = preprocess_data(file_path)

    premium_by_client_year = aggregate_data(df, [:ClientName, :Year], :AdjustedPremium)

    loss_ratio_by_contract_bu_year = combine(
        groupby(df, [:LayerTypeName, :BusinessUnit, :Year]),
        [:AdjustedPremium, :AdjustedExpectedLoss] =>
            ((premium, loss) -> loss_ratio(sum(premium), sum(loss))) => :LossRatio
    )

    premium_by_underwriter = aggregate_data(df, :Underwriter, :AdjustedPremium)

    hierarchy = [:LegalEntity, :BusinessUnit, :BusinessSegment]
    hierarchical_premium = hierarchical_aggregation(df, hierarchy, :AdjustedPremium)

    return (
        data=df,
        premium_by_client_year=premium_by_client_year,
        loss_ratio_by_contract_bu_year=loss_ratio_by_contract_bu_year,
        premium_by_underwriter=premium_by_underwriter,
        hierarchical_premium=hierarchical_premium
    )
end

function prepare_treemap_data(df)
    sort!(df, :Level)

    labels = String[]
    parents = String[]
    values = Float64[]

    for row in eachrow(df)
        if row.Level == 1
            push!(labels, row.LegalEntity)
            push!(parents, "World")
            push!(values, row.AdjustedPremium)
        elseif row.Level == 2
            push!(labels, "$(row.LegalEntity[1:3]) - $(row.BusinessUnit)")
            push!(parents, row.LegalEntity)
            push!(values, row.AdjustedPremium)
        elseif row.Level == 3
            push!(labels, row.BusinessSegment)
            push!(parents, "$(row.LegalEntity[1:3]) - $(row.BusinessUnit)")
            push!(values, row.AdjustedPremium)
        end
    end


    return (labels=labels, parents=parents, values=values)
end

end # module
