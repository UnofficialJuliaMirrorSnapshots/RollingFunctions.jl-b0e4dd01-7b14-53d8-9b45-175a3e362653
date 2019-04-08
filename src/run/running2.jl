for (T1, T2) in ((:T, :(float(T))), (:(Union{Missing,T}), :(Union{Missing,float(T)})))
  @eval begin
        
    # unweighted windowed function application that tapers

    function running(fun2::Function, data1::V, data2::V, windowspan::Int) where {T, V<:AbstractVector{$T1}}
        ndata   = min(length(data1), length(data2))
        nvals   = nrolled(ndata, windowspan)
        ntapers = ndata - nvals

        result = zeros($T2, ndata)

        result[1:ntapers] = tapers2(fun2, data1[1:ntapers], data2[1:ntapers])
        ntapers += 1
        result[ntapers:ndata] = rolling(fun2, data1, data2, windowspan)

        if isnan(result[1]) && ndata > 1
            result[1] = result[2]
        end

        return result
    end

    function running(fun2::Function, data1::V, data2::V, windowspan::Int, first::A) where {A, T, V<:AbstractVector{$T1}}
        ndata   = min(length(data1), length(data2))
        nvals   = nrolled(ndata, windowspan)
        ntapers = ndata - nvals

        result = zeros($T2, ndata)

        result[1:ntapers] = tapers2(fun2, data1[1:ntapers], data2[1:ntapers])
        ntapers += 1
        result[ntapers:ndata] = rolling(fun2, data1, data2, windowspan)

        result[1] = T(first)

        return result
    end

    # weighted windowed function application that tapers

    function running(fun2::Function, data1::V, data2::V, windowspan::Int, weighting::F) where
                     {T, N<:Number, V<:AbstractVector{$T1}, F<:Vector{N}}
        ndata   = min(length(data1), length(data2))
        nvals   = nrolled(ndata, windowspan)
        ntapers = ndata - nvals

        result = zeros($T2, ndata)

        result[1:ntapers] = tapers2(fun2, data1[1:ntapers], data2[1:ntapers], weighting[end-(ntapers-1):end])
        ntapers += 1
        result[ntapers:ndata] = rolling(fun2, data1, data2, windowspan, weighting)

        if isnan(result[1]) && ndata > 1
            result[1] = result[2]
        end

        return result
    end

    function running(fun2::Function, data1::V, data2::V, windowspan::Int, weighting::F, first::A) where
                     {A, T, V<:AbstractVector{$T1}, N<:Number, F<:Vector{N}}

        ndata   = min(length(data1), length(data2))
        nvals   = nrolled(ndata, windowspan)
        ntapers = ndata - nvals

        result = zeros($T2, ndata)

        result[1:ntapers] = tapers2(fun2, data1[1:ntapers], data2[1:ntapers], weighting[end-(ntapers-1):end])
        ntapers += 1
        result[ntapers:ndata] = rolling(fun2, data1, data2, windowspan, weighting)

        result[1] = T(first)

        return result
    end

    running(fun2::Function, data1::V, data2::V, windowspan::Int, weighting::W) where
                    {T, V<:AbstractVector{$T1}, N<:Number, W<:AbstractWeights} =
        running(fun2, data1, data2, windowspan, weighting.values)

    running(fun2::Function, data1::V, data2::V, windowspan::Int, weighting::W, first::A) where
                    {T, V<:AbstractVector{$T1}, A, N<:Number, W<:AbstractWeights} =
        running(fun2, data1, data2, windowspan, weighting.values, first)

  end
end
