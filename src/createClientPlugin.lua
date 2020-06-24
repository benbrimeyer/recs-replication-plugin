local ActionType = require(script.Parent.ActionType)

return function(remoteEvent)
	return function()
		local recsPlugin = {}

		function recsPlugin:beforeSystemStart(core)
			local function handleCoreAction(action)
				local payload = action.payload

				if action.type == ActionType.AddComponent then
					core:addComponent(payload.entity, payload.componentIdentifier, payload.props)
				elseif action.type == ActionType.SetStateComponent then
					core:setStateComponent(payload.entity, payload.componentIdentifier, payload.newState)
				elseif action.type == ActionType.RemoveComponent then
					core:removeComponent(payload.entity, payload.componentIdentifier)
				elseif action.type == ActionType.AddSingleton then
					core:addSingleton(payload.componentIdentifier)
				end
			end

			remoteEvent.OnClientEvent:Connect(function(actions)
				for _, action in pairs(actions) do
					if action.type == ActionType.Setup then
						for _, childAction in ipairs(action.payload.history) do
							handleCoreAction(childAction)
						end
					else
						handleCoreAction(action)
					end
				end
			end)
		end

		return recsPlugin
	end
end
