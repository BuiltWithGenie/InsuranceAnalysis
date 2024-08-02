module Yelt

using GenieFramework
using DataFrames
using Statistics
using Main.YeltDataAnalysis
@genietools

const yelt_data = load_yelt_data("data/yelt-data.csv")
const lookup_table = load_lookup_table("data/lookup.csv")
const yearly_losses = calculate_yearly_losses(yelt_data)
const _data_years = 100
const _return_periods = [5, 10, 20, 50, 100]
const rp_analysis = calculate_return_periods(yearly_losses, _return_periods)

@app begin
    @out yelt_data_table = DataTable(first(yelt_data, 10))
    @out yearly_losses_table = DataTable(yearly_losses)
    @out yearly_losses_pagination = DataTablePagination(rows_per_page=_data_years, rows_number=_data_years)
    @out return_periods_table = DataTable(rp_analysis)
    @out specific_rp_analysis_table = DataTable()
    @out data_years = _data_years
    @out return_periods = _return_periods
    @out pagination = DataTablePagination(rows_per_page=10, rows_number=size(yelt_data)[1])

    @event request begin
        # the process_request function will select the portion of df to be displayed as table_page
        state = StippleUI.Tables.process_request(yelt_data, data_table_page, pagination, "")
        data_table_page = state.datatable  # the selected portion of df
        pagination = state.pagination # update the pagination state in the backend and the browser
    end

    @in selected_return_period = min(100, _data_years)

    @onchange selected_return_period, isready begin
        analysis = analyze_specific_return_period(yelt_data, yearly_losses, selected_return_period, lookup_table)
        specific_rp_analysis_table = DataTable(analysis.summary)
    end

end

@page("/yelt", "yelt.jl.html")

end
