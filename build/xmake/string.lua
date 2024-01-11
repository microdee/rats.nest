------ commonly used extensions for string

function string.join(t, separator)
    result = t[1]
    for i = 2, #t, 1 do
        result = result .. separator .. t[i]
    end
    return result
end