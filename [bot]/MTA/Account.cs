using DiscordBot.Database;

namespace DiscordBot.MTA;

public class Account
{
    public ulong uid { get; set; } = 0;
    public string username { get; set; } = string.Empty;
    public string? avatar { get; set; } = string.Empty;
    public ulong? discordAccount { get; set; } = null;
    public string discordCode { get; set; } = string.Empty;
    public int money { get; set; } = 0;
    public int bankMoney { get; set; } = 0;
    public int level { get; set; } = 0;
    public int exp { get; set; } = 0;
    public int time { get; set; } = 0;
    public int afkTime { get; set; } = 0;
    public int dailyRewardDay { get; set; } = 0;
    public DateTime dailyRewardRedeem { get; set; } = DateTime.MinValue;
    public DateTime lastActive { get; set; } = DateTime.MinValue;
    public DateTime registerDate { get; set; } = DateTime.MinValue;
    public DateTime premiumDate { get; set; } = DateTime.MinValue;

    public Account(dynamic accountData)
    {
        username = accountData.username;
        uid = (ulong)accountData.uid;
        discordCode = accountData.discordCode;
        money = accountData.money;
        bankMoney = accountData.bankMoney;
        level = accountData.level;
        exp = accountData.exp;
        time = accountData.time;
        afkTime = accountData.afkTime;
        dailyRewardDay = accountData.dailyRewardDay;
        dailyRewardRedeem = accountData.dailyRewardRedeem;
        lastActive = accountData.lastActive;
        registerDate = accountData.registerDate;
        premiumDate = accountData.premiumDate;
  
        if (!string.IsNullOrEmpty(accountData.avatar.ToString()))
        {
            avatar = accountData.avatar;
        }

        if (!string.IsNullOrEmpty(accountData.discordAccount.ToString()))
        {
            ulong.TryParse(accountData.discordAccount.ToString(), out ulong discordId);
            discordAccount = discordId;
        }
    }

    public async Task<bool> ConnectAccount(ulong discordId)
    {
        var result = await DatabaseManager.ExecuteAsync("UPDATE `m-users` SET `discordAccount` = ? WHERE `uid` = ?", discordId, uid);
        return result;
    }

    public int GetNextLevelExp()
    {
        return (int)Math.Floor(100 * (double)level * Math.Max(Math.Floor((double)level / 40), 0.5));
    }

    public bool IsPremiumAccount()
    {
        return premiumDate > DateTime.Now;
    }

    public int GetDailyRewardDay()
    {
        var diff = (DateTime.Now - dailyRewardRedeem).TotalSeconds;
        if (diff > 86400)
        {
            dailyRewardDay = 1;
            dailyRewardRedeem = DateTime.Now;
        }

        return dailyRewardDay;
    }

    public bool CanRedeemDailyReward()
    {
        GetDailyRewardDay();
        return dailyRewardRedeem < DateTime.Now;
    }

    public async Task<string> GetAccountSetting(string key)
    {
        if (discordAccount == null)
            return string.Empty;
        
        var result = await DatabaseManager.QueryAsync("SELECT `value` FROM `m-discord-settings` WHERE `user` = ? AND `key` = ?", discordAccount, key);
        if (result.Count == 0)
            return string.Empty;

        return result[0].value;
    }

    public async Task<bool> SetAccountSetting(string key, string value)
    {
        if (discordAccount == null)
            return false;

        var result = await DatabaseManager.ExecuteAsync("INSERT INTO `m-discord-settings` (`user`, `key`, `value`) VALUES (?, ?, ?) ON DUPLICATE KEY UPDATE `value` = ?", discordAccount, key, value, value);
        return result;
    }

    public async Task<AccountSettingsManager> GetAccountSettings()
    {
        if (discordAccount == null)
            return new AccountSettingsManager(0, new Dictionary<string, string>());

        var result = await DatabaseManager.QueryAsync("SELECT `setting`, `value` FROM `m-discord-settings` WHERE `user` = ?", discordAccount);
        return new AccountSettingsManager(discordAccount.Value, result.ToDictionary(x => (string)x.setting, x => (string)x.value));
    }
}