function outputMessage(element, text)
	assert(isElement(element), "outputMessage @ Bad argument: expected element at argument 1, got "..type(element).." "..tostring(element))
	triggerClientEvent("onChatIncome", element, tostring(text))
end

function sendMessageToClient(message,messagetype)
	if not wasEventCancelled() then
		if messagetype == 0 or messagetype == 2 then
			triggerClientEvent("onChatIncome", source, message, messagetype)
		end
	end
end
addEventHandler("onPlayerChat",getRootElement(),sendMessageToClient)