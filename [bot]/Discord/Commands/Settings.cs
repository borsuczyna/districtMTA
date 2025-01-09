using System.Text;
using Discord;
using Discord.WebSocket;
using DiscordBot.MTA;

namespace DiscordBot.Client;

public class Settings : SlashCommandBase
{
    public Settings()
    {
        Name = "ustawienia";
        Description = "Wyświetla aktualne ustawienia konta";

        AddArgument("użytkownik", ApplicationCommandOptionType.User, "Użytkownik, którego konto chcesz sprawdzić", false);
    }

    public override async Task ExecuteAsync(SocketSlashCommand command)
    {
        var embed = DefaultEmbedBuilder.GetDefaultEmbedBuilder();
        embed.WithTitle("Ustawienia");

        await command.DeferAsync(ephemeral: true);

        var thisUser = command.User;
        var selectedUser = command.Data.Options.FirstOrDefault()?.Value as SocketUser;
        if (selectedUser != null && !DiscordClient.DoesUserHavePermission(thisUser, GuildPermission.Administrator))
        {
            embed.WithDescription("Nie posiadasz uprawnień do sprawdzania ustawień innych użytkowników");
            await command.FollowupAsync(embed: embed.Build());
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

        var settings = await account.GetAccountSettings();

        StringBuilder settingsStrBuilder = new StringBuilder();
        foreach (var setting in AccountSettingsManager.possibleSettings)
        {
            var value = settings.GetSetting(setting.name, setting.possibleValues[0]);
            settingsStrBuilder.AppendLine($"**{setting.description}**: {value}");
        }

        embed.WithDescription(settingsStrBuilder.ToString());

        await command.FollowupAsync(
            embed: embed.Build(),
            ephemeral: true,
            components: new ComponentBuilder()
                .WithButton("Zmień ustawienia", "settings_change")
                .Build()
        );
    }
}