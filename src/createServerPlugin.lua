local ActionType = require(script.Parent.ActionType)
local replicate = require(script.Parent.replicate)
local createAction = require(script.Parent.createAction)

return function(remoteEvent, history)
	history = history or {}

	return function(config)
		config = config or {
			batchActions = false,
		}

		local recsPlugin = {}
		local batch = {}

		local function performFlush()
			remoteEvent:FireAllClients(batch)
			batch = {}
		end

		local function addAction(action)
			table.insert(history, action)
			table.insert(batch, action)

			if config.batchActions == false then
				-- automatically flush if this config is OFF
				performFlush()
			end
		end

		function recsPlugin:componentAdded(core, entity, component, props)
			if replicate.shouldReplicate then
				local action = createAction(ActionType.AddComponent, {
					entity = entity,
					componentIdentifier = component.className,
					props = props
				})

				addAction(action)
			end
		end

		function recsPlugin:componentStateSet(core, entity, componentIdentifier, newState)
			if replicate.shouldReplicate then
				local action = createAction(ActionType.SetStateComponent, {
					entity = entity,
					componentIdentifier = componentIdentifier,
					newState = newState,
				})

				addAction(action)
			end
		end

		function recsPlugin:componentRemoving(core, entity, component)
			if replicate.shouldReplicate then
				local action = createAction(ActionType.RemoveComponent, {
					entity = entity,
					componentIdentifier = component.className
				})

				addAction(action)
			end
		end

		function recsPlugin:singletonAdded(core, component)
			if replicate.shouldReplicate then
				local action = createAction(ActionType.AddSingleton, {
					componentIdentifier = component.className
				})

				addAction(action)
			end
		end

		function recsPlugin:beforeSystemStart(core)
			core.flush = performFlush
		end

		return recsPlugin
	end
end
