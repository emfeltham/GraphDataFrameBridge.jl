import DataFrames.DataFrame

"""
    DataFrame(gr::T; type = :node) where T <:AbstractMetaGraph

Construct a DataFrame from a MetaGraph from either its node or edge properties.

`gr` is a MetaGraph.

Optional keyword arguments:

`type` is a Symbol valued either :node or :edge such that the DataFrame is populated with node or edge
properties stored in `gr`. Default is :node.

"""
function DataFrame(gr::T; type = :node) where T <:AbstractMetaGraph
    fl, prps, en, nu = if type == :node
        :node => Int[], gr.vprops, vertices, nv
    elseif type == :edge
        :edge => Edge[], gr.eprops, edges, ne
    else
        error("You must specify type as :node or :edge")
    end

    dx = DataFrame(fl)

    # this block only applies if there are defined properties
    # on the MetaGraph object `gr`
    if length(values(prps)) > 0
        x = unique(reduce(vcat, values(prps)))
        for y in x
            for (k, v) in y
                if typeof(v) != Missing # update if there are non-missing entries
                    dx[!, k] = typeof(v)[]
                end
                if string(k) ∈ names(dx)
                    allowmissing!(dx, k)
                end
            end
        end
    end
    
    dx = similar(dx, nu(gr))

    for (i, e) in (enumerate∘en)(gr)

        dx[i, type] = e
        pr = props(gr, e)
        for (nme, val) in pr
            dx[i, nme] = val
        end
    end
    
    for v in Symbol.(names(dx))
        if !any(ismissing.(dx[!, v]))
            disallowmissing!(dx, v)
        end
    end
    return dx
end
