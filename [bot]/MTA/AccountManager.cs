using DiscordBot.Database;
using DiscordBot.SocketManager;

namespace DiscordBot.MTA;

public class AccountManager
{
    public static async Task<Account?> FindAccountByDiscordCode(string code)
    {
        var results = await DatabaseManager.QueryAsync("SELECT * FROM `m-users` WHERE `discordCode` = ? AND `discordAccount` IS NULL", code);
        if (results.Count == 0) return null;

        return new Account(results[0]);
    }

    public static async Task<Account?> FindAccountByDiscordId(ulong discordId)
    {
        var results = await DatabaseManager.QueryAsync("SELECT * FROM `m-users` WHERE `discordAccount` = ?", discordId);
        if (results.Count == 0) return null;

        return new Account(results[0]);
    }

    public static async Task<Account?> GetUserAccount(ulong discordId)
    {
        var results = await DatabaseManager.QueryAsync("SELECT * FROM `m-users` WHERE `discordAccount` = ?", discordId);
        if (results.Count == 0) return null;

        return new Account(results[0]);
    }

    public static async Task<bool> UpdateUserAvatar(ulong discordId, ulong uid, string avatar)
    {                
        await DatabaseManager.ExecuteAsync("UPDATE `m-users` SET `avatar` = ? WHERE `discordAccount` = ?", avatar, discordId);
        await SocketServer.BroadcastMessage("clearAvatar", new {
            uid = uid,
            avatar = avatar
        });

        return true;
    }
}