using Discord;
using Discord.WebSocket;
using DiscordBot.MTA;
using DiscordBot.SocketManager;

namespace DiscordBot.Client;

public class Connect : SlashCommandBase
{
    public Connect()
    {
        Name = "polacz";
        Description = "Połącz swoje konto z serwerem MTA";
        
        AddArgument("kod", ApplicationCommandOptionType.String, "Kod do połączenia konta widoczny w panelu gracza", true);
    }

    public override async Task ExecuteAsync(SocketSlashCommand command)
    {
        var embed = DefaultEmbedBuilder.GetDefaultEmbedBuilder();
        embed.WithTitle("Łączenie konta");

        var account = await AccountManager.GetUserAccount(command.User.Id);
        if (account != null)
        {            
            embed.WithDescription($"Już posiadasz połączone konto z serwerem: `({account.uid}) {account.username}`");
            await command.RespondAsync(embed: embed.Build(), ephemeral: true);
            return;
        }

        var code = command.Data.Options.First().Value.ToString()?.Trim();
        if (string.IsNullOrEmpty(code))
        {
            embed.WithDescription("Nie podano kodu");
            await command.RespondAsync(embed: embed.Build(), ephemeral: true);
            return;
        }

        account = await AccountManager.FindAccountByDiscordCode(code);
        if (account == null)
        {
            embed.WithDescription("Podany kod jest nieprawidłowy");
            await command.RespondAsync(embed: embed.Build(), ephemeral: true);
            return;
        }

        if (account.discordAccount != null)
        {
            embed.WithDescription("Konto jest już połączone z innym użytkownikiem");
            await command.RespondAsync(embed: embed.Build(), ephemeral: true);
            return;
        }

        var result = await account.ConnectAccount(command.User.Id);
        if (!result)
        {
            embed.WithDescription("Wystąpił błąd podczas łączenia konta");
            await command.RespondAsync(embed: embed.Build(), ephemeral: true);
            return;
        }

        embed.WithDescription($"Pomyślnie połączono konto z kontem `({account.uid}) {account.username}`");
        await command.RespondAsync(embed: embed.Build(), ephemeral: true);

        string currentAvatarUrl = command.User.GetAvatarUrl();
        await AccountManager.UpdateUserAvatar(command.User.Id, account.uid, currentAvatarUrl);
        
        await SocketServer.BroadcastMessage("connectAccount", new {
            discordId = command.User.Id.ToString(),
            accountUid = account.uid
        });
    }
}