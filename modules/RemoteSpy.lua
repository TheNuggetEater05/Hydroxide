local RemoteSpy = {}
local Remote = import("objects/Remote")

local requiredMethods = {
    ["checkCaller"] = true,
    ["newCClosure"] = true,
    ["hookFunction"] = true,
    ["isReadOnly"] = true,
    ["setReadOnly"] = true,
    ["getInfo"] = true,
    ["getMetatable"] = true,
    ["setClipboard"] = true,
    ["getNamecallMethod"] = true,
    ["getCallingScript"] = true,
}

local remoteMethods = {
    FireServer = true,
    InvokeServer = true,
    Fire = true,
    Invoke = true
}

local remotesViewing = {
    RemoteEvent = true,
    RemoteFunction = false,
    BindableEvent = false,
    BindableFunction = false
}

local currentRemotes = {}

local remoteDataEvent = Instance.new("BindableEvent")
local eventSet = false

local function connectEvent(callback)
    remoteDataEvent.Event:Connect(callback)

    if not eventSet then
        eventSet = true
    end
end

for _,v in next, getgc(true) do
    if type(v) == "table" and type(rawget(v, "FireServer")) == "function" then
        oldFireServer = hookfunction(rawget(v, "FireServer"), function(self, ...)
            local instance = getupvalue(oldFireServer, 2)

            if typeof(instance) ~= "Instance" then
                return oldFireServer(self, ...)
            end

            if remotesViewing[instance.ClassName] and instance ~= remoteDataEvent and remoteMethods["FireServer"] then
                local remote = currentRemotes[instance]
                local vargs = {...}

                if not remote then
                    remote = Remote.new(instance)
                    currentRemotes[instance] = remote
                end

                local remoteIgnored = remote.Ignored
                local remoteBlocked = remote.Blocked
                local argsIgnored = remote.AreArgsIgnored(remote, vargs)
                local argsBlocked = remote.AreArgsBlocked(remote, vargs)

                if eventSet and (not remoteIgnored and not argsIgnored) then
                    local call = {
                        script = getCallingScript((PROTOSMASHER_LOADED ~= nil and 2) or nil),
                        args = vargs,
                        func = getInfo(2).func
                    }

                    remote.IncrementCalls(remote, call)
                    remoteDataEvent.Fire(remoteDataEvent, instance, call)
                end

                if remoteBlocked or argsBlocked then
                    return
                end
            end

            return oldFireServer(self, ...)
        end)
        oldInvokeServer = hookfunction(rawget(v, "InvokeServer"), function(self, ...)
            local instance = getupvalue(oldInvokeServer, 2)

            if typeof(instance) ~= "Instance" then
                return oldInvokeServer(self, ...)
            end

            if remotesViewing[instance.ClassName] and instance ~= remoteDataEvent and remoteMethods["InvokeServer"] then
                local remote = currentRemotes[instance]
                local vargs = {...}

                if not remote then
                    remote = Remote.new(instance)
                    currentRemotes[instance] = remote
                end

                local remoteIgnored = remote.Ignored
                local remoteBlocked = remote.Blocked
                local argsIgnored = remote.AreArgsIgnored(remote, vargs)
                local argsBlocked = remote.AreArgsBlocked(remote, vargs)

                if eventSet and (not remoteIgnored and not argsIgnored) then
                    local call = {
                        script = getCallingScript((PROTOSMASHER_LOADED ~= nil and 2) or nil),
                        args = vargs,
                        func = getInfo(2).func
                    }

                    remote.IncrementCalls(remote, call)
                    remoteDataEvent.Fire(remoteDataEvent, instance, call)
                end

                if remoteBlocked or argsBlocked then
                    return
                end
            end

            return oldInvokeServer(self, ...)
        end)
    end
end

RemoteSpy.RemotesViewing = remotesViewing
RemoteSpy.CurrentRemotes = currentRemotes
RemoteSpy.ConnectEvent = connectEvent
RemoteSpy.RequiredMethods = requiredMethods
return RemoteSpy
