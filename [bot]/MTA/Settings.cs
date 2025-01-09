using DiscordBot.Database;

namespace DiscordBot.MTA;

public class AccountSettingsManager
{
    public class PossibleSetting
    {
        public string name { get; set; } = string.Empty;
        public string description { get; set; } = string.Empty;
        public List<string> possibleValues { get; set; } = new();

        public PossibleSetting(string name, string description, List<string> possibleValues)
        {
            this.name = name;
            this.description = description;
            this.possibleValues = possibleValues;
        }
    }

    public static List<PossibleSetting> possibleSettings = new()
    {
        new PossibleSetting("daily_reward", "Powiadomienia o nagrodzie dziennej", new List<string> { "Wyłączone", "Włączone" }),
    };

    private ulong uid = 0;
    private Dictionary<string, string> settings = new Dictionary<string, string>();

    public AccountSettingsManager(ulong uid, Dictionary<string, string> settings)
    {
        this.uid = uid;
        this.settings = settings;
    }

    public string GetSetting(string key, string defaultValue = "")
    {
        if (settings.ContainsKey(key))
            return settings[key];

        return defaultValue;
    }

    public async Task<bool> SetSetting(string key, string value)
    {
        var result = await DatabaseManager.ExecuteAsync("INSERT INTO `m-discord-settings` (`user`, `setting`, `value`) VALUES (?, ?, ?) ON DUPLICATE KEY UPDATE `value` = ?", uid, key, value, value);
        if (result)
            settings[key] = value;

        return result;
    }
}