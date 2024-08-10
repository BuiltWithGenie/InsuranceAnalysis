module Yelt

using GenieFramework
using DataFrames
using Statistics
using Main.YeltDataAnalysis
@genietools
format_currency = Main.format_currency

yelt_data_left = load_yelt_data("data/yelt-data.csv")
const lookup_table = load_lookup_table("data/lookup.csv")
const yelt_data = select!(leftjoin(yelt_data_left, lookup_table, on=:AccumulationPerilId), Not(:AccumulationPerilId))
const _columns = names(yelt_data)
yelt_data_left = nothing
const yearly_losses = calculate_yearly_losses(yelt_data)
const _data_years = 100
const _return_periods = [5, 10, 20, 50, 100]
const rp_analysis = calculate_return_periods(yearly_losses, _return_periods)

@app begin
    @out yelt_data_table = DataTable(first(yelt_data, 10)) |> format_currency
    @out yearly_losses_table = DataTable(yearly_losses) |> format_currency
    @out yearly_losses_pagination = DataTablePagination(rows_per_page=_data_years, rows_number=_data_years)
    @out return_periods_table = DataTable(rp_analysis) |> format_currency
    @out top_perils_rp_table = DataTable() |> format_currency
    @out data_years = _data_years
    @out return_periods = _return_periods
    @out pagination = DataTablePagination(rows_per_page=10, rows_number=size(yelt_data)[1])
    @in filteryelt = ""
    @out columns = vcat("All", _columns)
    @in select_filter_columns = ["All"]

    @event requestyelt begin
        # the process_request function will select the portion of df to be displayed as table_page
        @show filteryelt
        filter_columns = "All" in select_filter_columns   ? _columns : select_filter_columns
        filtered_data = yelt_data[[any(occursin(filteryelt, string(row[col])) for col in filter_columns) for row in eachrow(yelt_data)], :]
        println(size(filtered_data))
        if nrow(filtered_data) != 0
        state = StippleUI.Tables.process_request(filtered_data, yelt_data_table, pagination, "")
        yelt_data_table = state.datatable   # the selected portion of df
        pagination = state.pagination # update the pagination state in the backend and the browser
        else
        yelt_data_table = DataTable()
        end
    end

    @in selected_return_period = min(100, _data_years)

    @onchange selected_return_period, isready begin
        analysis = analyze_specific_return_period(yelt_data, yearly_losses, selected_return_period, lookup_table)
        top_perils_rp_table = DataTable(analysis.summary) |> format_currency
    end

end

@page("/yelt", "yelt.jl.html")

end
