local ActionType = require(script.Parent.ActionType)
local replicate = require(script.Parent.replicate)
local createAction = require(script.Parent.createAction)

return function(remoteEvent, history)
	history = history or {}

	return function()
		local recsPlugin = {}

		local batch = {}

		function recsPlugin:componentAdded(core, entity, component, props)
			if replicate.shouldReplicate then
				local action = createAction(ActionType.AddComponent, {
					entity = entity,
					componentIdentifier = component.className,
					props = props
				})

				table.insert(history, action)
				table.insert(batch, action)
			end
		end

		function recsPlugin:componentStateSet(core, entity, componentIdentifier, newState)
			if replicate.shouldReplicate then
				local action = createAction(ActionType.SetStateComponent, {
					entity = entity,
					componentIdentifier = componentIdentifier,
					newState = newState,
				})

				table.insert(history, action)
				table.insert(batch, action)
			end
		end

		function recsPlugin:componentRemoving(core, entity, component)
			if replicate.shouldReplicate then
				local action = createAction(ActionType.RemoveComponent, {
					entity = entity,
					componentIdentifier = component.className
				})

				table.insert(history, action)
				table.insert(batch, action)
			end
		end

		function recsPlugin:singletonAdded(core, component)
			if replicate.shouldReplicate then
				local action = createAction(ActionType.AddSingleton, {
					componentIdentifier = component.className
				})

				table.insert(history, action)
				table.insert(batch, action)
			end
		end

		function recsPlugin:beforeSystemStart(core)
			core.flush = function()
				remoteEvent:FireAllClients(batch)
				batch = {}
			end
		end

		return recsPlugin
	end
end
