function format_currency(dt::DataTable)
    currency_columns = ["LossUsdOur", "TotalLoss", "GrossLoss", "RipUsdOur"]
    for col in currency_columns
        dt.opts.columnspecs[col] =
            Stipple.opts(
                format=Stipple.jsfunction(raw"""
                                          (val, row) => val.toLocaleString('en-US', {
                                          minimumFractionDigits: 2,
                                          maximumFractionDigits: 2
                                          })
                                          """)
            )
    end
    return dt
end
