------ commonly used extensions for tables

-- drop items until the first value is matched
function table.skip_until(t, v, offset)
    splitAt = table.find_first(t, v) + (offset or 0)
    return table.slice(t, splitAt)
end