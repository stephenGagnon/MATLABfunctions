module MATLABfunctions
using MATLAB
# using Infiltrator

export MATLABhistogram, plot3, MRPScatterPlot, plotSat, multiQuiverPlot3, closeAll, saveData, imagesc, plot_MATLAB, subplot_MATLAB

struct spaceScenario
    obsNo
    C
    d
    sunVec
    obsVecs
end

function MATLABHistogram(data, binNo)

    @mput data
    @mput binNo

    eval_string("""

    f = figure
    histogram(data,binNo)
    """)
end

function plot3(p, c=nothing)

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

function MRPScatterPlot(p, c)

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
        scen = spaceScenario(scenI.obsNo, scenI.C, scenI.d[:], scenI.sunVec, obsVecsm)
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

function multiQuiverPlot3(v, p, c=nothing)

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

function imagesc(x, y, M; xlabelstring="x", ylabelstring="y", titlestring="", clim="auto")
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

function saveData(filename, varnames, data; path="/Users/stephengagnon/matlab/storage/dataFromJulia/")

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

function plot_MATLAB(t, x, varin...; title_string="", xlabel_string="", ylabel_string="", xlim_val=nothing, ylim_val=nothing, grid_check=false)
    linespec = Array{Any,1}(undef, length(varin))
    linespec[:] .= varin[:]
    @mput t
    @mput x
    @mput linespec
    @mput title_string
    @mput xlabel_string
    @mput ylabel_string
    if !isnothing(xlim_val)
        @mput xlim_val
    end
    if !isnothing(ylim_val)
        @mput ylim_val
    end
    @mput grid_check

    if !isnothing(xlim_val) && !isnothing(ylim_val)
        eval_string("plot(t,x,linespec{:}); title(title_string); xlabel(xlabel_string); ylabel(ylabel_string); xlim(xlim_val); ylim(ylim_val); if grid_check; grid on; end")
    elseif !isnothing(xlim_val)
        eval_string("plot(t,x,linespec{:}); title(title_string); xlabel(xlabel_string); ylabel(ylabel_string); xlim(xlim_val); if grid_check; grid on; end")
    elseif !isnothing(ylim_val)
        eval_string("plot(t,x,linespec{:}); title(title_string); xlabel(xlabel_string); ylabel(ylabel_string); ylim(ylim_val); if grid_check; grid on; end")
    elseif isnothing(xlim_val) && isnothing(ylim_val)
        eval_string("plot(t,x,linespec{:}); title(title_string); xlabel(xlabel_string); ylabel(ylabel_string); if grid_check; grid on; end")
    end
end

function subplot_MATLAB(t, x, linespec; title_string=emptyStringArray(size(t)), xlabel_string=emptyStringArray(size(t)), ylabel_string=emptyStringArray(size(t)), xlim_val="no value", ylim_val="no value", grid_check=Array{Bool,length(size(t))}(undef, size(t)) .= false)

    @mput t
    @mput x
    @mput linespec
    @mput title_string
    @mput xlabel_string
    @mput ylabel_string
    if !isnothing(xlim_val)
        @mput xlim_val
    end
    if !isnothing(ylim_val)
        @mput ylim_val
    end
    @mput grid_check

    # eval_string("""
    # save("/Users/stephengagnon/matlab/storage/dataFromJulia/test",'t','x','linespec')
    # """)

    eval_string(
        raw" count = 1;
        [n,m] = size(t);
        f = figure;
        for i = 1:n
            for j = 1:m
                subplot(n,m,count)
                hold on
                
                for k = 1:length( x{i,j} )
                    plot(t{i,j}, x{i,j}{k} , linespec{i,j}{k}{:})
                end
    
                title(title_string{i,j}); 
                xlabel(xlabel_string{i,j}); 
                ylabel(ylabel_string{i,j});
    
                if class(xlim_val) == 'cell'
                    xlim(xlim_val{i,j});
                end
                if class(ylim_val) == 'cell'
                    ylim(ylim_val{i,j});
                end
    
                if grid_check(i,j)
                        grid on
                end
    
                hold off
                count = count + 1;
            end
        end
        set(f,'position',[1 1 1792 1016])
    
        ")
end

function emptyStringArray(dims)
    out = Array{String,length(dims)}(undef, dims)
    out .= ""
    return out
end
end # module
