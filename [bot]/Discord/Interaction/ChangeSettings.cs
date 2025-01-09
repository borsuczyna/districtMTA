using Discord;
using Discord.WebSocket;
using DiscordBot.MTA;

namespace DiscordBot.Client;

public class ChangeSettings : ComponentHandlerBase
{
    public ChangeSettings()
    {
        Name = new("settings_change");
    }    

    public override async Task ExecuteAsync(SocketMessageComponent component)
    {
        var menuBuilder = new SelectMenuBuilder()
            .WithCustomId("settings_change_menu")
            .WithPlaceholder("Wybierz ustawienie");

        foreach (var setting in AccountSettingsManager.possibleSettings)
        {
            menuBuilder.AddOption(setting.description, setting.name);
        }

        var builder = new ComponentBuilder()
            .WithSelectMenu(menuBuilder);

        await component.RespondAsync(
            embed: DefaultEmbedBuilder.GetDefaultEmbedBuilder()
                .WithTitle("Zmiana ustawień")
                .WithDescription("Wybierz ustawienie, które chcesz zmienić")
                .Build(),
            ephemeral: true,
            components: builder.Build());
    }
}

public class ChangeSettingsOption : ComponentHandlerBase
{
    public ChangeSettingsOption()
    {
        Name = new("settings_change_menu");
    }

    public override async Task ExecuteAsync(SocketMessageComponent component)
    {
        var settingName = component.Data.Values.FirstOrDefault();
        if (settingName == null)
        {
            await component.RespondAsync("Wystąpił błąd podczas zmiany ustawień", ephemeral: true);
            return;
        }

        var setting = AccountSettingsManager.possibleSettings.FirstOrDefault(x => x.name == settingName);
        if (setting == null)
        {
            await component.RespondAsync("Wystąpił błąd podczas zmiany ustawień", ephemeral: true);
            return;
        }

        var account = await AccountManager.GetUserAccount(component.User.Id);
        if (account == null)
        {
            await component.RespondAsync("Nie posiadasz połączonego konta z serwerem", ephemeral: true);
            return;
        }

        var settings = await account.GetAccountSettings();
        var currentValue = settings.GetSetting(setting.name, setting.possibleValues[0]);

        var menuBuilder = new SelectMenuBuilder()
            .WithCustomId("settings_change_menu_update_" + setting.name)
            .WithPlaceholder("Wybierz wartość");

        foreach (var value in setting.possibleValues)
        {
            menuBuilder.AddOption(value, value, isDefault: value == currentValue);
        }

        var builder = new ComponentBuilder()
            .WithSelectMenu(menuBuilder);

        await component.RespondAsync(
            embed: DefaultEmbedBuilder.GetDefaultEmbedBuilder()
                .WithTitle("Zmiana ustawień")
                .WithDescription($"Wybierz nową wartość dla ustawienia **{setting.description}**")
                .Build(),
            ephemeral: true,
            components: builder.Build());
    }
}

public class ChangeSettingsOptionUpdate : ComponentHandlerBase
{
    public ChangeSettingsOptionUpdate()
    {
        Name = new("settings_change_menu_update_(.*)");
    }

    public override async Task ExecuteAsync(SocketMessageComponent component)
    {
        var embed = DefaultEmbedBuilder.GetDefaultEmbedBuilder()
            .WithTitle("Zmiana ustawień");
            
        var setting = Name.Match(component.Data.CustomId).Groups[1].Value;
        var value = component.Data.Values.FirstOrDefault();

        if (setting == null || value == null)
        {
            embed.WithDescription("Wystąpił błąd podczas zmiany ustawień");
            await component.RespondAsync(embed: embed.Build(), ephemeral: true);
            return;
        }

        var account = await AccountManager.GetUserAccount(component.User.Id);
        if (account == null)
        {
            embed.WithDescription("Nie posiadasz połączonego konta z serwerem");
            await component.RespondAsync(embed: embed.Build(), ephemeral: true);
            return;
        }

        var settings = await account.GetAccountSettings();
        bool success = await settings.SetSetting(setting, value);

        if (!success)
        {
            embed.WithDescription("Wystąpił błąd podczas zmiany ustawień");
            await component.RespondAsync(embed: embed.Build(), ephemeral: true);
            return;
        }

        var settingName = AccountSettingsManager.possibleSettings.FirstOrDefault(x => x.name == setting)?.description;
        embed.WithDescription($"Pomyślnie zmieniono ustawienie **{settingName}** na **{value}**");
        await component.RespondAsync(embed: embed.Build(), ephemeral: true);
    }
}