using System;
using System.Reflection;
using System.Threading.Tasks;

using Discord;
using Discord.Net;
using Discord.WebSocket;
using DiscordBot.Tasks;
using DiscordBot.MTA;
using Newtonsoft.Json;

namespace DiscordBot.Client;

public class DiscordClient
{
    private static DiscordSocketClient? client;
    private static SocketGuild? guild;
    private static List<SlashCommandBase> commands = new();
    private static List<ComponentHandlerBase> components = new();

    public static async Task InitalizeAsync()
    {
        var config = new DiscordSocketConfig
        {
            GatewayIntents = GatewayIntents.All
        };
        
        client = new DiscordSocketClient(config);

        client.Log += Log;
        client.Ready += Ready;
        client.SlashCommandExecuted += SlashCommandExecuted;
        client.ButtonExecuted += ButtonExecuted;
        client.SelectMenuExecuted += SelectMenuExecuted;
        client.UserUpdated += UserUpdated;

        await client.LoginAsync(TokenType.Bot, Defines.DiscordToken);
        await client.StartAsync();
    }

    private static async Task Ready()
    {
        GetMainGuild();
        InitSlashCommands();
        InitComponents();

        HandleDailyRewards.Start();
    }

    private static Task Log(LogMessage msg)
    {
        SendLog(msg.ToString());
        return Task.CompletedTask;
    }

    private static void SendLog(string message)
    {
        Console.WriteLine($"[Discord Bot] {message}");
    }

    private static void GetMainGuild()
    {
        if (client == null) return;

        guild = client.GetGuild(Defines.GuildId);
    }

    public static bool DoesUserHavePermission(SocketUser user, GuildPermission permission)
    {
        if (guild == null) return false;

        var guildUser = guild.GetUser(user.Id);
        if (guildUser == null) return false;

        return guildUser.GuildPermissions.Has(permission);
    }

    private static async Task InitSlashCommands()
    {
        if (client == null || guild == null) return;

        var assemblyCommands = Assembly.GetExecutingAssembly().GetTypes()
            .Where(x => x.BaseType == typeof(SlashCommandBase));

        var registeredCommands = await guild.GetApplicationCommandsAsync();

        foreach (var command in assemblyCommands)
        {
            if (command == null) continue;

            var instance = (SlashCommandBase)Activator.CreateInstance(command)!;
            commands.Add(instance);

            if (registeredCommands.Any(x => x.Name == instance.Name)) continue;

            await RegisterSlashCommand(instance);
        }
    }

    private static async Task RegisterSlashCommand(SlashCommandBase command)
    {
        if (client == null || guild == null) return;

        try
        {
            await guild.CreateApplicationCommandAsync(command.GetCommandBuilder().Build());
            SendLog($"Registered slash command: /{command.Name}");
        }
        catch(HttpException exception)
        {
            var json = JsonConvert.SerializeObject(exception.Errors, Formatting.Indented);
            Console.WriteLine(json);
        }
    }

    private static void InitComponents()
    {
        if (client == null || guild == null) return;

        var _components = Assembly.GetExecutingAssembly().GetTypes()
            .Where(x => x.BaseType == typeof(ComponentHandlerBase));

        foreach (var component in _components)
        {
            if (component == null) continue;

            components.Add((ComponentHandlerBase)Activator.CreateInstance(component)!);
        }
    }

    private static async Task SlashCommandExecuted(SocketSlashCommand command)
    {
        if (client == null || guild == null) return;

        var commandInstance = commands.FirstOrDefault(x => x.Name == command.Data.Name);
        if (commandInstance == null) return;

        await commandInstance.ExecuteAsync(command);
    }

    private static async Task ButtonExecuted(SocketMessageComponent component)
    {
        if (client == null || guild == null) return;

        var componentInstance = components.FirstOrDefault(x =>
        {
            if (x.Name.ToString().Contains("("))
            {
                return x.Name.IsMatch(component.Data.CustomId);
            }
            return x.Name.ToString() == component.Data.CustomId;
        });

        if (componentInstance == null) return;

        await componentInstance.ExecuteAsync(component);
    }

    private static async Task SelectMenuExecuted(SocketMessageComponent component)
    {
        if (client == null || guild == null) return;

        var componentInstance = components.FirstOrDefault(x =>
        {
            if (x.Name.ToString().Contains("("))
            {
                return x.Name.IsMatch(component.Data.CustomId);
            }
            return x.Name.ToString() == component.Data.CustomId;
        });
        if (componentInstance == null) return;

        await componentInstance.ExecuteAsync(component);
    }

    private static async Task UserUpdated(SocketUser before, SocketUser after)
    {
        if (before.GetAvatarUrl() != after.GetAvatarUrl())
        {
            var account = await AccountManager.GetUserAccount(after.Id);
            if (account != null)
            {
                await AccountManager.UpdateUserAvatar(after.Id, account.uid, after.GetAvatarUrl());
            }
        }
    }

    public static SocketTextChannel? GetChannel(ulong channelId)
    {
        if (client == null || guild == null) return null;
        return guild.GetTextChannel(channelId);
    }
}