using Discord;
using Discord.WebSocket;

namespace DiscordBot.Client;

public class SlashCommandArgument
{
    public string Name { get; set; } = string.Empty;
    public ApplicationCommandOptionType Type { get; set; }
    public string Description { get; set; } = string.Empty;
    public bool Required { get; set; }

    public SlashCommandArgument() {}
}

public class SlashCommandBase
{
    public string Name { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public List<SlashCommandArgument> Arguments { get; set; } = new();

    public SlashCommandBase() {}

    public SlashCommandBase(string name, string description)
    {
        Name = name;
        Description = description;
    }

    public void AddArgument(string name, ApplicationCommandOptionType type, string description, bool required = true)
    {
        Arguments.Add(new SlashCommandArgument
        {
            Name = name,
            Type = type,
            Description = description,
            Required = required
        });
    }

    public SlashCommandBuilder GetCommandBuilder()
    {
        var command = new SlashCommandBuilder();
        command.WithName(Name);
        command.WithDescription(Description);

        foreach (var argument in Arguments)
        {
            command.AddOption(new SlashCommandOptionBuilder
            {
                Name = argument.Name,
                Type = argument.Type,
                Description = argument.Description,
                IsRequired = argument.Required
            });
        }

        return command;
    }

    public virtual Task ExecuteAsync(SocketSlashCommand command)
    {
        return Task.CompletedTask;
    }
}