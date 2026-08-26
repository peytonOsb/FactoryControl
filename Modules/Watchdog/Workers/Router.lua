local router = {}
router.__index = router

function router.new(watchdog)
    local self = setmetatable({}, router)
    
    self.message = watchdog:claimRoutingJob()
    self.validator_id = math.random(100000000)

    self.claimRoutingJob = function()
        return watchdog:claimRoutingJob() 
    end

    return self
end

