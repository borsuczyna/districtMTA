using Stripe.Checkout;
using Newtonsoft.Json;
using Stripe;
using DiscordBot.SocketManager;

public class PaymentManager
{
    public static void Init()
    {
        StripeConfiguration.ApiKey = Defines.StripeApiKey;
    }

    public static async Task ProcessPayment(Session session)
    {
        try
        {
            var uid = ulong.Parse(session.Metadata["uid"]);
            var itemId = session.Metadata["item_id"];
            
            await SocketServer.BroadcastMessage("paymentFinished", new { uid, itemId });
        }
        catch (Exception ex)
        {
            Console.WriteLine(ex.Message);
        }
    }

    public static string CreatePayment(ulong uid, string itemId, string priceId = "price_change_me")
    {
        try
        {
            var options = new PaymentLinkCreateOptions
            {
                LineItems = new()
                {
                    new()
                    {
                        Price = priceId,
                        Quantity = 1,
                    },
                },
                Metadata = new()
                {
                    { "uid", uid.ToString() },
                    { "item_id", itemId },
                },
            };
            var service = new PaymentLinkService();
            var result = service.Create(options);

            return result.Url;
        }
        catch (Exception ex)
        {
            Console.WriteLine(ex.Message);
            return string.Empty;
        }
    }
}