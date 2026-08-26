local workload_SCHEMA = {
            mode = {required = true, type = "string"},
            current_task_id = {required = false, one_of_types = {"string", "nil"}},
            task_phase = {required = false, one_of_types = {"string", "nil"}},
            queue_depth = {required = true, type = "string"},
            estimated_completion_time = {required = false, one_of_types = {"number", "nil"}},
            task_started_at = {required = false, one_of_types = {"number", "nil"}},
            last_progress_at = {required = false, one_of_types = {"number", "nil"}}
        }
        
return workload_SCHEMA