using System.Text.RegularExpressions;
using Discord.WebSocket;

namespace DiscordBot.Client;

public class ComponentHandlerBase
{
    public Regex Name { get; set; } = new("");
    
    public ComponentHandlerBase() {}

    public ComponentHandlerBase(string name)
    {
        Name = new(name);
    }

    public virtual Task ExecuteAsync(SocketMessageComponent component)
    {
        return Task.CompletedTask;
    }
}