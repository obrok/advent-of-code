function chunk_on(iterable, value)
    result = []
    chunk = []

    for item in iterable
        if item == value
            push!(result, chunk)
            chunk = []
        else
            push!(chunk, item)
        end
    end

    if chunk != []
        push!(result, chunk)
    end

    result
end
