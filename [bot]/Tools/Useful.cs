using System.Globalization;

namespace DiscordBot.Tools;

public static class Useful
{
    public static string GetRandomString(int length)
    {
        const string chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
        var random = new Random();
        return new string(Enumerable.Repeat(chars, length)
            .Select(s => s[random.Next(s.Length)]).ToArray());
    }

    public static string FormatNumberWithDecimal(int number)
    {
        // Dzieli liczbę przez 100 i zaokrągla do dwóch miejsc po przecinku
        decimal formattedNumber = Math.Round((decimal)number / 100, 2);

        // Formatuje liczbę, dodając przecinki co 3 cyfry
        return string.Format("{0:N2}", formattedNumber);
    }

    public static string FormatNumber(int number)
    {
        return number.ToString("N0", new CultureInfo("en-US"));
    }
}
