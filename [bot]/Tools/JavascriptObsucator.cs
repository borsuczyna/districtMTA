using System.Diagnostics;

public class JavaScriptObfuscator
{
    private static string JSObfuscatorPath = "/home/mta/mods/deathmatch/resources/[serwer]/[bot]/js-obfuscator";

    public static string? Obfuscate(string code)
    {
        var tempFile = Path.GetTempFileName();
        var inputPath = Path.Combine(JSObfuscatorPath, "input.js");
        var outputPath = Path.Combine(JSObfuscatorPath, "output.js");

        File.WriteAllText(inputPath, code);

        var process = new Process
        {
            StartInfo = new ProcessStartInfo
            {
                FileName = "node",
                Arguments = $"\"{JSObfuscatorPath}/index.js\" \"{inputPath}\" \"{outputPath}\"",
                RedirectStandardOutput = true,
                RedirectStandardError = true,
                UseShellExecute = false,
                CreateNoWindow = true
            }
        };

        process.Start();
        var output = process.StandardOutput.ReadToEnd();
        var error = process.StandardError.ReadToEnd();
        process.WaitForExit();

        if (!string.IsNullOrEmpty(error))
        {
            Console.WriteLine(error);
            return null;
        }

        var obfuscatedCode = File.ReadAllText(outputPath);
        File.Delete(inputPath);
        File.Delete(outputPath);

        return obfuscatedCode;
    }
}