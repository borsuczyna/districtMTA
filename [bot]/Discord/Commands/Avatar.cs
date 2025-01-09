using System.Diagnostics;
using Discord.WebSocket;
using DiscordBot.MTA;
using DiscordBot.SocketManager;

namespace DiscordBot.Client;

public class Avatar : SlashCommandBase
{
    public Avatar()
    {
        Name = "avatar";
        Description = "Odśwież swój avatar";
    }

    public override async Task ExecuteAsync(SocketSlashCommand command)
    {
        var embed = DefaultEmbedBuilder.GetDefaultEmbedBuilder();
        embed.WithTitle("Avatar");

        var account = await AccountManager.GetUserAccount(command.User.Id);
        if (account == null)
        {
            embed.WithDescription("Nie posiadasz połączonego konta z serwerem");

            await command.FollowupAsync(embed: embed.Build(), ephemeral: true);
            return;
        }

        string currentAvatarUrl = command.User.GetAvatarUrl();
        if (account.avatar == currentAvatarUrl)
        {
            embed.WithDescription("Twój avatar jest już aktualny");

            await command.RespondAsync(embed: embed.Build(), ephemeral: true);
            return;
        }

        await AccountManager.UpdateUserAvatar(command.User.Id, account.uid, currentAvatarUrl);

        embed.WithDescription("Twój avatar został odświeżony");
        await command.RespondAsync(embed: embed.Build(), ephemeral: true);
    }
}