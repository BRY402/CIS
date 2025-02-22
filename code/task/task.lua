if task then
    return task
end

local task = {levels = {}}

local format = string.format
local type = type
local error = error
local ipairs = ipairs
local coroutine_create = coroutine.create
local coroutine_yield = coroutine.yield
local coroutine_running = coroutine.running
local coroutine_close = coroutine.close
local os_clock = os.clock

local scheduler = require('./Scheduler')

task.levels.INIT_LVL = 1
task.levels.HEARTBEAT_LVL = 2

scheduler.addFloor(task.levels.INIT_LVL) -- Start of cycle
scheduler.addFloor(task.levels.HEARTBEAT_LVL) -- Heartbeat


-- Task functions
function task.wait(duration: number): number
    scheduler.scheduleTask(coroutine_running(), task.levels.HEARTBEAT_LVL, duration)
    local start = os_clock()
    coroutine_yield()
    return os_clock() - start
end

function task.spawn(functionOrThread: (...any) -> any | thread, ...: any): thread
    local thread = type(functionOrThread) == 'function' and coroutine_create(functionOrThread) or functionOrThread

    if type(thread) ~= 'thread' then
        error(format('Expected thread, got %s', type(thread)), 2)
    end

    return scheduler.resume(thread, ...)
end

function task.defer(functionOrThread: (...any) -> ...any, ...: any)
    local thread = type(functionOrThread) == 'function' and coroutine_create(functionOrThread) or functionOrThread

    if type(thread) ~= 'thread' then
        error(format('Expected thread, got %s', type(thread)), 2)
    end

    scheduler.scheduleTask(thread, task.levels.INIT_LVL, 0, ...)

    return thread
end

function task.delay(duration: number, functionOrThread: (...any) -> ...any | thread, ...: any)
    local thread = type(functionOrThread) == 'function' and coroutine_create(functionOrThread) or functionOrThread

    if type(thread) ~= 'thread' then
        error(format('Expected thread, got %s', type(thread)), 2)
    end

    scheduler.scheduleTask(thread, task.levels.HEARTBEAT_LVL, duration, ...)

    return thread
end

function task.cancel(thread: thread): nil
    coroutine_close(thread)
    return nil
end

function task.run(functionOrThread: ((...any) -> ...any | thread)?): nil
    if functionOrThread then
        task.spawn(functionOrThread)
    end
    while true do
        local finishedfloors = 0
        for i, floor in ipairs(scheduler.tasks) do
            if floor.n <= 0 then
                finishedfloors = finishedfloors + 1
                continue
            end
            finishedfloors = finishedfloors - 1
            scheduler.run(i)
        end
        if finishedfloors >= scheduler.tasks.n then
            break
        end
    end
    return nil
end

task.scheduler = scheduler

return task