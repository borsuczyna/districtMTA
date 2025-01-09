using System.Dynamic;
using MySql.Data.MySqlClient;

namespace DiscordBot.Database;

public class DatabaseManager
{
    private static MySqlConnection? connection;

    public static MySqlConnection GetConnection()
    {
        if (connection == null)
        {
            connection = new MySqlConnection(Defines.MySqlConnectionString);
        }

        return connection;
    }

    public static void OpenConnection()
    {
        if (connection == null) return;

        connection.Open();
    }

    public static void CloseConnection()
    {
        if (connection == null) return;

        connection.Close();
    }

    public static void Dispose()
    {
        if (connection == null) return;

        connection.Dispose();
    }

    public static async Task<List<dynamic>> QueryAsync(string query, params object[] parameters)
    {
        GetConnection();
        if (connection == null) return new List<dynamic>();

        await connection.OpenAsync();

        var command = new MySqlCommand(query, connection);

        // find all ? in the query and replace them with @p0, @p1, @p2, ...
        for (int i = 0; i < parameters.Length; i++)
        {
            query = query.Replace("?", $"@p{i}");
        }

        // Add parameters to the command
        for (int i = 0; i < parameters.Length; i++)
        {
            command.Parameters.AddWithValue($"@p{i}", parameters[i]);
        }

        var reader = await command.ExecuteReaderAsync();

        var result = new List<dynamic>();

        while (await reader.ReadAsync())
        {
            var row = new ExpandoObject() as IDictionary<string, dynamic>;

            for (var i = 0; i < reader.FieldCount; i++)
            {
                row.Add(reader.GetName(i), reader.GetValue(i));
            }

            result.Add(row);
        }

        await reader.CloseAsync();
        await connection.CloseAsync();

        return result;
    }

    public static async Task<bool> ExecuteAsync(string query, params object[] parameters)
    {
        GetConnection();
        if (connection == null) return false;

        await connection.OpenAsync();

        var command = new MySqlCommand(query, connection);

        // find all ? in the query and replace them with @p0, @p1, @p2, ...
        for (int i = 0; i < parameters.Length; i++)
        {
            query = query.Replace("?", $"@p{i}");
        }

        // Add parameters to the command
        for (int i = 0; i < parameters.Length; i++)
        {
            command.Parameters.AddWithValue($"@p{i}", parameters[i]);
        }

        var result = await command.ExecuteNonQueryAsync();

        await connection.CloseAsync();

        return result > 0;
    }
}