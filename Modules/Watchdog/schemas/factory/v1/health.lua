local health_SCHEMA = {
            last_err = {required = true, one_of_types = {"string", "nil"}},
            error_count_win = {required = true, type = "number"},
            faulted = {required = true, type = "boolean"},
            fault_code = {required = false, one_of_types = {"string", "nil"}}
        } 

return health_SCHEMA