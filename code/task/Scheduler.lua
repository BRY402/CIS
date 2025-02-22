local format = string.format
local type = type
local error = error
local ipairs = ipairs
local tonumber = tonumber
local coroutine_resume = coroutine.resume
local coroutine_status = coroutine.status
local table_remove = table.remove
local table_unpack = table.unpack or unpack
local os_clock = os.clock

type Floor = {n: number, [number]: any}
type Task = {any}

local scheduler = {tasks = {n = 0}}

local function isInt(number: number): boolean
    return not not (tonumber(number) and number % 1 == 0)
end

local function resume(thread: thread, ...: any?): thread
    local success, errormsg = coroutine_resume(thread, ...)

    if not success then
        error(errormsg, 2)
    end

    return thread
end

function scheduler.addFloor(level: number): Floor
    if not isInt(level) then
        error('Level is expexted to be an integer', 2)
    end

    if not scheduler.tasks[level] then
        scheduler.tasks[level] = {n = 0}
        scheduler.tasks.n = scheduler.tasks.n + 1
    end

    return scheduler.tasks[level]
end

function scheduler.scheduleTask(thread: thread, level: number, waitTime: number?, ...: any?): Task
    if not isInt(level) then
        error('Level is expexted to be an integer', 2)
    end

    local tasks = scheduler.tasks
    local floor = tasks[level] or scheduler.addFloor(level)

    if type(thread) ~= 'thread' then
        error(format('Expected thread, got %s', type(thread)), 2)
    end

    floor[floor.n + 1] = {thread, os_clock(), tonumber(waitTime) or 0, {...}}
    floor.n = floor.n + 1

    return floor[floor.n]
end

local function execTask(scheduledTask: Task, id: number, floor: Floor): nil
    local delta = os_clock() - scheduledTask[2]
    if delta >= scheduledTask[3] then
        local thread = scheduledTask[1]
        table_remove(floor, id)
        floor.n = floor.n - 1
        if coroutine_status(thread) ~= 'dead' then
            resume(scheduledTask[1], table_unpack(scheduledTask[4]))
        end
    end
    return
end

function scheduler.run(level: number, id: number?): boolean
    if not isInt(level) then
        error('Level is expexted to be an integer', 2)
    end

    local tasks = scheduler.tasks
    local floor = tasks[level]

    if not floor then
        return false
    end

    if id then
        if not isInt(id) then
            error('Task id is expexted to be an integer', 2)
        end

        local task = floor[id]

        execTask(task, id, floor)

        return true
    end

    for id, task in ipairs(floor) do
        if not task then
            continue
        end
        execTask(task, id, floor)
    end

    return true
end

scheduler.resume = resume

return scheduler