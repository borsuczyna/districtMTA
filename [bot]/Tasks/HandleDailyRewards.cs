using DiscordBot.Client;
using DiscordBot.Database;

namespace DiscordBot.Tasks;

public class HandleDailyRewards
{
    private class ReedemDailyRewardUser
    {
        public ulong uid { get; set; }
        public string discordId { get; set; } = string.Empty;
        public int dailyRewardDay { get; set; } = 0;

        public ReedemDailyRewardUser(ulong uid, string discordId, int dailyRewardDay)
        {
            this.uid = uid;
            this.discordId = discordId;
            this.dailyRewardDay = dailyRewardDay;
        }
    }

    public static void Start()
    {
        _ = new Timer(TimerElapsed, null, TimeSpan.Zero, TimeSpan.FromMinutes(5));
    }

    private static void TimerElapsed(object? state)
    {
        try
        {
            Task.Run(DoWork);
        }
        catch (Exception ex)
        {
            Console.WriteLine($"Error in HandleDailyRewards: {ex.Message}");
        }
    }

    public static async Task DoWork()
    {
        var usersWithSetting = await GetUsersWithSettingEnabled();
        var usersThatCanRedeem = await GetUsersThatCanRedeemDailyReward();
        var usersThatDidNotReceiveNotification = await Notifications.GetUsersWhoReceivedNotification("daily_reward");
        
        var usersThatCanRedeemAndHaveSettingEnabled = usersThatCanRedeem.Where(x => 
            usersWithSetting.Contains(x.discordId) &&
            !usersThatDidNotReceiveNotification.Contains(x.discordId)
        ).ToList();

        foreach (var user in usersThatCanRedeemAndHaveSettingEnabled)
        {
            await SendDailyRewardNotification(user);
        }
    }

    private static async Task SendDailyRewardNotification(ReedemDailyRewardUser user)
    {
        var message = $"twoja nagroda dzienna za dzień {user.dailyRewardDay} jest gotowa do odebrania!\n-# Aby wyłączyć tą funkcję wpisz `/ustawienia`";
        await Notifications.SendNotification(user.discordId, "daily_reward", message);
    }

    private static async Task<List<string>> GetUsersWithSettingEnabled()
    {
        var data = await DatabaseManager.QueryAsync("SELECT * FROM `m-discord-settings` WHERE `setting` = 'daily_reward' AND `value` = 'Włączone'");

        return data.Select(x => (string)x.user).ToList();
    }

    private static async Task<List<ReedemDailyRewardUser>> GetUsersThatCanRedeemDailyReward()
    {
        var data = await DatabaseManager.QueryAsync("SELECT * FROM `m-users` WHERE `dailyRewardRedeem` < NOW() AND `dailyRewardDay` != 0 AND `discordAccount` IS NOT NULL");

        return data.Select(x => new ReedemDailyRewardUser((ulong)x.uid, (string)x.discordAccount, (int)x.dailyRewardDay)).ToList();
    }
}