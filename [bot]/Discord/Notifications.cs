using DiscordBot.Database;

namespace DiscordBot.Client;

public class Notifications
{
    public static async Task<List<string>> GetUsersWhoReceivedNotification(string type, int interval = 1)
    {
        var data = await DatabaseManager.QueryAsync("SELECT * FROM `m-discord-notifications` WHERE `type` = ? AND `date` >= NOW() - INTERVAL ? DAY", type, interval);
        return data.Select(x => (string)x.user).ToList();
    }

    public static async Task<bool> AddNotification(string user, string type)
    {
        var result = await DatabaseManager.ExecuteAsync("INSERT INTO `m-discord-notifications` (`user`, `type`, `date`) VALUES (?, ?, NOW())", user, type);
        return result;
    }

    public static async Task<bool> SendNotification(string user, string type, string message)
    {
        var channel = DiscordClient.GetChannel(Defines.NotificationsChannelId);
        if (channel == null) return false;

        var notification = $"<@{user}> {message}";
        await channel.SendMessageAsync(notification);

        return await AddNotification(user, type);
    }
}