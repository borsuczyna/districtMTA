using System.Net.Sockets;
using Newtonsoft.Json;

namespace DiscordBot.SocketManager;

public class SocketMessage<T> where T : new()
{
    public string type { get; set; } = string.Empty;
    public T message { get; set; } = new();
}

public class SocketMessageTypeReader
{
    public string type { get; set; } = string.Empty;
}

public abstract class BaseSocketMessageHandler<T> where T : new()
{
    protected abstract Task HandleMessage(Socket client, T message);
    public async Task HandleMessageAsync(Socket client, string message)
    {
        var messageObject = JsonConvert.DeserializeObject<SocketMessage<T>>(message);
        if (messageObject == null) return;

        await HandleMessage(client, messageObject.message);
    }
}