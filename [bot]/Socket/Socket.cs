using System.Net;
using System.Net.Sockets;
using System.Text;
using Newtonsoft.Json;

namespace DiscordBot.SocketManager;

public class SocketServer
{
    private static Socket _serverSocket = null!;
    private static int _port = 32800;
    public static List<Socket> _authenticatedSockets = new();

    public static async Task Start()
    {
        _serverSocket = new Socket(AddressFamily.InterNetwork, SocketType.Stream, ProtocolType.Tcp);

        _serverSocket.Bind(new IPEndPoint(IPAddress.Any, _port));
        _serverSocket.Listen(10);

        Log($"Socket server started on port {_port}. Waiting for a connection...");

        while (true)
        {
            Socket clientSocket = _serverSocket.Accept();
            await HandleClient(clientSocket);
        }
    }

    private static async Task HandleMessage(Socket clientSocket, string data)
    {
        data = data[1..^1];

        var message = JsonConvert.DeserializeObject<SocketMessageTypeReader>(data);
        if (message == null)
        {
            Log("Invalid message received.");
            return;
        }

        if (message.type != "auth" && !_authenticatedSockets.Contains(clientSocket))
        {
            Log("Client is not authenticated.");
            return;
        }

        switch (message.type)
        {
            case "auth":
                await new AuthMessageHandler().HandleMessageAsync(clientSocket, data);
                break;
            case "createPayment":
                await new CreatePaymentMessageHandler().HandleMessageAsync(clientSocket, data);
                break;
            default:
                Log("Unknown message type.");
                break;
        }
    }

    public static async Task SendMessage(Socket clientSocket, string type, dynamic message)
    {
        var messageObject = new SocketMessage<dynamic>
        {
            type = type,
            message = message
        };

        string json = JsonConvert.SerializeObject(messageObject);
        byte[] buffer = Encoding.ASCII.GetBytes(json);

        await clientSocket.SendAsync(buffer, SocketFlags.None);
    }

    public static async Task BroadcastMessage(string type, dynamic message)
    {
        foreach (var client in _authenticatedSockets)
        {
            await SendMessage(client, type, message);
        }
    }

    private static async Task HandleClient(Socket clientSocket)
    {
        byte[] buffer = new byte[4096];

        try
        {
            while (true)
            {
                int received = clientSocket.Receive(buffer);
                if (received == 0)
                    break;

                string data = Encoding.ASCII.GetString(buffer, 0, received);
                await HandleMessage(clientSocket, data);
            }
        }
        catch (SocketException ex)
        {
            Log("SocketException: " + ex.Message);
        }
        finally
        {
            _authenticatedSockets.Remove(clientSocket);
            clientSocket.Shutdown(SocketShutdown.Both);
            clientSocket.Close();
            Log("Client disconnected");
        }
    }

    public static void Stop()
    {
        if (_serverSocket != null)
        {
            _serverSocket.Close();
            Log("Socket server stopped");
        }
    }

    public static void Log(string message)
    {
        Console.WriteLine($"[Socket server] {DateTime.Now:HH:mm:ss} {message}");
    }
}
