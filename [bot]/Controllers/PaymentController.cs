using Microsoft.AspNetCore.Mvc;
using Stripe;
using Stripe.Checkout;

[Route("api/payment")]
[ApiController]
public class PaymentController : ControllerBase
{
    [HttpPost("send")]
    public async Task<IActionResult> Index()
    {
        var json = await new StreamReader(HttpContext.Request.Body).ReadToEndAsync();

        try
        {
            var stripeEvent = EventUtility.ParseEvent(json);

            if (stripeEvent.Type == Events.CheckoutSessionCompleted)
            {
                var session = stripeEvent.Data.Object as Session;
                if (session == null)
                    return BadRequest();

                await PaymentManager.ProcessPayment(session);
                return Ok();
            }
            else
            {
                Console.WriteLine("Payment failed!");
            }
        }
        catch (StripeException e)
        {
            Console.WriteLine("Payment failed!");
            Console.WriteLine(e.Message);
            Console.WriteLine(e.StripeError.Code);
            return BadRequest();
        }

        return Ok();
    }
}