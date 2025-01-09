using System.Net.Sockets;

namespace DiscordBot.SocketManager;

public class AuthMessage
{
    public string apiKey { get; set; } = string.Empty;
}

public class AuthMessageHandler : BaseSocketMessageHandler<AuthMessage>
{
    protected override async Task HandleMessage(Socket client, AuthMessage message)
    {
        if (message.apiKey != Defines.MTAToken)
        {
            await SocketServer.SendMessage(client, "auth", new { success = false });
            SocketServer.Log($"Client passed invalid API key ({message.apiKey}).");
            client.Disconnect(false);
            return;
        }

        SocketServer._authenticatedSockets.Add(client);
        SocketServer.Log("Client authenticated.");
        await SocketServer.SendMessage(client, "auth", new { success = true });
    }
}