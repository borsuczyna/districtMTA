namespace DiscordBot.Tools;

public class Moment
{
    public static string TimeInfo(int time)
    {
        List<string> parts = new();
        var AddTime = (string name, int divideBy) =>
        {
            var value = time / divideBy;
            if (value > 0)
            {
                parts.Add($"{value} {name}");
                time %= divideBy;
            }
        };

        AddTime("tygodni", 604800);
        AddTime("dni", 86400);
        AddTime("godzin", 3600);
        AddTime("minut", 60);
        AddTime("sekund", 1);

        return string.Join(", ", parts);
    }

    public static string GetTimeDifference(DateTime date)
    {
        var time = DateTime.Now - date;
        bool inThePast = time.TotalSeconds > 0;

        time = time.Duration();

        List<string> parts = new();
        var AddTime = (string name, int divideBy) =>
        {
            var value = (int)(time.TotalSeconds / divideBy);
            if (value > 0)
            {
                parts.Add($"{value} {name}");
                time = TimeSpan.FromSeconds(time.TotalSeconds % divideBy);
            }
        };

        AddTime("tygodni", 604800);
        AddTime("dni", 86400);
        AddTime("godzin", 3600);
        AddTime("minut", 60);
        AddTime("sekund", 1);

        return (inThePast ? "" : "za ") + string.Join(", ", parts) + (inThePast ? " temu" : "");
    }

    public static long GetUnixTimestamp(DateTime date)
    {
        return (long)date.ToUniversalTime().Subtract(new DateTime(1970, 1, 1)).TotalSeconds;
    }
}