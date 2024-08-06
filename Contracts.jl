module App
using GenieFramework, DataFrames
using Main.ContractAnalysis
@genietools

const results = analyze_contracts("data/contracts-data.csv")
const _columns = names(results.data)
const _treemap_data = prepare_treemap_data(results.hierarchical_premium)
const N = size(results.data)[1]

@app begin
    # Main table
    @out data_table_page = DataTable()
    #=@out pagination = DataTablePagination(rows_per_page=10, rows_number=size(results.data)[1])=#
    @out pagination = DataTablePagination(rows_per_page=10, rows_number=N)
    @in filter = ""
    @onchange isready begin
        data_table_page = DataTable(results.data)
    end
    #==#
    #=@event request begin=#
    #=    # the process_request function will select the portion of df to be displayed as table_page=#
    #=    state = StippleUI.Tables.process_request(results.data, data_table_page, pagination, "")=#
    #=    data_table_page = state.datatable  # the selected portion of df=#
    #=    pagination = state.pagination # update the pagination state in the backend and the browser=#
    #=end=#

    # Data aggregation
    @in metrics_options = _columns
    @in target = :AdjustedPremium
    @in selected_metrics = [:ClientName, :Year]
    @out aggregated_data = DataTable(aggregate_data(results.premium_by_client_year, [:ClientName, :Year], :AdjustedPremium))
    @in filter_agg = ""

    @onchange selected_metrics, target begin
        aggregated_data = DataTable(aggregate_data(results.data, selected_metrics, target))
    end

    # Data grouping
    @out columns = _columns
    @in group_by = :Underwriter
    @in group_select::Any = "Jeff"
    @out group_keys::Any = unique(results.data[:, :Underwriter])
    @out selected_group_table = DataTable()

    @onchange group_by begin
        group_keys = unique(results.data[:, group_by]) |> sort
        group_select = group_keys[1]
    end

    @onchange group_select, isready begin
        gdf = groupby(results.data, group_by)
        selected_group_table = gdf[(group_select,)] |> DataFrame |> DataTable
    end

    @out hierarchical_premium = results.hierarchical_premium
    @out hierarchical_premium_table = results.hierarchical_premium

    # Treemap
    @out tmap_labels = _treemap_data.labels
    @out tmap_parents = _treemap_data.parents
    @out tmap_values = _treemap_data.values
    @out text = "Treemap of Premiums by Client and Year"
end

@page("/", "contracts.jl.html")
end
