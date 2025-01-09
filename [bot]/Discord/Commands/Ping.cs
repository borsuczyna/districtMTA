using System.Diagnostics;
using Discord.WebSocket;

namespace DiscordBot.Client;

public class Ping : SlashCommandBase
{
    public Ping()
    {
        Name = "ping";
        Description = "Sprawdź ping aplikacji";
    }

    public override async Task ExecuteAsync(SocketSlashCommand command)
    {
        var ping = await GetPing();
        var discordPing = GetDiscordPing(command);

        var embed = DefaultEmbedBuilder.GetDefaultEmbedBuilder();
        embed.WithTitle("Ping");
        embed.WithDescription($"Ping aplikacji: {ping}ms\nPing Discord: {discordPing}ms");

        await command.RespondAsync(embed: embed.Build(), ephemeral: true);
    }

    private int GetDiscordPing(SocketSlashCommand command)
    {
        var requestTimestamp = command.CreatedAt;
        var currentTimestamp = DateTimeOffset.UtcNow;
        return (int)-(currentTimestamp - requestTimestamp).TotalMilliseconds;
    }

    private async Task<int> GetPing()
    {
        using var client = new HttpClient();
        var sw = new Stopwatch();
        sw.Start();
        var response = await client.GetAsync("https://www.google.com");
        sw.Stop();
        return (int)sw.ElapsedMilliseconds;
    }
}