module MATLABfunctions
using MATLAB
# using Infiltrator

export MATLABhistogram, plot3, MRPScatterPlot, plotSat, multiQuiverPlot3, closeAll, saveData, imagesc

struct spaceScenario
    obsNo
    C
    d
    sunVec
    obsVecs
end

function MATLABHistogram(data,binNo)

    @mput data
    @mput binNo

    eval_string("""

    f = figure
    histogram(data,binNo)
    """)
end

function plot3(p,c=nothing)

    if c == nothing
        @mput p

        eval_string("""

        f = figure
        ax = gca
        hold on
        for i = 1:size(p,2)

            plot3(ax,p(1,i),p(2,i),p(3,i),'*')

        end
        hold off

        """)
    else
        @mput p
        @mput c

        eval_string("""

        f = figure
        ax = gca
        hold on
        for i = 1:size(p,2)

            plot3(ax,p(1,i),p(2,i),p(3,i),'*','color',c(:,i))

        end
        hold off

        """)
    end
end

function MRPScatterPlot(p,c)

    @mput p
    @mput c

    eval_string("""

    f = figure
    ax = gca
    hold on
    for i = 1:size(p,2)

        plot3(ax,p(1,i),p(2,i),p(3,i),'*','color',c(:,i))

    end
    hold off

    """)
end

function plotSat(obj, scenI, A)

    # if typeof(s) != MSession
    #
    # end
    if typeof(scenI.obsVecs) == Array{Array{Float64,1},1}
        obsVecsm = hcat(scenI.obsVecs...)
        scen = spaceScenario(scenI.obsNo,scenI.C,scenI.d[:],scenI.sunVec,obsVecsm)
    else
        scen = scenI
    end
    @mput obj
    # put_variable(s, :obj, mxarray(obj))
    @mput scen
    # put_variable(s, :scen, mxarray(scen))
    @mput A
    # put_variables(s, :A, mxarray(A))


    eval_string("""
        addpath("/Users/stephengagnon/matlab/NASA");
        sat = objectGeometry('facetNo',obj.facetNo,'Area',obj.Areas,'nu',obj.nu,'nv',obj.nv,...
        'Rdiff',obj.Rdiff,'Rspec',obj.Rspec,'I',obj.J,'vertices',obj.vertices,...
        'facetVerticesList',obj.vertList,'Attitude',A,'obsNo',scen.obsNo,'obsVecs',scen.obsVecs,...
        'obsDist',scen.d,'sunVec',scen.sunVec,'C',scen.C);

        sat = sat.plot()
        """)
end

function multiQuiverPlot3(v,p,c=nothing)

    @mput v
    @mput p

    if c == nothing
        eval_string("""
        figure
        hold on
        for i = 1:size(v,2)
            quiver3(p(1,i),p(2,i),p(3,i),v(1,i),v(2,i),v(3,i))
        end
        """)
    else
        @mput c
        eval_string("""
        figure
        hold on
        for i = 1:size(v,2)
            quiver3(p(1,i),p(2,i),p(3,i),v(1,i),v(2,i),v(3,i),'color',c(:,i))
        end
        """)
    end
end

function imagesc(x,y,M; xlabelstring = "x",ylabelstring = "y",titlestring = "",clim = "auto")
    @mput M
    @mput x
    @mput y
    @mput xlabelstring
    @mput ylabelstring
    @mput titlestring
    @mput clim

    eval_string("""
    figure
    imagesc(x,y,M)
    xlabel(xlabelstring)
    ylabel(ylabelstring)
    title(titlestring)
    colorbar
    caxis(clim)
    set(gca,'YDir','normal')
    """)
end

function closeAll()
    eval_string("""
    close all""")
end

function saveData(filename, varnames, data; path = "/Users/stephengagnon/matlab/storage/dataFromJulia/")

    @mput filename
    @mput path

    mdata = Dict(varnames[i] => data[i] for i = 1:length(varnames))
    @mput mdata

    eval_string("""
    fullPath = string(strcat(path,filename))
    mdata
    save(fullPath,'mdata')
    """)
end


end # module
