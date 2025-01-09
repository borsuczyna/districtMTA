using Discord;

namespace DiscordBot.Client;

public class DefaultEmbedBuilder
{
    public static EmbedBuilder GetDefaultEmbedBuilder()
    {
        var embed = new EmbedBuilder();
        embed.WithColor(new Color(0xFD, 0x9B, 0x5E));
        embed.WithFooter("districtMTA", "https://i.imgur.com/Ccez7BN.png");
        embed.WithTimestamp(DateTimeOffset.Now);

        return embed;
    }
}