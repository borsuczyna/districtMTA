using System.Text;
using System.Xml;

public enum ScriptType
{
    Server,
    Client,
    Shared
}

public class MTAScript
{
    private static HttpClient _httpClient = new();
    private Dictionary<string, bool> apiCodes = new()
    {
        ["ERROR Nothing to do - Please select compile and/or obfuscate"] = true,
        ["ERROR Could not compile file"] = true,
        ["ERROR Could not read file"] = true,
        ["ERROR Already compiled"] = true,
        ["ERROR Already encrypted"] = true,
    };

    public string path { get; set; }
    public string name { get; set; }
    public ScriptType type { get; set; } = ScriptType.Shared;
    
    public MTAScript(string path, ScriptType type)
    {
        name = new DirectoryInfo(path).Name;
        this.path = Path.GetDirectoryName(path) ?? string.Empty;
        this.type = type;
    }

    public async Task<byte[]?> Compile(string resourcePath)
    {
        var scriptPath = Path.Combine(resourcePath, path, name);
        if (!File.Exists(scriptPath))
            return null;

        var script = await File.ReadAllTextAsync(scriptPath);
        var response = await _httpClient.PostAsync("https://luac.mtasa.com/?compile=1&debug=0&obfuscate=3", new StringContent(script));

        if (!response.IsSuccessStatusCode)
            return null;

        var buffer = await response.Content.ReadAsByteArrayAsync();
        var responseString = Encoding.UTF8.GetString(buffer);
        if (apiCodes.ContainsKey(responseString))
        {
            Console.WriteLine($"Failed to compile {name} with response: {responseString}");
            return null;
        }

        return buffer;
    }
}

public class MTAFile
{
    public string path { get; set; }
    public string name { get; set; }
    public bool isValid { get; set; }

    public MTAFile(string path)
    {
        this.path = path;
        name = new DirectoryInfo(path).Name;
        isValid = true;
    }
}

public class MTAResource
{
    public string path { get; set; }
    public string name { get; set; }
    public bool isValid { get; set; }
    private List<MTAScript> scripts { get; set; } = new();
    private List<MTAFile> files { get; set; } = new();

    public MTAResource(string path)
    {
        this.path = path;
        name = new DirectoryInfo(path).Name;
        
        isValid = ReadMeta();
        // Console.WriteLine($"Resource {name} {(isValid ? "loaded" : "not loaded")} with {scripts.Count} scripts");
    }

    private bool ReadMeta()
    {
        var metaPath = Path.Combine(path, "meta.xml");
        if (!File.Exists(metaPath))
            return false;
        
        var xml = new XmlDocument();
        xml.Load(metaPath);

        // Read scripts
        var scriptNodes = xml.SelectNodes("//script");
        if (scriptNodes == null)
        {
            Console.WriteLine($"Script nodes not found in {name}/meta.xml");
            return false;
        }
        
        foreach (XmlNode scriptNode in scriptNodes)
        {
            string? scriptPath = null;
            var scriptType = ScriptType.Shared;
            var attributes = scriptNode.Attributes;
            if (attributes != null)
            {
                var srcAttribute = attributes.GetNamedItem("src");
                if (srcAttribute != null)
                    scriptPath = srcAttribute.InnerText.Replace("/", "\\");

                var typeAttribute = attributes.GetNamedItem("type");
                if (typeAttribute != null)
                {
                    var type = typeAttribute.InnerText.ToLower();
                    if (type == "server")
                        scriptType = ScriptType.Server;
                    else if (type == "client")
                        scriptType = ScriptType.Client;
                }
            }

            if (scriptPath == null)
            {
                Console.WriteLine($"Script path not found in {name}/meta.xml");
                return false;
            }

            var script = new MTAScript(scriptPath, scriptType);
            scripts.Add(script);
        }

        // Read files
        var fileNodes = xml.SelectNodes("//file");
        if (fileNodes == null)
        {
            Console.WriteLine($"File nodes not found in {name}/meta.xml");
            return false;
        }

        foreach (XmlNode fileNode in fileNodes)
        {
            string? filePath = null;
            var attributes = fileNode.Attributes;
            if (attributes != null)
            {
                var srcAttribute = attributes.GetNamedItem("src");
                if (srcAttribute != null)
                    filePath = srcAttribute.InnerText.Replace("/", "\\");
            }

            if (filePath == null)
            {
                Console.WriteLine($"File path not found in {name}/meta.xml");
                return false;
            }

            var file = new MTAFile(filePath);
            files.Add(file);
        }
        
        return true;
    }

    private async Task<bool> CompileScript(MTAScript script, string outputPath)
    {
        var scriptPath = Path.Combine(outputPath, name, script.path);
        if (!Directory.Exists(scriptPath))
            Directory.CreateDirectory(scriptPath);

        scriptPath = Path.Combine(scriptPath, script.name);
        var buffer = await script.Compile(path);
        if (buffer == null)
        {
            Console.WriteLine($"Failed to compile {script.name}");
            return false;
        }

        await File.WriteAllBytesAsync(scriptPath, buffer);
        return true;
    }

    private void CopyFiles(string sourcePath, string outputPath)
    {
        foreach (var file in files)
        {
            var sourceFilePath = Path.Combine(sourcePath, file.path);
            var outputFilePath = Path.Combine(outputPath, name, file.path);
            if (!Directory.Exists(Path.GetDirectoryName(outputFilePath)))
                Directory.CreateDirectory(Path.GetDirectoryName(outputFilePath) ?? string.Empty);
            
            string extension = Path.GetExtension(file.name);
            switch (extension)
            {
                case ".html":
                    var html = File.ReadAllText(sourceFilePath);
                    var obfuscator = new HtmlObfuscator();
                    File.WriteAllText(outputFilePath, obfuscator.Obfuscate(html));
                    break;
                case ".js":
                    var js = File.ReadAllText(sourceFilePath);
                    var obfuscatedCode = JavaScriptObfuscator.Obfuscate(js);
                    if (obfuscatedCode == null)
                        throw new Exception("Failed to obfuscate JavaScript code");

                    File.WriteAllText(outputFilePath, obfuscatedCode);
                    break;
                case ".css":
                    var css = File.ReadAllText(sourceFilePath);
                    var minifiedCss = CSSMinifier.Minify(css);
                    File.WriteAllText(outputFilePath, minifiedCss);
                    break;
                default:
                    File.Copy(sourceFilePath, outputFilePath, true);
                    break;
            }
        }
    }

    public async Task<bool> CompileScripts(string outputPath)
    {
        var tasks = new List<Task<bool>>();
        List<bool> results = new();

        foreach (var script in scripts)
        {
            tasks.Add(CompileScript(script, outputPath));

            if (tasks.Count >= 5)
            {
                results.AddRange(await Task.WhenAll(tasks));
                tasks.Clear();
            }
        }

        results.AddRange(await Task.WhenAll(tasks));
        return results.All(x => x);
    }

    public async Task<bool> Compile(string outputPath)
    {
        var metaPath = Path.Combine(outputPath, name, "meta.xml");
        if (!Directory.Exists(Path.Combine(outputPath, name)))
            Directory.CreateDirectory(Path.Combine(outputPath, name));

        File.Copy(Path.Combine(path, "meta.xml"), metaPath, true);

        CopyFiles(path, outputPath);
        return await CompileScripts(outputPath);
    }
}