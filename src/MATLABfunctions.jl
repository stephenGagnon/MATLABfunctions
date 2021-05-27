module MATLABfunctions

function MATLABHistogram(data,binNo)

    @mput data
    @mput binNo

    eval_string("""

    f = figure
    histogram(data,binNo)
    """)
end

function MATLABPlot3()

end

end # module
