using Discord;
using Discord.WebSocket;
using DiscordBot.MTA;
using DiscordBot.Tools;

namespace DiscordBot.Client;

public class Account : SlashCommandBase
{
    public Account()
    {
        Name = "konto";
        Description = "Wyświetla informacje o koncie";

        AddArgument("użytkownik", ApplicationCommandOptionType.User, "Użytkownik, którego konto chcesz sprawdzić", false);
    }

    public override async Task ExecuteAsync(SocketSlashCommand command)
    {
        var embed = DefaultEmbedBuilder.GetDefaultEmbedBuilder();
        embed.WithTitle("Konto");

        await command.DeferAsync();

        var thisUser = command.User;
        var selectedUser = command.Data.Options.FirstOrDefault()?.Value as SocketUser;
        if (selectedUser != null && !DiscordClient.DoesUserHavePermission(thisUser, GuildPermission.Administrator))
        {
            embed.WithDescription("Nie posiadasz uprawnień do sprawdzania kont innych użytkowników");
            await command.FollowupAsync(embed: embed.Build(), ephemeral: true);
            return;
        }

        if (selectedUser == null)
            selectedUser = thisUser;

        var account = await AccountManager.GetUserAccount(selectedUser.Id);
        if (account == null)
        {
            embed.WithDescription(selectedUser.Id == thisUser.Id
                ? "Nie posiadasz połączonego konta z serwerem"
                : "Użytkownik nie posiada połączonego konta z serwerem");

            await command.FollowupAsync(embed: embed.Build(), ephemeral: true);
            return;
        }

        embed.WithThumbnailUrl(selectedUser.GetAvatarUrl() ?? selectedUser.GetDefaultAvatarUrl());

        embed.AddField("Konto", AccountTable(account), inline: false)
             .AddField("Statystyki", StatsTable(account), inline: false)
             .AddField("Premium", PremiumTable(account), inline: false)
             .AddField("Nagroda dzienna", DailyRewardTable(account), inline: false);

        await command.FollowupAsync(embed: embed.Build());
    }

    private string AccountTable(DiscordBot.MTA.Account account)
    {
        return @$"
        » UID: {account.uid}
        » Nazwa: {account.username}
        » Discord: <@{account.discordAccount}>
        » Gotówka: ${Useful.FormatNumberWithDecimal(account.money)}
        » Gotówka banku: ${Useful.FormatNumberWithDecimal(account.bankMoney)}";
    }

    private string StatsTable(DiscordBot.MTA.Account account)
    {
        return @$"
        » Poziom: {account.level}
        » Doświadczenie: {account.exp}/{account.GetNextLevelExp()}
        » Czas gry: {Moment.TimeInfo(account.time * 60)}
        » Czas AFK: {Moment.TimeInfo(account.afkTime * 60)}
        » Ostatnio aktywny: <t:{Moment.GetUnixTimestamp(account.lastActive)}:R>
        » Data rejestracji: <t:{Moment.GetUnixTimestamp(account.registerDate)}:D>";
    }

    private string PremiumTable(DiscordBot.MTA.Account account)
    {
        bool isPremium = account.IsPremiumAccount();
        string premiumDateString = isPremium ? $"<t:{Moment.GetUnixTimestamp(account.premiumDate)}:D>" : "N/A";

        return @$"
        » Premium: {(isPremium ? "Tak" : "Nie")}
        » Aktywne do: {premiumDateString}";
    }

    private string DailyRewardTable(DiscordBot.MTA.Account account)
    {
        var dailyRewardRedeemTime = account.CanRedeemDailyReward() ?
            "Teraz" :
            $"<t:{Moment.GetUnixTimestamp(account.dailyRewardRedeem)}:R>";

        return @$"
        » Dzień: {account.GetDailyRewardDay()}
        » Dostępna do odebrania: {dailyRewardRedeemTime}";
    }
}
