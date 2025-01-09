using System.Net.Sockets;

namespace DiscordBot.SocketManager;

public class CreatePaymentMessage
{
    public ulong uid { get; set; }
    public string item { get; set; } = string.Empty;
    public string itemId { get; set; } = string.Empty;
}

public class CreatePaymentMessageHandler : BaseSocketMessageHandler<CreatePaymentMessage>
{
    protected override async Task HandleMessage(Socket client, CreatePaymentMessage message)
    {
        var url = PaymentManager.CreatePayment(message.uid, message.item, message.itemId);
        await SocketServer.SendMessage(client, "paymentCreated", new { message.uid, message.itemId, message.item, url });
    }
}